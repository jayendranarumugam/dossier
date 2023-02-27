import radius as radius

param appId string

param accountingDbLinkName string

@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

var daprAppId = 'bootstrapper'

resource accountingDbLink 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' existing = {
  name: accountingDbLinkName
}

// TODO
// This cannot scale to zero, so can this be deployed as a Job?
resource bootstrapper 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'bootstrapper'
  location: 'global'
  properties: {
    application: appId
    container: {
      image: 'ghcr.io/azure/reddog-retail-demo/reddog-retail-bootstrapper:latest'
      env: {
        'reddog-sql': 'Server=tcp:${accountingDbLink.properties.server},1433;Initial Catalog=${accountingDbLink.properties.database};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      }
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: daprAppId
        appPort: 80
      }
    ]
  }
}
