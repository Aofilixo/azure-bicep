# Get the current date in the format MM-dd-yyyy
date=$(date +%m-%d-%Y)

# Concatenate the deployment name with the current date
deploymentName="AzPaloDeployment$date"

# Deploy the resources using the Bicep file and parameter file
az deployment group create \
  --name "$deploymentName" \
  --resource-group rg-cloudcore-egress-vdi-eastus-sandbox \
  --template-file ./main.bicep \
  --parameters @main.parameters.json
