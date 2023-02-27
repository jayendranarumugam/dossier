import radius as radius

param appId string
param environment string

param daprPubSubBrokerName string

var daprAppId = 'order-service'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource orderService 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'order-service'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-order-service:latest'
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: orderServiceDaprRoute.id
      }
    ]
    connections: {
      pubsub: {
        source: daprPubSubBroker.id
      }
    }
  }
}

resource orderServiceDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'order-service-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output orderServiceDaprRouteName string = orderServiceDaprRoute.name
