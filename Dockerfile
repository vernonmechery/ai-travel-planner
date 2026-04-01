# Use uv package manager, ARM64 compatible architecture
FROM --platform=linux/arm64 ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app

# Install build tools for compiling dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements.txt
COPY requirements.txt .

# Use uv pip to install dependencies 
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system --no-cache -r requirements.txt

# Open Telemetry
RUN pip install --no-cache-dir "aws-opentelemetry-distro>=0.10.0" boto3

# Copy app source code and pyproject.toml
COPY src/ ./src/
COPY pyproject.toml .

# AWS OPEN TELEMETRY
ENV OTEL_SERVICE_NAME=ai_travel_planner_agent
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=otlp

ENV OTEL_PYTHON_DISTRO=aws_distro
ENV OTEL_PYTHON_CONFIGURATION=aws_configurator

ENV OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf


ENV AGENT_OBSERVABILITY_ENABLED=true
ENV OTEL_TRACES_SAMPLER=always_on
ENV OTEL_RESOURCE_ATTRIBUTES=service.namespace=AgentCore,service.version=1.0

ENV AGENT_OBSERVABILITY_ENABLED=true

# Expose port
EXPOSE 8080

# Startup command - Runs the app
# CMD ["python", "src/ai_travel_planner/crew.py"]

CMD ["opentelemetry-instrument", "python", "src/ai_travel_planner/crew.py"]