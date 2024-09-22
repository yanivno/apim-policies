# Azure APIM GenAI policies

## Architecture Components

This repository contains the Bicep templates for deploying the following components:

- Azure APIM Basic SKU
- API Management Open AI Policy for AI Gateway (2024-06-01)
- API Management Fragments for backend
- Azure OpenAI API Management Backends (3)
- Application Insights + Log Analytics workspace

## Deployment

Customize Configuration: you can customize template params in main.bicep
Deploy the template to the Azure subscription using the following command:

```bash
    cd infra
    az deployment sub create --name apim-genai --template-file main.bicep --location swedencentral
```