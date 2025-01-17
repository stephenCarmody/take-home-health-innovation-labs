# PII Redaction Service 🕵️‍♂️

A service that automatically identifies and redacts Personally Identifiable Information (PII) from text data. Built as part of Montu's technical challenge.

## What it does 🎯

This service identifies and redacts the following types of PII:
- Names (people & organizations)
- Organizations
- Addresses
- Email addresses
- Phone numbers

# Delivery & Comments on the Project

## Technical Decisions 🤔

- Only implemented a dummy model for the sake of the challenge as I wanted to focus on the infrastructure and deployment pipeline
- Used Lambda for easy scaling without complex infrastructure
- Implemented basic CI/CD pipeline for automated testing and deployment
    - Currently the deployment pipeline is not fully implemented as I am not a heavy user of Lambda and wasnt sure wether to bake the model into the image or store it in Lambda ephemeral storage
- Used Terraform for easy management and reproducibility of infrastructure
- Used Justfile for easy management of the project

## What I would have done with more time

- Implemented a more robust deployment pipeline, and fixed the model loading strategy
- Implemented a working model
- Added more robust testing (more test coverage & integration tests)
- Added mypy for static type checking 
- Added instrumentation for observability (loggings, metrics, tracing)
- Added OIDC for authentication so endpoints are protected with a token
- Added load testing


## Getting Started 🚀

### Prerequisites

- Python 3.11+
- Docker
- AWS CLI (for deployment)

### Installation

1. Clone the repository:


```bash
git clone https://github.com/stephenCarmody/take-home-health-innovation-labs
cd take-home-health-innovation-labs
```

2. Install dependencies:

Make sure you have aws secrets added to infrastructure/.env_template and Python 3.11+ installed.


```bash
just init
```

3. Train the model:

```bash
just train
```

Copy the run_id to serving/settings.py MODEL_ID field


4. Serve the model:

```bash
just serve
```

5. Test the model:

```bash
just serving/test-info-local
```

```bash
just serving/test-redact-local
```

6. Deploy the model:

```bash
just deploy
```

