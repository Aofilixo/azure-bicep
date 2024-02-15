// Setting target scope
targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string
param storageName string
param storageLocation string

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

// Deploying storage account using module
module stg './storage.bicep' = {
  name: 'test-bicep01'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    storageName: storageName
    storageLocation: storageLocation
  }
}
