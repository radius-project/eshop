import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('Name of the Keystore Redis Link name')
param redisKeystoreName string

// CONTAINER --------------------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webspa
resource webspa 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'web-spa'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webspa.yaml')
    }
    container: {
      env: {
        DPConnectionString: redisKeystore.connectionString()
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

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webmvc
resource webmvc 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webmvc'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webmvc.yaml')
    }
    container: {
      env: {
        DPConnectionString: redisKeystore.connectionString()
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

// LINKS ------------------------------------------------------

resource redisKeystore 'Applications.Link/redisCaches@2022-03-15-privatepreview' existing = {
  name: redisKeystoreName
}
