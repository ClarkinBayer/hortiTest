@description('App Service Plan name')
param appServicePlanName string

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

@description('SKU name (e.g., F1, B1, B2, S1, P1v3)')
param skuName string = 'B2'

@description('Instance count')
param capacity int = 1

resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  tags: tags

  sku: {
    name: skuName
    capacity: capacity
  }

  properties: {
    reserved: true // required for Linux plans
    perSiteScaling: false
  }
}

output planId string = appServicePlan.id
