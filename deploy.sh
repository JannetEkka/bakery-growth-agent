#!/bin/bash
# ============================================================
# Bakery Growth Intelligence Agent — Cloud Run Deploy Script
# ============================================================
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="us-central1"
SERVICE_NAME="bakery-growth-agent"
IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"

if [ -z "$PROJECT_ID" ]; then
  echo "Error: No GCP project set. Run: gcloud config set project YOUR_PROJECT_ID"
  exit 1
fi

# Load MAPS_API_KEY from .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

if [ -z "$MAPS_API_KEY" ]; then
  echo "Error: MAPS_API_KEY not set. Add it to your .env file."
  exit 1
fi

echo "================================================"
echo "Deploying: $SERVICE_NAME"
echo "Project:   $PROJECT_ID"
echo "Region:    $REGION"
echo "Image:     $IMAGE"
echo "================================================"

# 1. Enable required APIs
echo "[1/4] Enabling APIs..."
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  bigquery.googleapis.com \
  aiplatform.googleapis.com \
  --project=$PROJECT_ID

# 2. Build and push container image
echo "[2/4] Building container image..."
gcloud builds submit --tag $IMAGE .

# 3. Deploy to Cloud Run
echo "[3/4] Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=global,GOOGLE_GENAI_USE_VERTEXAI=1,MAPS_API_KEY=$MAPS_API_KEY" \
  --service-account "$(gcloud iam service-accounts list --filter='displayName:Compute Engine default service account' --format='value(email)' --limit=1)" \
  --memory 512Mi \
  --timeout 300

# 4. Print service URL
echo "[4/4] Deployment complete!"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --format 'value(status.url)')
echo ""
echo "✅ Your agent is live at: $SERVICE_URL"
echo ""
echo "Submit this URL for your project: $SERVICE_URL"
