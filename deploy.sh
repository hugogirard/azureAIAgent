#!/bin/bash

LOCATION=$(grep -E '^param location' ./infra/main.bicepparam | awk -F"'" '{print $2}')

#echo $LOCATION

az deployment sub create \
  --location "$LOCATION" \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam \
  --debug