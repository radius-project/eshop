import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('The name of the Webhooks SQL Link')
param sqlWebhooksDbName string

@description('The connection string for the event bus')
@secure()
param eventBusConnectionString string

// CONTAINERS -----------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webhooks-api
resource webhooks 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webhooks-api'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webhooks-api.yaml')
    }
    container: {
      env: {
        ConnectionString: sqlWebhooksDb.connectionString()
        EventBusConnection: eventBusConnectionString
      }
    }
    connections: {
      sql: {
        source: sqlWebhooksDb.id
        disableDefaultEnvVars: true
      }
    }
  }
}


// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webhooks-web
resource webhooksclient 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webhooks-client'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webhooks-web.yaml')
    }
  }
}

// LINKS -----------------------------------------------------------

resource sqlWebhooksDb 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: sqlWebhooksDbName
}
