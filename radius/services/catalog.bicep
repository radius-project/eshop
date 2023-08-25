import radius as rad

// Parameters ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('The name of the Catalog SQL Link')
param sqlCatalogDbName string

@description('The connection string for the event bus')
@secure()
param eventBusConnectionString string

// CONTAINERS -------------------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/catalog-api
resource catalog 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'catalog-api'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/catalog-api.yaml')
    }
    container: {
      env: {
        ConnectionString: sqlCatalogDb.connectionString()
        EventBusConnection: eventBusConnectionString
      }
    }
    connections: {
      sql: {
        source: sqlCatalogDb.id
      }
    }
  }
}

// LINKS -----------------------------------------------------------

resource sqlCatalogDb 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: sqlCatalogDbName
}
