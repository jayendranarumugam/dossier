import radius as radius

param appId string
param environment string

param daprPubSubBrokerName string
param daprStateStoreName string

var daprAppId = 'make-line-service'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource daprStateStore 'Applications.Link/daprStateStores@2022-03-15-privatepreview' existing = {
  name: daprStateStoreName
}

resource makeLineService 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'make-line-service'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-make-line-service:latest'
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: makeLineServiceDaprRoute.id
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

resource makeLineServiceDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'make-line-service-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output makeLineServiceDaprRouteName string = makeLineServiceDaprRoute.name
