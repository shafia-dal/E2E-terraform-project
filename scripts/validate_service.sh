#!/bin/bash
APP_PORT=4000 # Assuming your app listens on port 4000
HEALTH_CHECK_URL="http://localhost:$APP_PORT/" # Or a specific health endpoint

echo "Performing health check on: $HEALTH_CHECK_URL"

RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_CHECK_URL")

if [ "$RESPONSE_CODE" -eq 200 ]; then
  echo "Health check successful (HTTP status code: $RESPONSE_CODE)."
else
  echo "Health check failed (HTTP status code: $RESPONSE_CODE)."
  exit 1
fi