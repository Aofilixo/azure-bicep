targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string
param storageName string
param storageLocation string
param vnetName string
param location string

param vnetAddressPrefix array = [
  '172.22.241.0/25'
]

@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets array = [
  {
    name: 'snet-untrusted'
    addressPrefix: '172.22.241.0/27'
  }
  {
    name: 'snet-trusted'
    addressPrefix: '172.22.241.32/27'
  }
  {
    name: 'snet-management'
    addressPrefix: '172.22.241.64/27'
  }
]

param storageSkuName string 



@description('Set of tags to apply to all resources.')
param tags object = {
  foo1: 'tag1'
  foo2: 'tag2'
  foo3: 'tag3'
  foo4: 'tag4'
}

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  tags: tags
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
    vnetAddressSpace: vnetAddressPrefix
    location: location
    subnets:subnets
    tags: tags
  }
}

// Deploying storage account using module
module stg './storage.bicep' = {
  name: storageName
  scope: rg
  params: {
    storageName: storageName
    storageLocation: storageLocation
    storageSkuName: storageSkuName
    tags: tags
  }
}
