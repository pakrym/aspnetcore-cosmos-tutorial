param principalId string
param accountName string
param accountId string
param roleId string

resource role_assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-03-01-preview' = {
  name: '${accountName}/${principalId}'
  properties: {
    principalId: principalId
    roleDefinitionId: roleId
    scope: accountId
  }
}
