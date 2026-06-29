FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

WORKDIR /app

COPY capstone_portal.py /app/capstone_portal.py
COPY published_artifacts /app/published_artifacts

EXPOSE 8000

CMD ["python", "capstone_portal.py"]
