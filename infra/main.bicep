
param linuxAdminUsername string

@secure()
param sshRSAPublicKey string

module acr 'acr.bicep' = {
  params: {
    acrName: 'mlhub'
  }
}

module blue_ask 'aks.bicep' = {
  params: {
    clusterName: 'mlhub-blue-cluster'
    dnsPrefix: 'mlhub-blue'
    acrName: 'mlhub'
    dnsZoneName: 'mlhub.ksharp.dev'
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshRSAPublicKey
  }
}

module green_ask 'aks.bicep' = {
  params: {
    clusterName: 'mlhub-green-cluster'
    dnsPrefix: 'mlhub-green'
    acrName: 'mlhub'
    dnsZoneName: 'mlhub.ksharp.dev'
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshRSAPublicKey
  }
}





