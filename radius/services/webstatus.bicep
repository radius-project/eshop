import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

// CONTAINAERS ---------------------------------------------------------

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webstatus
resource webstatus 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webstatus'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webstatus.yaml')
    }
  }
}
