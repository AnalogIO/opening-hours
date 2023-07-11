param environment string

param webappVerificationIdValue string
param webappAzureGeneratedFqdn string

var appname = 'openinghours' 

resource dnszone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: '${environment}.analogio.dk'
}

resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: 'asuid.${appname}'
  parent: dnszone
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: array(webappVerificationIdValue)
      }
    ]
  }
}

resource cname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: appname
  parent: dnszone
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: webappAzureGeneratedFqdn
    }
  }
}

output customDomainFqdn string = cname.properties.fqdn
