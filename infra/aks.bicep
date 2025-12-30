@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 1

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_B2s'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

@description('The name of the Azure Container Registry to integrate with the AKS cluster.')
param acrName string

@description('The name of the DNS Zone to which the AKS cluster will have access.')
param dnsZoneName string

var acrPullRoleDefinitionID = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull Role Definition ID
var dnsContributorRoleDefinitionID = 'befefa01-2a29-4197-83a8-272ff33ce314' // DNS Zone Contributor Role Definition ID

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
  name: acrName
}

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneName
}

resource aksToAcrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: guid(aks.id, 'AcrPullRoleAssignment', acrPullRoleDefinitionID)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionID)
    principalId: aks.identity.principalId
  }
}

resource askToDnsContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dnsZone
  name: guid(aks.id, 'DNSContributorRoleAssignment', dnsContributorRoleDefinitionID)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', dnsContributorRoleDefinitionID)
    principalId: aks.identity.principalId
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
