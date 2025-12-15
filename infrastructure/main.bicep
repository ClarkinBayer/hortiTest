param location string
param environment string

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

param mongoDatabaseName string
param collection1Name string
param collection2Name string
param sharedAutoscaleMaxThroughput int = 4000
param dedicatedAutoscaleMaxThroughput int = 8000
module logAnalytics './modules/log_analytics_workspace.bicep' = {
  name: 'logAnalytics'
  params: {
    workspaceName: logAnalyticsName
    location: location
    tags: tags
  }
}

module appInsights './modules/application_insights.bicep' = {
  name: 'appInsights'
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

module appServicePlan './modules/app_service_plan.bicep' = {
  name: 'appServicePlan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    tags: tags
  }
}

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

module cosmos './modules/cosmos_db.bicep' = {
  name: 'cosmos'
  params: {
    cosmosAccountName: cosmosAccountName
    mongoDatabaseName: mongoDatabaseName
    collection1Name: collection1Name
    collection2Name: collection2Name
    sharedAutoscaleMaxThroughput: sharedAutoscaleMaxThroughput
    dedicatedAutoscaleMaxThroughput: dedicatedAutoscaleMaxThroughput
    location: location
    tags: tags
  }
}
