#!/bin/bash

VAULT_ADDR=http://localhost:8200/v1/auth/approle
VAULT_TOKEN=<VAULT-TOKEN>
role_name="my-test"

keys=`curl --header "X-Vault-Token: ${VAULT_TOKEN}" --request LIST ${VAULT_ADDR}/role/rstudio-role/secret-id | jq '.data[]' | sed 's/[][]//g'`
echo ${keys}>payload.json

for key in ${keys};
do
	echo $key
	expiry_date=`curl --header "X-Vault-Token: ${VAULT_TOKEN}" --request POST --data '{ "secret_id_accessor": '${key}' }' http://localhost:8200/v1/auth/approle/role/${role_name}/secret-id-accessor/lookup | jq '.data.expiration_time'`
done

expiry_date=`date -d ${expiry_date} +%Y-%m-%d`
expiry_date=`date -d ${expiry_date} +%s`

today_date=`date -d 'Today' +%Y-%m-%d`
today_date=`date -d $today_date +%s`


if [ ${expiry_date} -ge ${today_date} ];
then
	echo "Token is valid".   #calculate nubmer of days and print the days left in token expiry
else
	curl --header "X-Vault-Token: ${VAULT_TOKEN}" --request POST http://localhost:8200/v1/auth/approle/role/${role_name}/secret-id
fi
