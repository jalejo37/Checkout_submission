namespace Checkout.InternalApi.Models;

// Simple model representing the expected JSON request body.
// Example request:
// {
//   "message": "hello"
// }
public sealed class MessageRequest
{
    public string? Message { get; set; }
}
