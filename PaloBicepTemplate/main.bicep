@description('Set of tags to apply to all resources.')
param tags object = {
  publicIP: 'paloalto'
  foo2: 'tag2'
  foo3: 'tag3'
  foo4: 'tag4'
}
param storageLocation string
param storageName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])

@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'
@description('Location for all resources.')
param location string = resourceGroup().location
@description('Your source public IP address. Added to the inbound NSG on eth0 (MGMT)')
param srcIPInboundNSG string = '0.0.0.0/0'
@description('String passed down to the Virtual Machine.')
param customData string = 'echo customData'
@description('Name of VM-Series VM in the Azure portal')
param vmName string = 'VM-Series'
@description('Version number of VM-Series VM in the Azure portal')
@allowed([
  'latest'
  '10.1.0'
  '10.0.6'
  '9.1.10'
])
param imageVersion string = 'latest'
@description('Azure VM size for VM-Series')
@allowed([
  'Standard_D3_v2'
  'Standard_D4_v2'
])
param vmSize string = 'Standard_D3_v2'
@description('Name of the Virtual Network (VNET)')
param virtualNetworkName string = 'cloudcore-egress-vdi-eastus-sandbox'
@description('Use new or existing VNET')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string = 'new'
@description('Virtual network address CIDR')
param virtualNetworkAddressPrefixes array = array('172.22.241.0/25')
@description('Name of resource group of existing VNET (if applicable)')
param virtualNetworkExistingRGName string = ''
@description('Subnet for Management')
param subnet0Name string = 'Mgmt'
@description('Subnet for Untrust')
param subnet1Name string = 'Untrust'
@description('Subnet for Trust')
param subnet2Name string = 'Trust'
@description('Mgmt subnet CIDR')
param subnet0Prefix string = '172.22.241.64/27'
@description('Untrust subnet CIDR')
param subnet1Prefix string = '172.22.241.32/27'
@description('Trust subnet CIDR')
param subnet2Prefix string = '172.22.241.0/27'
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'
@description('Username of the administrator account of VM-Series')
param adminUsername string
@description('Password or ssh key for the administrator account of VM-Series.')
@secure()
param adminPasswordOrKey string
@description('Public IP for mgmt interface is new or existing')
param pipAddressName string
@description('Name of existing public IP resource group')
param bootstrap string = 'yes'
@description('Availability Zone for VM-Series')
param zone string = 'None'
param availabilitySetName string 

