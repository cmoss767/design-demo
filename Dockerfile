# Configuration Options:
# - Workers: Modify --workers 4 for different concurrency levels (default: 4)
# - Port: Default 3000, configurable via EXPOSE and CMD
# - Platform: Set via --platform flag for cross-platform compatibility
# - Base Image: python:3.11-slim chosen for minimal size while maintaining performance

FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

COPY api/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY api/app.py .

EXPOSE 3000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "3000", "--workers", "4"] 