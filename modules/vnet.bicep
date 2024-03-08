// Define a parameter for the VNet name
param vnetName string

// Define a parameter for the location
param location string

// Optionally, define a parameter for tags if needed
param tags object = {
  foo1: 'tag1'
  foo2: 'tag2'
  foo3: 'tag3'
}


@description('Array containing virtual network address space(s)')
param vnetAddressSpace array = [
  '10.0.0.0/16'
]

@description('Array containing DNS Servers')
param dnsServers array = []

param subnets array = [
  {
    name: 'subnet1'
    addressPrefix: '10.0.1.0/24'
  }
  {
  name: 'subnet2'
  addressPrefix: '10.0.2.0/24'
  }
  {
  name: 'subnet3'
  addressPrefix: '10.0.3.0/24'
  }
]
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
    dhcpOptions: empty(dnsServers) ? null : {
      dnsServers: dnsServers
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
}



output name string = vnet.name
output id string = vnet.id
