param location string = 'westeurope'
param environment string = 'tes'

param tags object = {
  application: 'hv'
  environment: environment
  managed_by: 'terraform'
  module: 'spraying'
  region: location
}

param logAnalyticsName string
param appInsightsName string
param appServicePlanName string
param webAppName string
param cosmosAccountName string

// Log Analytics
module logAnalytics './modules/log_analytics_workspace.bicep' = {
  name: 'logAnalytics'
  params: {
    workspaceName: logAnalyticsName
    location: location
    tags: tags
  }
}

// Application Insights
module appInsights './modules/application_insights.bicep' = {
  name: 'appInsights'
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

// App Service Plan
module appServicePlan './modules/app_service_plan.bicep' = {
  name: 'appServicePlan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    tags: tags
  }
}

// Web App
module webApp './modules/webapp.bicep' = {
  name: 'webApp'
  params: {
    webAppName: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.planId
    appInsightsResourceId: appInsights.outputs.appInsightsId
    tags: tags
  }
}

// Cosmos DB (Mongo)
module cosmos './modules/cosmos_db.bicep' = {
  name: 'cosmos'
  params: {
    cosmosAccountName: cosmosAccountName
    location: location
    tags: tags
  }
}
