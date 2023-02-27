import radius as radius

param appId string
param environment string
param daprPubSubBrokerName string

param uiRouteName string

var daprAppId = 'ui'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource uiRoute 'Applications.Core/httproutes@2022-03-15-privatepreview' existing = {
  name: uiRouteName
}

resource ui 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'ui'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-ui:latest'
      env: {
        VUE_APP_IS_CORP: 'false'
        VUE_APP_STORE_ID: 'Redmond'
        VUE_APP_SITE_TYPE: 'Pharmacy'
        VUE_APP_SITE_TITLE: 'Red Dog Bodega :: Market fresh food, pharmaceuticals, and fireworks!'
        // TODO: Should these be pulled somehow from a DaprRoute? Like in the Connections example for 'seq' route, etc.?
        VUE_APP_MAKELINE_BASE_URL: 'http://localhost:3500/v1.0/invoke/make-line-service/method'
        VUE_APP_ACCOUNTING_BASE_URL: 'http://localhost:3500/v1.0/invoke/accounting-service/method'
      }
      ports: {
        http: {
          containerPort: 8080
          provides: uiRoute.id
        }
      }
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 8080
        provides: uiDaprRoute.id
      }
    ]
    connections: {
      pubsub: {
        source: daprPubSubBroker.id
      }
    }
  }
}

resource uiDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'ui-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output uiDaprRouteName string = uiDaprRoute.name
