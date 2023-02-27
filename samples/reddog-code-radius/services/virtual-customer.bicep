import radius as radius

param appId string
param environment string

var daprAppId = 'virtual-customers'

resource virtualCustomers 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'virtual-customers'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-virtual-customers:latest'
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
        provides: virtualCustomersDaprRoute.id
      }
    ]
  }
}

resource virtualCustomersDaprRoute 'Applications.Link/daprInvokeHttpRoutes@2022-03-15-privatepreview' = {
  name: 'virtual-customers-dapr-route'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    appId: daprAppId
  }
}

output virtualCustomersDaprRouteName string = virtualCustomersDaprRoute.name
