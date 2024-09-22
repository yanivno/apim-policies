var apimName = 'apim-qkojak7tombza'

//backends prefix
var openAiApiBackendId = 'openai-backend'

//urls
param openAiUris array = [
  'https://aoai-1-qkojak7tombza.openai.azure.com/openai'
  'https://aoai-2-qkojak7tombza.openai.azure.com/openai'
  'https://aoai-3-qkojak7tombza.openai.azure.com/openai'
]

//existing api management instance
resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimName
}

//create the backends
resource openAiBackends 'Microsoft.ApiManagement/service/backends@2022-08-01' = [for (openAiUri, i) in openAiUris: {
  name: '${openAiApiBackendId}-${i}'
  parent: apiManagementService
  properties: {
    description: openAiApiBackendId
    url: openAiUri
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}]