var imagePublisher = 'paloaltonetworks'
var imageSku = 'byol'
var imageOffer = 'vmseries-flex'
var nsgName_Mgmt = 'Mgmt-nsg'
var nsgName_Untrusted = 'Untrusted-nsg'
var nsgName_Trusted = 'Trusted-nsg'
var nicName = '${vmName}-${pipAddressName}-eth'
var existingVnetID = resourceId(virtualNetworkExistingRGName, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var existingSubnet0Ref = '${existingVnetID}/subnets/${subnet0Name}'
var existingSubnet1Ref = '${existingVnetID}/subnets/${subnet1Name}'
var existingSubnet2Ref = '${existingVnetID}/subnets/${subnet2Name}'
var newVnetID = virtualNetworkName_resource.id
var newSubnet0Ref = '${newVnetID}/subnets/${subnet0Name}'
var newSubnet1Ref = '${newVnetID}/subnets/${subnet1Name}'
var newSubnet2Ref = '${newVnetID}/subnets/${subnet2Name}'
var subnet0Ref = ((vnetNewOrExisting == 'new') ? newSubnet0Ref : existingSubnet0Ref)
var subnet1Ref = ((vnetNewOrExisting == 'new') ? newSubnet1Ref : existingSubnet1Ref)
var subnet2Ref = ((vnetNewOrExisting == 'new') ? newSubnet2Ref : existingSubnet2Ref)
var virtualNetworkAddressPrefix = virtualNetworkAddressPrefixes[0]

var zones = [
  zone
]
var availabilitySet = {
  id: availabilitySetName_resource.id
}
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var subnets = [
  {
    name: subnet0Name
    properties: {
      addressPrefix: subnet0Prefix
      networkSecurityGroup: {
        id: nsgMgmt.id
      }
    }
  }
  {
    name: subnet1Name
    properties: {
      addressPrefix: subnet1Prefix
      networkSecurityGroup: {
        id: nsgUntrusted.id // to do create 
      }
    }
  }
  {
    name: subnet2Name
    properties: {
      addressPrefix: subnet2Prefix
      networkSecurityGroup: {
        id: nsgTrusted.id
      }
    }
  }
]

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for i in range(0, 2): {
  name: '${pipAddressName}${i + 1}'
  location: location
  sku: {
    name: 'Standard'
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

resource nsgMgmt 'Microsoft.Network/networkSecurityGroups@2017-10-01' = {
  name: nsgName_Mgmt
  location: location
  properties: {
    securityRules: [
      {
        name: 'MGMT_OUT'
        properties: {
          description: 'Rule'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: srcIPInboundNSG
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1010
          direction: 'Inbound'
        }
      }
      {
        name: 'PanoramaNatIn'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.154.20.120' 
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      ]
    }
  }

resource nsgTrusted 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName_Trusted
  location: location
  properties: {
    securityRules: [
      {
        name: 'ANY'
        properties: {
          description: 'Allow_all_in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Trust_OUT'
        properties: {
          description: 'Allow_all_out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1010
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource nsgUntrusted 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName_Untrusted
  location: location
  properties: {
    securityRules: [
      {
        name: 'ANY'
        properties: {
          description: 'Allow_all_in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      { 
        name: 'Trust_OUT'
        properties: {
          description: 'Allow_all_out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1010
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2017-10-01' = if (vnetNewOrExisting == 'new') {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnets
  }
}
resource nicName_0 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: '${nicName}0'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-mgmt'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip[0].id
          }
          subnet: {
            id: subnet0Ref
          }
        }
      }
    ]
  }
}
resource nicName_1 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: '${nicName}1'
  location: location
  properties: {
    enableIPForwarding: true
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig-untrust'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip[1].id
          }
          subnet: {
            id: subnet1Ref
          }
        }
      }
    ]
  }
  dependsOn: [
    pip
  ]
}
resource nicName_2 'Microsoft.Network/networkInterfaces@2017-10-01' = {
  name: '${nicName}2'
  location: location
  properties: {
    enableIPForwarding: true
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig-trust'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet2Ref
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'BackendPool1')
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    pip
    trustedLB
  ]
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageName
  location: storageLocation
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

param loadBalancerName string

resource trustedLB 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties: {
          subnet: {
            id: subnet2Ref
          }
          privateIPAddress: '172.22.241.6'
          privateIPAllocationMethod: 'Static'
        }
        name: 'LoadBalancerFrontend'
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, 'LoadBalancerFrontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'BackendPool1')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'lbprobe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
        }
        name: 'lbrule'
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
        name: 'lbprobe'
      }
    ]
  }
  dependsOn: [
    virtualNetworkName_resource
  ]
}

resource availabilitySetName_resource 'Microsoft.Compute/availabilitySets@2018-06-01' = if (availabilitySetName != 'None') {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
  sku: {
    name: 'aligned'
  }
  dependsOn: [
    virtualNetworkName_resource
  ]
}
resource vmName_resource 'Microsoft.Compute/virtualMachines@2018-06-01' = {
  name: vmName
  location: location
  plan: {
    name: imageSku
    product: imageOffer
    publisher: imagePublisher
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
      customData: ((bootstrap == 'no') ? null : base64(customData))
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicName_0.id
          properties: {
            primary: true
          }
        }
        {
          id: nicName_1.id
          properties: {
            primary: false
          }
        }
        {
          id: nicName_2.id
          properties: {
            primary: false
          }
        }
      ]
    }
    availabilitySet: ((availabilitySetName == 'None') ? null : availabilitySet)
  }
  zones: ((zone == 'None') ? null : zones)
  dependsOn: [
    pip
    virtualNetworkName_resource
    nsgMgmt
  ]
}

output adminUsername string = adminUsername

