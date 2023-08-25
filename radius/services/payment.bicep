import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

@description('The connection string for the event bus')
@secure()
param eventBusConnectionString string

// CONTAINERS ---------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/payment-api
resource payment 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'payment-api'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/payment-api.yaml')
    }
    container: {
      env: {
        EventBusConnection: eventBusConnectionString
      }
    }
  }
}
