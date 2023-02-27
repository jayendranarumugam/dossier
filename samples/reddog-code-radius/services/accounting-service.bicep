import radius as radius

param appId string
param environment string

param daprPubSubBrokerName string
param accountingDbLinkName string

@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

var daprAppId = 'accounting-service'

resource daprPubSubBroker 'Applications.Link/daprPubSubBrokers@2022-03-15-privatepreview' existing = {
  name: daprPubSubBrokerName
}

resource accountingDbLink 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: accountingDbLinkName
}

// TODO: NEED TO FIGURE OUT PROBES
resource accountingService 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'accounting-service'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-accounting-service:latest'
      env: {
        'reddog-sql': 'Server=tcp:${accountingDbLink.properties.server},1433;Initial Catalog=${accountingDbLink.properties.database};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      }
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: accountingServiceDaprRoute.id
      }
    ]
    connections: {
      sql: {
        source: accountingDbLink.id
      }
      pubsub: {
        source: daprPubSubBroker.id
      }
    }
  }
}

resource accountingServiceDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'accounting-service-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output accountingServiceDaprRouteName string = accountingServiceDaprRoute.name
