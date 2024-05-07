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

@description('Optional : Describes plan instance count')
@minValue(1)
@maxValue(3)
param skuCapacity int = 1

// This property cannot be changed after infra creation and needs to be set during plan creation.
// Suggested to keep true for production to achieve high availability.
@description('Optional. Whether this App Service Plan will perform availability zone balancing. Default is false.')
param zoneRedundant bool

@description('Location for all resources.')
param location string = resourceGroup().location

@description('True if the operating system is linux else false.')
param useLinux bool = false

@description('The runtime stack of the App Service.')
@allowed([
  'Java 17 on Java SE'
  'Java 17 on Tomcat 10.0'
  'Java 11 on Java SE'
  'Java 11 on Tomcat 10.0'

])
param runtimeStack string = 'Java 17 on Java SE'

@description('Application Insights Name for logging and monitoring')
param applicationInsightsName string

@description('Whether public network access is enabled or disabled. Dafault is enabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('An array of IP security restriction rules.')
param ipSecurityRestrictions array = []

// Java version to be used.
var javaVersion = (startsWith(runtimeStack, 'Java 17') ? '17' : (startsWith(runtimeStack, 'Java 11') ? '11' : ''))

// Web container to be used.
var javaContainer = (endsWith(runtimeStack, 'Java SE') ? 'JAVA' : (contains(runtimeStack, 'Tomcat') ? 'TOMCAT' : ''))

//Web container version to be used.
var javaContainerVersion = (endsWith(runtimeStack, 'Java SE') ? 'SE' : (endsWith(runtimeStack, 'Tomcat 10.0') ? '10.0' : ''))

// web app kind property based on Os Type
var appServiceKind = (useLinux ? 'app,linux' : 'app')

// Resource definition of the App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: appServiceKind
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    zoneRedundant : zoneRedundant
  }
}

// Resource definition of the App Service (Web App)
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  kind: appServiceKind
  location: location
  identity: {
    type: 'SystemAssigned, UserAssigned'  //You can also have one of them as identity based on your requirement.
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      minTlsVersion: '1.2'
      javaVersion: javaVersion
      javaContainer: javaContainer
      javaContainerVersion: javaContainerVersion
      publicNetworkAccess: publicNetworkAccess
      ipSecurityRestrictions: ipSecurityRestrictions  // you can use this to restrict access to limited ips or CIDR ranges.
      appSettings: [
        // This is how you can link your appservice to application insights.
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference('microsoft.insights/components/${applicationInsightsName}', '2015-05-01').ConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference('microsoft.insights/components/${applicationInsightsName}', '2015-05-01').InstrumentationKey
        }
      ]
    }
  }
}

// output the resources name
output planName string = appServicePlan.name
output webAppName string = webApp.name
// you can aslo output other properties or entire object based on your requirement to use further.
