import radius as radius

param appId string

resource uiRoute 'Applications.Core/httproutes@2022-03-15-privatepreview' = {
  name: 'ui-route'
  location: 'global'
  properties: {
    application: appId
  }
}

output uiRouteName string = uiRoute.name
