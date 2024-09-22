param apiManagementServiceName string
param apimanagementApiName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource azureOpenAIApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagementService
  name: apimanagementApiName
}

resource validateRoutesPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apiManagementService
  name: 'validate-routes'
  properties: {
    value: loadTextContent('./fragments/frag-validate-routes.xml')
    format: 'rawxml'
  }
}

resource backendRoutingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apiManagementService
  name: 'backend-routing'
  properties: {
    value: loadTextContent('./fragments/frag-backend-routing.xml')
    format: 'rawxml'
  }
}

resource dynamicThrottlingFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apiManagementService
  name: 'dynamic-throttling-assignment'
  properties: {
    value: loadTextContent('./fragments/frag-dynamic-throttling-assignment.xml')
    format: 'rawxml'
  }
}

//with validation policies@2023-05-01-preview
resource azureOpenAIApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  parent: azureOpenAIApi
  name: 'policy'
  properties: {
    value: loadTextContent('./policies/policy.xml')
    format: 'rawxml'
  }
}
