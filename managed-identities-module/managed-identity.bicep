// This Bicep file creates multiple managed identities

targetScope = 'resourceGroup'

var details = [
  { name: 'openai-user-1', region: 'eastus', openAiInstanceName: 'aoai-1-qkojak7tombza' }
  { name: 'openai-user-2', region: 'eastus2', openAiInstanceName: 'aoai-2-qkojak7tombza' }
  { name: 'openai-user-3', region: 'canadaeast', openAiInstanceName: 'aoai-3-qkojak7tombza' }
  { name: 'openai-user-4', region: 'swedencentral', openAiInstanceName: 'ynorman-gpt-swe' }
]

//name: guid(managedIdentity.id, resourceGroup().id, roleDefinitionId)

//Cognitive Services OpenAI User
var roleDefinitionId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'


resource managedUsers 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = [for (detail, i) in details: {
  name: detail.name
  location: detail.region
}]

resource existingOpenAiInstances 'Microsoft.CognitiveServices/accounts@2021-04-30' existing = [for (detail, i) in details: {
  name: detail.openAiInstanceName
  scope: resourceGroup()
}
]

//CognitiveServicesOpenAIUser'
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =  [for (detail, i) in details: {
  scope: existingOpenAiInstances[i]
  name: guid(existingOpenAiInstances[i].id, managedUsers[i].name  , roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId) // Cognitive Services OpenAI User role
    principalId: managedUsers[i].properties.principalId
    principalType: 'ServicePrincipal'
  }
}
]


/*
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, 'myOpenAiInstance', 'Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader role
    principalId: openAiInstance.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}
*/
