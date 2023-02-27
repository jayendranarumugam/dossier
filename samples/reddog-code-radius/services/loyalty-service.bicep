import radius as radius

param appId string
param environment string

param daprPubSubBrokerName string
param daprStateStoreName string

var daprAppId = 'loyalty-service'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource daprStateStore 'Applications.Link/daprStateStores@2022-03-15-privatepreview' existing = {
  name: daprStateStoreName
}

resource loyaltyService 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'loyalty-service'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-loyalty-service:latest'
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: loyaltyServiceDaprRoute.id
      }
    ]
    connections: {
      pubsub: {
        source: daprPubSubBroker.id
      }
      statestore: {
        source: daprStateStore.id
      }
    }
  }
}

resource loyaltyServiceDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'loyalty-service-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output loyaltyServiceDaprRouteName string = loyaltyServiceDaprRoute.name
