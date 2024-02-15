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
param virtualHubName string = 'MyVirtualHub'
param virtualHubLocation string = 'East US'
param virtualHubTags object = {
  tagName1: 'tagValue1'
  tagName2: 'tagValue2'
}
param virtualHubAddressPrefix string = 'your_virtual_hub_address_prefix'
param virtualHubAllowBranchToBranchTraffic bool = true
param virtualHubAzureFirewallId string = 'your_azure_firewall_id'
param virtualHubExpressRouteGatewayId string = 'your_express_route_gateway_id'
param virtualHubRoutingPreference string = 'your_hub_routing_preference'
param virtualHubP2SVpnGatewayId string = 'your_p2s_vpn_gateway_id'
param virtualHubPreferredRoutingGateway string = 'your_preferred_routing_gateway'
param virtualHubRouteTableRoutes array = [
  {
    addressPrefixes: ['your_route_address_prefix']
    nextHopIpAddress: 'your_next_hop_ip_address'
  }
]
param virtualHubSecurityPartnerProviderId string = 'your_security_partner_provider_id'
param virtualHubSecurityProviderName string = 'your_security_provider_name'
param virtualHubSku string = 'your_sku'
param virtualHubRouteTableV2s array = [
  {
    id: 'your_virtual_hub_route_table_id'
    name: 'your_virtual_hub_route_table_name'
    properties: {
      attachedConnections: ['your_attached_connection']
      routes: [
        {
          destinations: ['your_destination']
          destinationType: 'your_destination_type'
          nextHops: ['your_next_hop']
          nextHopType: 'your_next_hop_type'
        }
      ]
    }
  }
]
param virtualHubVirtualRouterAsn int = 65501
param virtualHubVirtualRouterAutoScaleConfigurationMinCapacity int = 2
param virtualHubVirtualRouterIps array = ['your_virtual_router_ip']
param virtualHubVirtualWanId string = 'your_virtual_wan_id'
param virtualHubVpnGatewayId string = 'your_vpn_gateway_id'

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
output resourceGroupName string = rg.name
output resourceGroupLocation string = rg.location

// Using the virtual hub module
module virtualHubModule './VirtualHubModule.bicep' = {
  name: 'virtualHubModule'
  params: {
    virtualHubName: virtualHubName
    location: virtualHubLocation
    tags: virtualHubTags
    addressPrefix: virtualHubAddressPrefix
    allowBranchToBranchTraffic: virtualHubAllowBranchToBranchTraffic
    azureFirewallId: virtualHubAzureFirewallId
    expressRouteGatewayId: virtualHubExpressRouteGatewayId
    hubRoutingPreference: virtualHubRoutingPreference
    p2SVpnGatewayId: virtualHubP2SVpnGatewayId
    preferredRoutingGateway: virtualHubPreferredRoutingGateway
    routeTableRoutes: virtualHubRouteTableRoutes
    securityPartnerProviderId: virtualHubSecurityPartnerProviderId
    securityProviderName: virtualHubSecurityProviderName
    sku: virtualHubSku
    virtualHubRouteTableV2s: virtualHubRouteTableV2s
    virtualRouterAsn: virtualHubVirtualRouterAsn
    virtualRouterAutoScaleConfigurationMinCapacity: virtualHubVirtualRouterAutoScaleConfigurationMinCapacity
    virtualRouterIps: virtualHubVirtualRouterIps
    virtualWanId: virtualHubVirtualWanId
    vpnGatewayId: virtualHubVpnGatewayId
  }
}

module expressRoute './expressroute.bicep' = {
  name: 'ExpressRouteDeployment'
  params: {
    location: location
    expressRouteGatewayName: 'YourExpressRouteGatewayName'
    virtualHubId: vwanHub.outputs.vwanHubId
    minScaleUnits: 1
  }
}

module azureFirewall './azurefirewall.bicep' = {
  name: 'AzureFirewallDeployment'
  params: {
    location: location
    azureFirewallName: 'YourAzureFirewallName'
    virtualHubId: vwanHub.outputs.vwanHubId
    firewallPolicyId: 'YourFirewallPolicyResourceId'
  }
}

