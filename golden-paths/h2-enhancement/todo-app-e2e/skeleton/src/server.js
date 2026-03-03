const http = require("http");

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", service: "${{ values.appName }}" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(
    JSON.stringify({
      message: "${{ values.appName }} is running",
      environment: "${{ values.environment }}",
      region: "${{ values.azureRegion }}"
    })
  );
});

server.listen(port, () => {
  console.log("Server listening on port " + port);
});
