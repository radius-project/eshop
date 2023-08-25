import radius as rad

// Parameters -------------------------------------------------------

@description('Name of the eshop application. Defaults to "eshop"')
param appName string = 'eshop'

@description('Radius environment ID. Set automatically by Radius')
param environment string

@description('SQL administrator username')
param adminLogin string = 'SA'

@description('SQL administrator password')
@secure()
param adminPassword string = newGuid()

@description('Use Azure Service Bus for messaging. Defaults to "False"')
@allowed([
  'True'
  'False'
])
param AZURESERVICEBUSENABLED string = 'False'

// Application --------------------------------------------------------

resource eshop 'Applications.Core/applications@2022-03-15-privatepreview' = {
  name: appName
  properties: {
    environment: environment
  }
}

// Infrastructure ------------------------------------------------------

module infra 'infra/infra.bicep' = {
  name: 'infra'
  params: {
    application: eshop.id
    environment: environment
    adminLogin: adminLogin
    adminPassword: adminPassword
    AZURESERVICEBUSENABLED: AZURESERVICEBUSENABLED
  }
}

// Services ------------------------------------------------------------

module basket 'services/basket.bicep' = {
  name: 'basket'
  params: {
    application: eshop.id
    redisBasketName: infra.outputs.redisBasket
    eventBusConnectionString: infra.outputs.eventBusConnectionString
  }
}

module catalog 'services/catalog.bicep' = {
  name: 'catalog'
  params: {
    application: eshop.id
    sqlCatalogDbName: infra.outputs.sqlCatalogDb
    eventBusConnectionString: infra.outputs.eventBusConnectionString
  }
}

module identity 'services/identity.bicep' = {
  name: 'identity'
  params: {
    application: eshop.id
    redisKeystoreName: infra.outputs.redisKeystore
    sqlIdentityDbName: infra.outputs.sqlIdentityDb
  }
}

module ordering 'services/ordering.bicep' = {
  name: 'ordering'
  params: {
    application: eshop.id
    redisKeystoreName: infra.outputs.redisKeystore
    sqlOrderingDbName: infra.outputs.sqlOrderingDb
    eventBusConnectionString: infra.outputs.eventBusConnectionString
  }
}

module payment 'services/payment.bicep' = {
  name: 'payment'
  params: {
    application: eshop.id 
    eventBusConnectionString: infra.outputs.eventBusConnectionString
  }
}

module seq 'services/seq.bicep' = {
  name: 'seq'
  params: {
    application: eshop.id 
  }
}

module web 'services/web.bicep' = {
  name: 'web'
  params: {
    application: eshop.id
    redisKeystoreName: infra.outputs.redisKeystore
  }
}

module webhooks 'services/webhooks.bicep' = {
  name: 'webhooks'
  params: {
    application: eshop.id
    sqlWebhooksDbName: infra.outputs.sqlWebhooksDb
    eventBusConnectionString: infra.outputs.eventBusConnectionString
  }
}

module webshopping 'services/webshopping.bicep' = {
  name: 'webshopping'
  params: {
    application: eshop.id
  }
}

module webstatus 'services/webstatus.bicep' = {
  name: 'webstatus'
  params: {
    application: eshop.id
  }
}
