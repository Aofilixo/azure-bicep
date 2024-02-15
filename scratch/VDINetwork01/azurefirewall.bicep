param location string
param azureFirewallName string
param virtualHubId string
param firewallPolicyId string

resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: azureFirewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    virtualHub: {
      id: virtualHubId
    }
   
