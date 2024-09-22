
param apiManagementServiceName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource azureOpenAIApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'azure-openai-api'
  properties: {
    path: '/openai'
    displayName: 'AzureOpenAI'
    protocols: ['https']
    value: loadTextContent('./apispec/openapi-2024-06-01-spec.yaml')
    format: 'openapi'
    subscriptionRequired: true
    subscriptionKeyParameterNames: {
      header: 'api-key'
    }
  }
}

