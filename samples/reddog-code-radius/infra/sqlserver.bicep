import radius as radius

param appId string
param environment string
param location string
param uniqueSeed string

param sqlServerName string = 'sql-${uniqueString(uniqueSeed)}'

@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

param accountingDbName string

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
  }

  resource sqlServerFirewall 'firewallRules@2021-05-01-preview' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      // Allow Azure services and resources to access this server
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }

  resource accountingDb 'databases@2021-05-01-preview' = {
    name: accountingDbName
    location: location
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
    }
  }

}

resource accountingDbLink 'Applications.Link/sqlDatabases@2022-03-15-privatepreview' = {
  name: 'accounting-db-link'
  location: location
  properties: {
    application: appId
    environment: environment
    mode: 'resource'
    resource: sqlServer::accountingDb.id
  }
}

output accountingDbLinkName string = accountingDbLink.name
