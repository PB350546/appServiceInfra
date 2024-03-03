@description('Name of the app service plan.')
@minLength(1)
param appServicePlanName string

@description('Name of the Azure Web app to create.')
@minLength(1)
param webAppName string

@description('Describes plan pricing tier and instance size')
@allowed([
  'F1'
  'P3V2'
  'P3V3'
  'P2V2'
  'P2V3'
])
param skuName string

@description('Describes plan instance count')
@minValue(1)
@maxValue(3)
param skuCapacity int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Java version to be used.')
param javaVersion string

@description('Web container to be used.')
param javaContainer string

@description('Web container version to be used.')
param javaContainerVersion string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {}
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource webAppConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'web'
  properties: {
    javaVersion: javaVersion
    javaContainer: javaContainer
    javaContainerVersion: javaContainerVersion
  }
}

