FROM python:3.11-slim

WORKDIR /app
COPY pyproject.toml README.md config.sample.toml /app/
COPY autonomous_agent /app/autonomous_agent
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir .

ENV AGENT_CONFIG=/workspace/config.toml
WORKDIR /workspace
CMD ["autonomous-agent", "--task", "Describe the repository"]
