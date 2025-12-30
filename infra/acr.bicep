param location string = resourceGroup().location
param acrName string
param skuName string = 'Standard'
param adminUserEnabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: acrName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'disabled'
      }
    }
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrId string = acr.id
output acrName string = acr.name
