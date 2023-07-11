param location string

param organizationPrefix string

param environment string

param applicationInsightsInstrumentationKey string

param logAnalyticsWorkspaceId string

param sharedResourceGroupName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${organizationPrefix}-openingHours-${environment}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'sa${organizationPrefix}openinghours${environment}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    allowBlobPublicAccess: false
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'func-${organizationPrefix}-openingHours-${environment}'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      http20Enabled: true
      linuxFxVersion: 'DOTNET|6.0'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('openingHours')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }
}

resource diagnosticSettingsFunctionApp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Function App Logs'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
  }
}

module dns 'modules/webappDns.bicep' = {
  name: '${deployment().name}-openinghours-dns'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    environment: environment
    webappVerificationIdValue: functionApp.properties.customDomainVerificationId
    webappAzureGeneratedFqdn: functionApp.properties.defaultHostName
  }
}

module certificate 'modules/webappManagedCertificate.bicep' = {
  name: '${deployment().name}-core-certificate'
  params: {
    location: location
    environment: environment
    appservicePlanId: appServicePlan.id
    webAppName: functionApp.name
  }

  dependsOn: [
    dns
  ]
}

module bindCertificate 'modules/bindCustomDomainCertificate.bicep' = {
  name: '${deployment().name}-core-bind-certificate'
  params: {
    webAppName: functionApp.name
    certificateThumbprint: certificate.outputs.certificateThumbprint
    customDomainFqdn: certificate.outputs.customDomainFqdn
  }

  dependsOn: [
    certificate
  ]
}
