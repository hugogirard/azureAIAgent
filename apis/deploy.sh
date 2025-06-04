#!/bin/bash

RESOURCE_GROUP_NAME="$1"

if [[ -z "$RESOURCE_GROUP_NAME" ]]; then
  echo "Error: Resource group name parameter is required."
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

# Retrieve the API Management instance name in the resource group
APIM_NAME=$(az apim list --resource-group "$RESOURCE_GROUP_NAME" --query '[0].name' -o tsv)

if [[ -z "$APIM_NAME" ]]; then
  echo "Error: No API Management instance found in resource group '$RESOURCE_GROUP_NAME'."
  exit 1
fi

echo "API Management instance name: $APIM_NAME"

# List Cognitive Services accounts with kind 'AIServices' in the resource group
AISERVICES_ACCOUNT=$(az cognitiveservices account list -g "$RESOURCE_GROUP_NAME" --query "[?kind=='AIServices']" -o json)
echo "Cognitive Services accounts with kind 'AIServices':"
echo "$AISERVICES_ACCOUNT"

# Extract specific endpoints using jq from the variable
AI_FOUNDRY_API=$(echo "$AISERVICES_ACCOUNT" | jq -r '.[0].properties.endpoints["AI Foundry API"]')
OPENAI_LANGUAGE_MODEL_API=$(echo "$AISERVICES_ACCOUNT" | jq -r '.[0].properties.endpoints["OpenAI Language Model Instance API"]')

echo "AI Foundry API endpoint: $AI_FOUNDRY_API"
echo "OpenAI Language Model Instance API endpoint: $OPENAI_LANGUAGE_MODEL_API"

sed -e 's/__title__/GenAI Gateway Demo/' -e "s|__apimName__|$APIM_NAME|g" ./api/openapi.yaml > ./api/openapi.final.yaml

# az deployment group create \
#   --resource-group "$RESOURCE_GROUP_NAME" \
#   --template-file main.bicep \
#   --parameters apimName="$APIM_NAME" endpointFoundry="$AI_FOUNDRY_API"