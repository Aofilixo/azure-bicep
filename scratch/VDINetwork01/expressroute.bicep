param location string
param expressRouteGatewayName string
param virtualHubId string
param sku string = 'Standard'
param minScaleUnits int

resource expressRouteGateway 'Microsoft.Network/expressRouteGateways@2020-07-01' = {
  name: expressRouteGatewayName
  location: location
  properties: {
    autoScaleConfiguration: {
      bounds: {
        min: minScaleUnits
      }
    }
    virtualHub: {
      id: virtualHubId
    }
  }
  sku: {
    name: sku
  }
}
