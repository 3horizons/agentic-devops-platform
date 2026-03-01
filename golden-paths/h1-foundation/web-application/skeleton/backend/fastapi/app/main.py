from fastapi import FastAPI
import structlog

logger = structlog.get_logger()
app = FastAPI(title="${{values.appName}}", version="0.1.0")

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/")
async def root():
    return {"service": "${{values.appName}}", "version": "0.1.0"}
