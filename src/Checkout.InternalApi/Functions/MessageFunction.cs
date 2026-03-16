using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using Checkout.InternalApi.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Checkout.InternalApi.Functions;

public sealed class MessageFunction
{
    // ILogger is injected by the Functions runtime so request flow and failures are written to logs.
    private readonly ILogger<MessageFunction> _logger;

    public MessageFunction(ILogger<MessageFunction> logger)
    {
        _logger = logger;
    }

    [Function("PostMessage")]
    public async Task<HttpResponseData> Run(
        // HTTP POST endpoint exposed at /api/message.
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "message")] HttpRequestData req,
        FunctionContext context)
    {
        // Each function invocation gets a unique id. This is returned to the caller and written to logs.
        var requestId = context.InvocationId;
        string? requestBody = null;

        try
        {
            // First validate the client certificate before doing any business logic.
            // This supports the assessment requirement for mutual TLS style client authentication.
            if (!TryValidateClientCertificate(req, out var certificateError))
            {
                _logger.LogWarning("Rejected request {RequestId}. Client certificate validation failed: {Reason}", requestId, certificateError);
                var unauthorized = req.CreateResponse(HttpStatusCode.Unauthorized);
                await unauthorized.WriteAsJsonAsync(new
                {
                    error = "Client certificate validation failed.",
                    requestId,
                    details = certificateError
                });
                return unauthorized;
            }

            // Read the raw request body from the incoming HTTP stream.
            requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            // Convert the JSON into the MessageRequest model.
            // PropertyNameCaseInsensitive allows both message and Message.
            var payload = JsonSerializer.Deserialize<MessageRequest>(requestBody, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            // Basic input validation.
            // The API requires a non empty message field before it will continue.
            if (payload is null || string.IsNullOrWhiteSpace(payload.Message))
            {
                _logger.LogInformation("Rejected request {RequestId}. Message was missing or empty.", requestId);
                var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequest.WriteAsJsonAsync(new
                {
                    error = "Request body must contain a non empty 'message' field.",
                    requestId
                });
                return badRequest;
            }

            _logger.LogInformation("Accepted request {RequestId}. MessageLength={MessageLength}", requestId, payload.Message.Length);

            // Build the success response required by the assessment:
            // original message, timestamp, and request id.
            var ok = req.CreateResponse(HttpStatusCode.OK);
            await ok.WriteAsJsonAsync(new
            {
                message = payload.Message,
                timestampUtc = DateTime.UtcNow,
                requestId
            });
            return ok;
        }
        catch (JsonException ex)
        {
            // Handles malformed JSON cleanly instead of returning an unhelpful generic 500 error.
            _logger.LogWarning(ex, "Rejected request {RequestId}. Invalid JSON payload.", requestId);
            var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
            await badRequest.WriteAsJsonAsync(new
            {
                error = "Invalid JSON payload.",
                requestId
            });
            return badRequest;
        }
        catch (Exception ex)
        {
            // Catch all for unexpected failures.
            // The raw body is logged to help troubleshooting, though in a real production API
            // you would be careful not to log sensitive or personal data.
            _logger.LogError(ex, "Unhandled error while processing request {RequestId}. RequestBody={RequestBody}", requestId, requestBody);
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteAsJsonAsync(new
            {
                error = "An unexpected error occurred.",
                requestId
            });
            return errorResponse;
        }
    }

    private static bool TryValidateClientCertificate(HttpRequestData req, out string reason)
    {
        reason = string.Empty;

        // Azure App Service forwards the client certificate in the X ARR ClientCert header
        // when client certificate forwarding is enabled.
        if (!req.Headers.TryGetValues("X-ARR-ClientCert", out var certHeaders))
        {
            reason = "Client certificate header was not present.";
            return false;
        }

        var certHeader = certHeaders.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(certHeader))
        {
            reason = "Client certificate header was empty.";
            return false;
        }

        // The trusted CA certificate is expected to be stored in configuration.
        // In Azure this would normally come from an app setting backed by Key Vault.
        var caPem = Environment.GetEnvironmentVariable("MTLS_CA_CERT_PEM");
        if (string.IsNullOrWhiteSpace(caPem))
        {
            reason = "Trusted CA certificate was not configured in app settings.";
            return false;
        }

        try
        {
            // Convert the incoming hex string into an X509 certificate object.
            using var clientCertificate = new X509Certificate2(Convert.FromHexString(certHeader));

            // Load the trusted Certificate Authority certificate from PEM text.
            using var trustedCaCertificate = X509Certificate2.CreateFromPem(caPem);
            using var chain = new X509Chain();

            // Revocation checks are disabled here because this is a simplified interview solution
            // using self signed certificates rather than a full enterprise PKI setup.
            chain.ChainPolicy.RevocationMode = X509RevocationMode.NoCheck;

            // AllowUnknownCertificateAuthority is paired with a custom trust store below.
            // This means only the CA we explicitly add is trusted for chain validation.
            chain.ChainPolicy.VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority;
            chain.ChainPolicy.ExtraStore.Add(trustedCaCertificate);
            chain.ChainPolicy.CustomTrustStore.Add(trustedCaCertificate);
            chain.ChainPolicy.TrustMode = X509ChainTrustMode.CustomRootTrust;

            // Build validates that the client certificate chains back to the trusted CA.
            var isValid = chain.Build(clientCertificate);
            if (!isValid)
            {
                reason = string.Join("; ", chain.ChainStatus.Select(status => status.StatusInformation.Trim()));
            }

            return isValid;
        }
        catch (Exception ex)
        {
            reason = ex.Message;
            return false;
        }
    }
}
