targetScope = 'subscription'

@allowed([ 'dev', 'prd' ])
param environment string

var location = 'West Europe'

var organizationPrefix = 'aio'
var sharedResourcesAbbreviation = 'shr'

resource sharedRg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: 'rg-${organizationPrefix}-${sharedResourcesAbbreviation}-${environment}'
}

resource functionAppRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${organizationPrefix}-openingHours-${environment}'
  location: location
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'appi-${organizationPrefix}-${sharedResourcesAbbreviation}-${environment}'
  scope: resourceGroup(sharedRg.name)
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'log-${organizationPrefix}-${sharedResourcesAbbreviation}-${environment}'
  scope: resourceGroup(sharedRg.name)
}

module functionapp 'functionapp.bicep' = {
  name: '${deployment().name}-func-openingHours'
  scope: functionAppRg
  params: {
    location: location
    organizationPrefix: organizationPrefix
    environment: environment
    applicationInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sharedResourceGroupName: sharedRg.name
  }
}
