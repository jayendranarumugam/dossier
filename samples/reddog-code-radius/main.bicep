import radius as radius

param environment string

param location string = resourceGroup().location
param uniqueSeed string = resourceGroup().id

param sqlAdministratorLogin string = 'server_admin'
@secure()
param sqlAdministratorLoginPassword string = take(newGuid(), 16)


resource reddog 'Applications.Core/applications@2022-03-15-privatepreview' = {
  name: 'reddog'
  location: 'global'
  properties: {
    environment: environment
  }
}

////////////////////////////////////////////////////////////////////////////////
// Infrastructure
////////////////////////////////////////////////////////////////////////////////

// Azure SQL Database
module sqlServer 'infra/sqlserver.bicep' = {
  name: '${deployment().name}-sql'
  params: {
    appId: reddog.id
    environment: environment
    location: location
    uniqueSeed: uniqueSeed
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    accountingDbName: 'reddog'
  }
}

// TODO - need to understand bindings support / workaround
// Azure Storage (Receipts)
//module storage 'infra/storage.bicep' = {
//  name: '${deployment().name}-storage'
//  params: {
//    appId: reddog.id
//    environment: environment
//    location: location
//    uniqueSeed: uniqueSeed
//  }
//}

// Dapr Pub/Sub Broker
// Note: Module creates Azure Service Bus resource(s)
module daprPubSub 'infra/dapr-pubsub.bicep' = {
  name: '${deployment().name}-dapr-pubsub'
  params: {
    appId: reddog.id
    environment: environment
    location: location
    uniqueSeed: uniqueSeed
  }
}

// Dapr State Store - Loyalty
// Note: Module creates Azure Cosmos DB resource(s)
module daprStateLoyalty 'infra/dapr-state-loyalty.bicep' = {
  name: '${deployment().name}-dapr-state-loyalty'
  params: {
    appId: reddog.id
    environment: environment
    location: location
    uniqueSeed: uniqueSeed
  }
}

// Dapr State Store - Make Line
// Note: Module uses Redis recipe, so no infra explicitly created (hence no loc/seed)
module daprStateMakeLine 'infra/dapr-state-makeline.bicep' = {
  name: '${deployment().name}-dapr-state-makeline'
  params: {
    appId: reddog.id
    environment: environment
  }
}


// HTTP Routes
module httpRoutes 'infra/http-routes.bicep' = {
  name: '${deployment().name}-http-routes'
  params: {
    appId: reddog.id
  }
}

// Gateway
module gateway 'infra/gateway.bicep' = {
  name: '${deployment().name}-gateway'
  params: {
    appId: reddog.id
    uiRouteName: httpRoutes.outputs.uiRouteName
  }
}

// TODO
// Azure Key Vault (with reddog-sql and sb-connection-string/whatever)
// Dapr secret store for KV

////////////////////////////////////////////////////////////////////////////////
// Services
////////////////////////////////////////////////////////////////////////////////

// TODO: CAN THIS BE DEPLOYED AS A JOB?
// module bootstrapper 'services/bootstrapper.bicep' = {
//   name: '${deployment().name}-bootstrapper'
//   params: {
//   }
// }

module ui 'services/ui.bicep' = {
  name: '${deployment().name}-ui'
  params: {
    appId: reddog.id
    environment: environment
    daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
    uiRouteName: httpRoutes.outputs.uiRouteName
  }
}

module accountingService 'services/accounting-service.bicep' = {
  name: '${deployment().name}-accounting-service'
  params: {
    appId: reddog.id
    environment: environment
    daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
    accountingDbLinkName: sqlServer.outputs.accountingDbLinkName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
  }
}

module orderService 'services/order-service.bicep' = {
  name: '${deployment().name}-order-service'
  params: {
    appId: reddog.id
    environment: environment
    daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
  }
}

module makeLineService 'services/make-line-service.bicep' = {
  name: '${deployment().name}-make-line-service'
  params: {
    appId: reddog.id
    environment: environment
    daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
    daprStateStoreName: daprStateMakeLine.outputs.daprStateStoreName
  }
}

module loyaltyService 'services/loyalty-service.bicep' = {
  name: '${deployment().name}-loyalty-service'
  params: {
    appId: reddog.id
    environment: environment
    daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
    daprStateStoreName: daprStateLoyalty.outputs.daprStateStoreName
  }
}

// TODO: NEED TO HANDLE BINDING SOMEHOW
// module receiptGenerationService 'services/receipt-generation-service.bicep' = {
//   name: '${deployment().name}-receipt-generation-service'
//   params: {
//     appId: reddog.id
//     environment: environment
//     daprPubSubBrokerName: daprPubSub.outputs.daprPubSubBrokerName
//   }
// }

// TODO: NEED TO HANDLE CRON BINDING SOMEHOW
// module virtualWorker 'services/virtual-worker.bicep' = {
// }

// TODO Just don't want it right now...
// module virtualCustomer 'services/virtual-customer.bicep' = {
//   name: '${deployment().name}-virtual-customer'
//   params: {
//     appId: reddog.id
//     environment: environment
//   }
// }
