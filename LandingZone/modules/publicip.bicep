param pipAddressName string
param tags object
param pipLocation string 

@description('Optional. Name of a public IP address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param pipSkuName string = 'Basic'



resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for i in range(0, 2): {
  name: '${pipAddressName}${i + 1}'
  location: pipLocation
  sku: {
    name: pipSkuName
  }
  tags:tags
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${pipAddressName}${i + 1}'
    }

  }
}]
