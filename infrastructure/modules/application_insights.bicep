@description('Application Insights name')
param appInsightsName string

@description('Azure region')
param location string = 'westeurope'

@description('Log Analytics Workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Resource tags')
param tags object = {
  application: 'hv'
  environment: 'tes'
  managed_by: 'terraform'
  module: 'spraying'
  region: 'westeurope'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags

  properties: {
    Application_Type: 'web'

    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'

    SamplingPercentage: 100
    RetentionInDays: 90

    DisableIpMasking: false
    DisableLocalAuth: false

    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output appInsightsId string = appInsights.id
