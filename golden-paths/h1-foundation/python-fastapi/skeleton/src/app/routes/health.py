"""Health check routes."""

from datetime import datetime, timezone

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health() -> dict[str, str]:
    """Basic health check endpoint.

    Returns the service status and current timestamp.
    """
    return {
        "status": "ok",
        "timestamp": datetime.now(tz=timezone.utc).isoformat(),
    }


@router.get("/ready")
async def ready() -> dict[str, bool]:
    """Readiness probe endpoint.

    Returns whether the service is ready to accept traffic.
    """
    return {
        "ready": True,
    }
