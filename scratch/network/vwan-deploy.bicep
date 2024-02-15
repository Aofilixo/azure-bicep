resource virtualWan 'Microsoft.Network/virtualWans@2023-05-01' = {
  name: 'name'
  location: location
  properties: any({
    type: 'Standard'
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    office365LocalBreakoutCategory: 'Optimize'
  })
}
