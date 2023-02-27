import radius as radius

param appId string
param environment string

param daprPubSubBrokerName string

var daprAppId = 'receipt-generation-service'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource receiptGenerationService 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'receipt-generation-service'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-receipt-generation-service:latest'
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: receiptGenerationServiceDaprRoute.id
      }
    ]
    connections: {
      pubsub: {
        source: daprPubSubBroker.id
      }
    }
  }
}

resource receiptGenerationServiceDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'receipt-generation-service-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output receiptGenerationServiceDaprRouteName string = receiptGenerationServiceDaprRoute.name
