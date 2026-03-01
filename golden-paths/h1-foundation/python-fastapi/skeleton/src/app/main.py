"""${{ values.name }} - FastAPI application."""

import os
from contextlib import asynccontextmanager
from collections.abc import AsyncGenerator

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.health import router as health_router

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan context manager for startup and shutdown events."""
    logger.info("application_startup", name="${{ values.name }}")
    yield
    logger.info("application_shutdown", name="${{ values.name }}")


app = FastAPI(
    title="${{ values.name }}",
    description="${{ values.description }}",
    version="1.0.0",
    lifespan=lifespan,
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(health_router)


@app.get("/api/v1/info")
async def info() -> dict[str, str]:
    """Return service information."""
    return {
        "name": "${{ values.name }}",
        "version": "1.0.0",
        "environment": os.getenv("ENVIRONMENT", "development"),
    }
