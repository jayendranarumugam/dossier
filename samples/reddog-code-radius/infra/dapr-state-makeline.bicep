import radius as radius

param appId string
param environment string

// REDISSSSS....
// Create the redis resource here. Actual infra. OR let the recipe handle it below...

resource daprStateMakeLine 'Applications.Link/daprStateStores@2022-03-15-privatepreview' = {
  name: 'reddog.state.makeline'
  location: 'global'
  properties: {
    application: appId
    environment: environment
    mode: 'recipe'
    recipe: {
      name: 'redis'
    }
  }
}

output daprStateStoreName string = daprStateMakeLine.name
