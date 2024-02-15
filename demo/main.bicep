// Setting target scope
targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string
param storageName string
param storageLocation string
param vnetName string
param location string
param vnetAddressPrefix string
param subnet1Name string
param subnet1Prefix string
param subnet2Name string
param subnet2Prefix string

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
output resourceGroupName string = rg.name
output resourceGroupLocation string = rg.location

// Deploying VNet using module
module vnet './vnet.bicep' = {
  name: 'vnetModule'
  scope: rg
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Name: subnet1Name
    subnet1Prefix: subnet1Prefix
    subnet2Name: subnet2Name
    subnet2Prefix: subnet2Prefix
    location: location
  }
}

// Deploying storage account using module
module stg './storage.bicep' = {
  name: storageName
  scope: rg
  params: {
    storageName: storageName
    storageLocation: storageLocation
  }
}
