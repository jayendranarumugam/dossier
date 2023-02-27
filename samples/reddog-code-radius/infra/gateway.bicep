import radius as radius

param appId string

param uiRouteName string

resource uiRoute 'Applications.Core/httpRoutes@2022-03-15-privatepreview' existing = {
  name: uiRouteName
}

resource gateway 'Applications.Core/gateways@2022-03-15-privatepreview' = {
  name: 'gateway'
  location: 'global'
  properties: {
    application: appId
    routes: [
      // UI
      {
        path: '/'
        destination: uiRoute.id
      }
    ]
  }
}

output url string = gateway.properties.url
