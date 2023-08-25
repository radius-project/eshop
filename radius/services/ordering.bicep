import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('Name of the Keystore Redis Link')
param redisKeystoreName string

@description('Name of the Ordering SQL Link')
param sqlOrderingDbName string

@description('The connection string for the event bus')
@secure()
param eventBusConnectionString string

// CONTAINERS -------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/ordering-api
resource ordering 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'ordering-api'
  properties: {
    application: application
    runtimes: {
      kubernetes: {
        base: loadTextContent('helm-output/ordering-api.yaml')
      }
    }
    container: {
      env: {
        ConnectionString: sqlOrderingDb.connectionString()
        EventBusConnection: eventBusConnectionString
      }
    }
    connections: {
      sql: {
        source: sqlOrderingDb.id
        disableDefaultEnvVars: true
      }
    }
  }
}

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/ordering-backgroundtasks
resource orderbgtasks 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'ordering-backgroundtasks'
  properties: {
    application: application
    runtimes: {
      kubernetes: {
        base: loadTextContent('helm-output/ordering-backgroundtasks.yaml')
      }
    }
    container: {
      env: {
        ConnectionString: sqlOrderingDb.connectionString()
        EventBusConnection: eventBusConnectionString
      }
    }
    connections: {
      sql: {
        source: sqlOrderingDb.id
        disableDefaultEnvVars: true
      }
    }
  }
}

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/ordering-signalrhub
resource orderingsignalrhub 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'ordering-signalrhub'
  properties: {
    application: application
    runtimes: {
      kubernetes: {
        base: loadTextContent('helm-output/ordering-signalrhub.yaml')
      }
    }
    container: {
      env: {
        EventBusConnection: eventBusConnectionString
        SignalrStoreConnectionString: redisKeystore.connectionString()
      }
    }
    connections: {
      redis: {
        source: redisKeystore.id
        disableDefaultEnvVars: true
      }
    }
  }
}

// LINKS -----------------------------------------------------------

resource redisKeystore 'Applications.Link/redisCaches@2022-03-15-privatepreview' existing = {
  name: redisKeystoreName
}

resource sqlOrderingDb 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: sqlOrderingDbName
}
