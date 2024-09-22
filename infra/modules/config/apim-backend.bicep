param apiManagementServiceName string
param openAiDetails array


//existing api management instance
resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apiManagementServiceName
}

//create the backends
resource openAiBackends 'Microsoft.ApiManagement/service/backends@2022-08-01' = [for (openAiDetail, i) in openAiDetails: {
  name: openAiDetails[i].name
  parent: apiManagementService
  properties: {
    description: openAiDetails[i].name
    url: openAiDetails[i].openAiUrl
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}]

