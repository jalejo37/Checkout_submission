using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;

namespace Checkout.InternalApi.Functions;

public sealed class HealthFunction
{
    [Function("Health")]
    public async Task<HttpResponseData> Run(
        // HTTP GET endpoint exposed at /api/health.
        // AuthorizationLevel.Function means a function key is required unless access is handled upstream.
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "health")] HttpRequestData req,
        FunctionContext context)
    {
        // Create a 200 OK response that can be used by health checks or monitoring tools.
        var response = req.CreateResponse(HttpStatusCode.OK);

        // Return a minimal payload showing service status, the current UTC time, and the invocation id.
        // The invocation id is useful when matching a response to logs in Application Insights.
        await response.WriteAsJsonAsync(new
        {
            status = "Healthy",
            timestampUtc = DateTime.UtcNow,
            requestId = context.InvocationId
        });

        return response;
    }
}
