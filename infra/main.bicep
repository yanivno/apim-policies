targetScope = 'subscription'

param resourceGroupName string

// General Params
@description('region for service to be deployed')
param location string = deployment().location


//Application Insights + Log Analytics params
@description('The Application Insights Name')
param appInsightsName string = 'appinsights-test'

@description('The Log Analytics Workspace Name')
param logAnalyticsWorkspaceName string = 'log-test'


//API Management params
@description('The name of the API Management Service Name.')
param apiManagementServiceName string

@description('The name of the API Management Managed Identity Name.')
param apiManagementManagedIdentityName string = 'apim-identity'

@description('API Management Tier.')
param apiManagementSkuName string = 'Basic'

@description('API Management Unit Capacity.')
param apiManagementCapacity int = 1

//Backend OpenAI Config
var openAiDetails = [
  { name: 'ptu-instance', region: 'swedencentral', openAiUrl: 'https://aoai-1-qkojak7tombza.openai.azure.com/openai' }
  { name: 'paygo-instance-1', region: 'eastus', openAiUrl: 'https://aoai-2-qkojak7tombza.openai.azure.com/openai' }
  { name: 'paygo-instance-2', region: 'eastus2', openAiUrl: 'https://aoai-3-qkojak7tombza.openai.azure.com/openai' }
]

//Policy Config
param apiManagementApiName string = 'azure-openai-api'



// create resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// create log analytics workspace + application insights
module appInsights './modules/appinsights/appinsights.bicep' = {
  name: 'appInsights'
  scope: resourceGroup
  params: {
    location: location
    logAnalyticsWorkspaceName : logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
  }
}

module apiManagement './modules/apim/apim.bicep' = {
  name: 'apiManagement'
  scope: resourceGroup
  params: {
    location: location
    skuName: apiManagementSkuName
    capacity: apiManagementCapacity
    apiManagementServiceName: apiManagementServiceName
    apiManagementManagedIdentityName: apiManagementManagedIdentityName
    appInsightsName: appInsightsName
  }
  dependsOn: [
    appInsights
  ]
}

/*
module aoai './modules/aoai/aoai.bicep' = [for (config, i) in items(aoaiInstances): {
  name: config.value.name
  scope: resourceGroup
  params: {
    location: config.value.location
    deploymentName: config.value.name
    deploymentSuffix: deploymentSuffix
    apimIdentityName: apiManagement.outputs.apimIdentityName
  }
}]
*/

//API Mangement API Call
module apiImport './modules/config/apim-import.bicep' = {
  name: 'apiImport'
  scope: resourceGroup
  params: {
    apiManagementServiceName: apiManagementServiceName
  }
  dependsOn: [
    apiManagement
  ] 
}

//API Management Backends
module apiBackend './modules/config/apim-backend.bicep' = {
  name: 'apiBackend'
  scope: resourceGroup
  params: {
    openAiDetails: openAiDetails
    apiManagementServiceName: apiManagementServiceName
  } 
  dependsOn: [
    apiManagement
  ] 
}

//API Management Open AI Policy
module apiPolicy './modules/config/apim-policy.bicep' = {
  name: 'apiPolicy'
  scope: resourceGroup
  params: {
    apiManagementServiceName: apiManagementServiceName
    apimanagementApiName: apiManagementApiName
  }
  dependsOn: [
    apiImport
    apiBackend
  ]
}

module apiLogger './modules/config/apim-assign-logger.bicep' = {
  name: 'apiLogger'
  scope: resourceGroup
  params: {
    apiManagementServiceName: apiManagementServiceName
    apimanagementApiName: apiManagementApiName
    appInsightsLoggerId: apiManagement.outputs.appInsightsLoggerId
  }
  dependsOn: [
    apiPolicy
  ]
}

