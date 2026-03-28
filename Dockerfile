# Use official Python slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY bakery_growth_app/ ./bakery_growth_app/

# Cloud Run sets PORT env var; ADK web server respects it
ENV PORT=8080

# ADK web serves on 0.0.0.0 so Cloud Run can reach it
CMD ["sh", "-c", "adk web --host 0.0.0.0 --port $PORT bakery_growth_app"]
