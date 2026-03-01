import { Controller, Get } from "@nestjs/common";

@Controller()
export class AppController {
  @Get("health")
  health() { return { status: "healthy" }; }

  @Get()
  root() { return { service: "${{values.appName}}", version: "0.1.0" }; }
}
