using Microsoft.Extensions.Hosting;

// This is the application entry point.
// HostBuilder creates the Azure Functions worker process and wires up the default services.
var host = new HostBuilder()
    // ConfigureFunctionsWorkerDefaults registers the standard Azure Functions isolated worker features,
    // such as dependency injection, logging, trigger binding support, and middleware defaults.
    .ConfigureFunctionsWorkerDefaults()
    .Build();

// Starts the function host and keeps it running so Azure can invoke the functions.
host.Run();
