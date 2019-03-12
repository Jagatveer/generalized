#!/bin/bash

if [ "$PARAM_STORE" == "true" ]; then
  cd paramstore/
  npm i

  echo 'Retrieving parameters from Parameter Store:'
  nodejs ssm_get_secrets.js 'ssm_vars' /${NAMESPACE}/${DEPLOYMENT_ENVIRONMENT}/${SERVICE_NAME} ${AWS_DEFAULT_REGION}

  if [ -f ssm_vars ]; then
      echo 'Exporting parameters as environment variables:'
      source ssm_vars
  fi
  cd ..
fi

# Concat positional parameters
cmd=""
while [ "$1" != "" ]; do
    cmd="$cmd $1"
    shift
done

echo "Starting service: $cmd"
$cmd
