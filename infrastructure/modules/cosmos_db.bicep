@description('Cosmos DB account name')
param cosmosAccountName string

@description('Mongo database name')
param mongoDatabaseName string

@description('First collection name')
param collection1Name string

@description('Second collection name')
param collection2Name string

@description('Autoscale max RU/s for shared DB')
param sharedAutoscaleMaxThroughput int = 4000

@description('Autoscale max RU/s for dedicated collection')
param dedicatedAutoscaleMaxThroughput int = 8000

@description('Azure region')
param location string

@description('Resource tags')
param tags object

/* =========================
   Cosmos DB Account
   ========================= */

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

/* =========================
   Mongo Database
   ========================= */

resource mongoDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-05-15' = {
  parent: cosmosAccount
  name: mongoDatabaseName
  properties: {
    resource: {
      id: mongoDatabaseName
    }
    options: {
      autoscaleSettings: {
        maxThroughput: sharedAutoscaleMaxThroughput
      }
    }
  }
}

/* =========================
   Collection 1
   ========================= */

resource collection1 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2022-05-15' = {
  parent: mongoDatabase
  name: collection1Name
  properties: {
    resource: {
      id: collection1Name
      shardKey: {
        user_id: 'Hash'
      }
      indexes: [
        {
          key: {
            keys: ['_id']
          }
        }
        {
          key: {
            keys: ['$**']
          }
        }
        {
          key: {
            keys: [
              'product_name'
              'product_category_name'
            ]
          }
        }
      ]
    }
  }
}

/* =========================
   Collection 2
   ========================= */

resource collection2 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2022-05-15' = {
  parent: mongoDatabase
  name: collection2Name
  properties: {
    resource: {
      id: collection2Name
      shardKey: {
        company_id: 'Hash'
      }
      indexes: [
        {
          key: {
            keys: ['_id']
          }
        }
        {
          key: {
            keys: ['$**']
          }
        }
        {
          key: {
            keys: [
              'customer_id'
              'order_id'
            ]
          }
        }
      ]
    }
    options: {
      autoscaleSettings: {
        maxThroughput: dedicatedAutoscaleMaxThroughput
      }
    }
  }
}

/* =========================
   Outputs
   ========================= */

output cosmosAccountId string = cosmosAccount.id
output mongoDatabaseNameOut string = mongoDatabase.name
