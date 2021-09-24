param location string
param baseName string
param identity string = ''

resource webSite 'Microsoft.Web/sites@2021-01-15' = {
  name: '${baseName}frontend'
  location: location
  properties: {
    serverFarmId: appService.id
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource webappappsettings 'config' = {
    name: 'appsettings'
    properties: {
      'Cosmos__Endpoint': cosmosAccount.properties.documentEndpoint
      'Cosmos__Database': cosmosAccount::cosmosDatabase.name
      'WEBSITE_RUN_FROM_PACKAGE': '1'
      'APPINSIGHTS_INSTRUMENTATIONKEY': appInsights.properties.InstrumentationKey
    }
  }
}

resource appService 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: '${baseName}appService'
  location: location
  sku: {
    name: 'D1'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' =  {
  name: '${baseName}appInsights'
  location: location
  kind: 'web'
  properties: {
     Application_Type: 'web'
  }
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: '${toLower(baseName)}cosmosaccount'
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
  
  resource cosmosDatabase 'sqlDatabases' = {
    name: 'ToDo'
    properties: {
      resource: {
        id: 'ToDo'
      }
    }

    resource containers 'containers' = {
      name: 'ToDos'
      properties: {
        resource: {
          id: 'ToDos'
          partitionKey: {
            paths: [ 
              '/id'
            ]
          }
        }
        options: {
        }
      }
    }
  }
}

var readWriteRoleDefinitionId = guid(cosmosAccount.name, 'ReadWriteRole')

resource cosmosReadWriteRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-03-01-preview' = {
  name: '${cosmosAccount.name}/${readWriteRoleDefinitionId}'
  properties: {
    assignableScopes: [
      cosmosAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
        ]
        notDataActions: []
      }
    ]
    roleName: 'Reader Writer'
    type: 'CustomRole'
  }
}

module cosmosAssignmentApp 'CosmosRole.bicep' = if (empty(identity)) {
  name: 'cosmosAssignmentApp'
  params: {
    accountName: cosmosAccount.name
    accountId: cosmosAccount.id
    principalId: webSite.identity.principalId
    roleId: cosmosReadWriteRoleDefinition.id
  }
}

module cosmosAssignmentUser 'CosmosRole.bicep' = if (!empty(identity)) {
  name: 'cosmosAssignmentUser'
  params: {
    accountName: cosmosAccount.name
    accountId: cosmosAccount.id
    principalId: identity
    roleId: cosmosReadWriteRoleDefinition.id
  }
}

output CosmosEndpoint string = cosmosAccount.properties.documentEndpoint
output CosmosDatabase string = cosmosAccount::cosmosDatabase.name

output WebSiteName string = webSite.name
output APPINSIGHTS_INSTRUMENTATIONKEY string = appInsights.properties.InstrumentationKey
