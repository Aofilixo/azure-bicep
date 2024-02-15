@description('Azure VM size for VM-Series')
@allowed([
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_DS5_v2'
])
param vmSize string = 'Standard_DS3_v2'

@description('PAN OS Version')
@allowed([
  '7.1.1'
  '8.0.0'
  '8.1.0'
  'latest'
])
param imageVersion string = 'latest'

@description('Firewall License Model')
@allowed([
  'byol'
  'bundle1'
  'bundle2'
])
param imageSku string = 'byol'
