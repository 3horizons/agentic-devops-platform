# =============================================================================
# Multi-stage Dockerfile for .NET 8 Web API
# Stage 1: Build and publish the application
# Stage 2: Run with the ASP.NET runtime
# =============================================================================

# --- Build Stage ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY src/*.csproj ./
RUN dotnet restore

COPY src/ ./
RUN dotnet publish -c Release -o /app/publish --no-restore

# --- Production Stage ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY --from=build /app/publish .

USER app

EXPOSE 8080

ENTRYPOINT ["dotnet", "${{ values.name }}.dll"]
