var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => new { service = "${{values.appName}}", version = "0.1.0" });
app.MapGet("/health", () => new { status = "healthy" });

app.Run();
