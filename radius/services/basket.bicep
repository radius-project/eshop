import radius as rad

// Parameters ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('The name of the Redis Basket Link')
param redisBasketName string

@description('The connection string for the event bus')
@secure()
param eventBusConnectionString string

// Container -------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/basket-api
resource basket 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'basket-api'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/basket-api.yaml')
    }
    container: {
      env: {
        ConnectionString: redisBasket.connectionString()
        EventBusConnection: eventBusConnectionString
      }
    }
    connections: {
      redis: {
        source: redisBasket.id
        disableDefaultEnvVars: true
      }
    }
  }
}

// Links ------------------------------------------

resource redisBasket 'Applications.Link/redisCaches@2022-03-15-privatepreview' existing = {
  name: redisBasketName
}
