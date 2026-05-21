FROM python:3.11-slim

WORKDIR /app

# 1. Install dependencies as root
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Create your locked-down user
RUN adduser --system --no-create-home --shell /bin/false jawad

# 3. Copy the files first and grant jawad explicit ownership
COPY --chown=jawad:jawad app/ .

# 4. FIX: Force the entire container environment to look at /tmp instead of /nonexistent
ENV HOME=/tmp
ENV GUNICORN_CMD_ARGS="--worker-tmp-dir /tmp"

# 5. Now switch down to the unprivileged user context
USER jawad

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]
