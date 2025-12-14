@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region')
param location string = 'westeurope'

@description('Resource tags')
param tags object = {
  application: 'hv'
  environment: 'tes'
  managed_by: 'terraform'
  module: 'spraying'
  region: 'westeurope'
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: workspaceName
  location: location
  tags: tags

  properties: {
    sku: {
      name: 'PerGB2018'
    }

    retentionInDays: 30

    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }

    workspaceCapping: {
      dailyQuotaGb: -1
    }

    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output workspaceId string = logAnalytics.id
