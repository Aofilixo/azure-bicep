module resourceGroup 'br/public:avm/res/resources/resource-group:<version>' = {
  name: '${uniqueString(deployment().name, resourceLocation)}-test-rrgwaf'
  params: {
    // Required parameters
    name: 'avm-resources.resourcegroups-rrgwaf-rg'
    // Non-required parameters
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    tags: {
      Environment: 'dev'
      ESF_Program_ID: '4775998a-2656-39eb-9d5b-e1bd6582a544'
      ESF_Service_ID: 'a86fdb2f-9f62-38b8-9fa5-308558a975ec'
      dataclassification: 'n/a'
      foo: 'barbaz'
      assetuuid: '16b21411-9c8c-363c-9d31-12124a8b2063'
      environment: 'Non Production'
      ESF_Application: 'Azure Cloud Enablement Appl'
      ESF_Application_ID: '16b21411-9c8c-363c-9d31-12124a8b2063'
      ESF_Program: 'Builders Enablement Program'
      ESF_Service: 'Cloud as a Service'

      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
