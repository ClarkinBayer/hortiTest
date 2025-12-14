@description('Web App name')
param webAppName string

@description('Azure region')
param location string = 'westeurope'

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Application Insights resource ID (for hidden-link tag)')
param appInsightsResourceId string

@description('Resource tags')
param tags object = {
  application: 'hv'
  environment: 'tes'
  managed_by: 'terraform'
  module: 'spraying'
  region: 'westeurope'
}

resource webApp 'Microsoft.Web/sites@2024-11-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  tags: union(tags, {
    'hidden-link:/app-insights-resource-id': appInsightsResourceId
  })

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    reserved: true

    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      minimumElasticInstanceCount: 1
    }
  }
}
