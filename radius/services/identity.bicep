import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('Name of the Identity SQL Database Link')
param sqlIdentityDbName string

@description('Name of the Keystore Redis Link')
param redisKeystoreName string

// CONTAINERS -------------------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/identity-api
resource identity 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'identity-api'
  properties: {
    application: application
    runtimes: {
      kubernetes: {
        base: loadTextContent('helm-output/identity-api.yaml')
      }
    }
    container: {
      env: {
        DPConnectionString: redisKeystore.connectionString()
        ConnectionString: sqlIdentityDb.connectionString()
      }
    }
    connections: {
      redis: {
        source: redisKeystore.id
        disableDefaultEnvVars: true
      }
      sql: {
        source: sqlIdentityDb.id
        disableDefaultEnvVars: true
      }
    }
  }
}

// LINKS -----------------------------------------------------------

resource sqlIdentityDb 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: sqlIdentityDbName
}

resource redisKeystore 'Applications.Link/redisCaches@2022-03-15-privatepreview' existing = {
  name: redisKeystoreName
}
