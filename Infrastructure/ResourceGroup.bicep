param identity string = ''

targetScope = 'subscription'

resource webAppResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: deployment().name
  location: deployment().location
}

module resources 'Resources.bicep' = {
  name: 'resources'
  scope: webAppResourceGroup
  params: {
    location: deployment().location
    baseName: deployment().name
    identity: identity
  }
}

output Cosmos__Endpoint string = resources.outputs.CosmosEndpoint
output Cosmos__Database string = resources.outputs.CosmosDatabase
output WebSiteName string = resources.outputs.WebSiteName
