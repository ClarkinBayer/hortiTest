@description('Cosmos DB account name')
param cosmosAccountName string

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

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: cosmosAccountName
  location: location
  kind: 'MongoDB'
  tags: tags

  properties: {
    databaseAccountOfferType: 'Standard'

    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]

    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }

    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    disableLocalAuth: false
    minimalTlsVersion: 'Tls12'

    apiProperties: {
      serverVersion: '5.0'
    }

    capabilities: [
      { name: 'EnableMongo' }
      { name: 'DisableRateLimitingResponses' }
      { name: 'EnableMongo16MBDocumentSupport' }
    ]

    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
  }
}
