# 🥐 Bakery Growth Intelligence Agent

An AI agent built with **Google Agent Development Kit (ADK)** that connects to **BigQuery** and **Google Maps** via remote MCP servers to help a bakery chain make smart expansion and forecasting decisions.

## What It Does

This agent combines two data sources to solve two real business problems:

### 📦 Delivery Zone Optimizer
Scores Los Angeles zip codes using foot traffic patterns and demographics to identify the best zones for delivery expansion. Cross-references with Maps to check competitor density before recommending.

### 📈 Sales Trend Forecaster
Analyzes weekly sales history to flag underperforming stores and project next-month revenue. Uses Maps to investigate whether nearby competition explains performance gaps.

## Architecture

```
User
 │
 └─► ADK Agent (Gemini 2.0 Flash)
       │
       ├─► MCP Server for BigQuery ──► mcp_bakery dataset
       │     (demographics, foot_traffic,   (BigQuery)
       │      bakery_prices, sales_history)
       │
       └─► MCP Server for Maps ──► Google Maps APIs
             (search places,           (Grounding Lite)
              directions, geocoding)
```

## Sample Prompts

```
"Which zip codes in Los Angeles should we prioritize for delivery? 
 I want afternoon and evening coverage."

"Which of our stores is underperforming? Show me week-over-week trends 
 and project next month's revenue for each."

"Is Silver Lake worth expanding? Check foot traffic, competitor density, 
 and project revenue if we open there."
```

## Project Structure

```
bakery_growth_agent/
├── bakery_growth_app/
│   ├── __init__.py       # Package init
│   ├── agent.py          # Agent definition + system prompt
│   └── tools.py          # MCP toolset configuration
├── requirements.txt      # Python dependencies
├── Dockerfile            # Container for Cloud Run
├── deploy.sh             # One-command deployment script
└── .env.example          # Environment variable template
```

## Setup & Run Locally

### Prerequisites
- Google Cloud project with billing enabled
- `mcp_bakery` BigQuery dataset provisioned (from codelab setup scripts)
- Google Maps API key with Maps Grounding Lite enabled

### 1. Clone and configure
```bash
git clone <your-repo-url>
cd bakery_growth_agent

cp .env.example .env
# Edit .env with your project ID and Maps API key
```

### 2. Authenticate
```bash
gcloud auth application-default login
```

### 3. Install and run
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

adk web bakery_growth_app
```

Open http://localhost:8080 to chat with your agent.

## Deploy to Cloud Run

```bash
chmod +x deploy.sh
./deploy.sh
```

The script will build the container, deploy to Cloud Run, and print your submission URL.

## Environment Variables

| Variable | Description |
|---|---|
| `GOOGLE_CLOUD_PROJECT` | Your GCP project ID |
| `GOOGLE_CLOUD_LOCATION` | Region (e.g. `global`) |
| `GOOGLE_GENAI_USE_VERTEXAI` | Set to `1` for Vertex AI |
| `MAPS_API_KEY` | Google Maps Platform API key |

## MCP Integration

This agent uses two **remote, Google-hosted MCP servers**:

- **BigQuery MCP**: `https://bigquery.googleapis.com/mcp` — authenticated via ADC OAuth token
- **Maps Grounding Lite MCP**: `https://mapstools.googleapis.com/mcp` — authenticated via API key

No local MCP server processes are needed — all tool execution is handled server-side by Google.
