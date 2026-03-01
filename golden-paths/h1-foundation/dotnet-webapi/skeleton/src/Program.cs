using Serilog;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// Structured Logging (Serilog)
// ---------------------------------------------------------------------------
builder.Host.UseSerilog((context, configuration) =>
    configuration.ReadFrom.Configuration(context.Configuration));

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "${{ values.name }}",
        Version = "v1",
        Description = "${{ values.description }}"
    });
});

var app = builder.Build();

// ---------------------------------------------------------------------------
// Middleware
// ---------------------------------------------------------------------------
app.UseSerilogRequestLogging();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ---------------------------------------------------------------------------
// Health & Readiness Endpoints
// ---------------------------------------------------------------------------
app.MapHealthChecks("/health");

app.MapGet("/ready", () => Results.Ok(new
{
    ready = true,
    timestamp = DateTime.UtcNow
}))
.WithName("Readiness")
.WithTags("health");

// ---------------------------------------------------------------------------
// API Endpoints
// ---------------------------------------------------------------------------
app.MapGet("/api/v1/info", () => Results.Ok(new
{
    name = "${{ values.name }}",
    version = "1.0.0",
    environment = app.Environment.EnvironmentName
}))
.WithName("GetServiceInfo")
.WithTags("info");

// ---------------------------------------------------------------------------
// Run
// ---------------------------------------------------------------------------
Log.Information("Starting ${{ values.name }}");
app.Run();
