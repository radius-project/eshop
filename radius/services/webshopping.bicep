import radius as rad

// PARAMETERS ---------------------------------------------------------

@description('Radius application ID')
param application string

// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/webshoppingagg
resource webshoppingagg 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webshoppingagg'
  properties: {
    application: application
    runtimes: {
      base: loadTextContent('helm-output/webshoppingagg.yaml')
    }
  }
}


// Based on https://github.com/dotnet-architecture/eShopOnContainers/tree/dev/deploy/k8s/helm/apigwws
resource webshoppingapigw 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'webshoppingapigw'
  properties: {
    application: application
    container: {
      image: 'radius.azurecr.io/eshop-envoy:0.1.4'
    }
  }
}
