# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app
COPY app/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Production runtime
FROM python:3.11-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Force home directory creation (-m) for the system user
RUN groupadd -r appuser && useradd -r -g appuser -m appuser

WORKDIR /app

# Copy artifacts and assign ownership simultaneously
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser app/ .

# Set environment variables
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Switch to the secure non-root user
USER appuser

# Synced cleanly with the Gunicorn port below
EXPOSE 8080

# HEALTHCHECK is intentionally removed here. 
# You will configure the health check on your AWS Target Group pointing to /health instead.

# Scaled workers down to 2 to maximize performance on a cost-effective 0.5 vCPU Fargate task
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "2", "--timeout", "30", "app:app"]
