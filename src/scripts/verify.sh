#!/bin/bash

echo DF_API_KEY="${API_KEY}" >> "${BASH_ENV}"

if [[ -z "$DF_API_KEY" ]]; then
    echo "DF_API_KEY environment variable missing"
    exit 1
fi

if [[ -z "$DF_PORTAL_URL" ]]; then 
    echo "Param \"portal-url\" is missing"
    exit 1
fi

if [[ -z "$DF_APP" ]]; then
    echo "Param \"app\" is missing"
    exit 1
fi

if [[ -z "$DF_COMPONENT" ]]; then
    echo "Param \"component\" is missing"
    exit 1
fi

# check the portal url is valid
curl -kfs "${DF_PORTAL_URL}/api/health" > /dev/null
status="$?"
if [[ "$status" != "0" ]]; then
   echo "The param DeepFactor portal_url is incorrect or is not reachable"
   exit 1
fi

mkdir /tmp/report

# Get application
application_id=$( curl -ks -X GET "${DF_PORTAL_URL}/api/services/v1/applications" \
                    -H "Authorization: Bearer ${DF_API_KEY}" | \
                    jq -r --arg v "${DF_APP}" '.data.apps[] | select (.name==$v) | .application_id' )

echo "application_id=${application_id}"

# Get components
component_version_tuple=$( curl -ks -X GET \
                            "${DF_PORTAL_URL}/api/services/v1/applications/${application_id}/components" \
                            -H "Authorization: Bearer ${DF_API_KEY}" | \
                            jq -r --arg c "${DF_COMPONENT}" \
                            '.data.components[] | select (.name==$c) | {component_id,latest_component_version,security}')

component_id=$( jq -r '.component_id' <<< "$component_version_tuple" )
echo "component_id=${component_id}"

component_security_summary=$( jq -r '.security' <<< "$component_version_tuple")

summary=$(jq -r '{ total: .total, p1: .p1, p2: .p2, p3: .p3, p4: .p4 }' <<< "$component_security_summary")
cat <<< "$summary" > /tmp/report/deepfactor_summary.json

alert_details=$(curl -ks -X GET "${DF_PORTAL_URL}/api/services/v1/alerts?application_id=${application_id}&component_id=${component_id}&version_type=latest" \
                    -H "Authorization: Bearer ${DF_API_KEY}" \
                    | jq -r --arg portal "${DF_PORTAL_URL}" \
                    '[.data.alerts[] | {alertType: .alertType, severity: .severity, title: .title ,dfa: .dfa, link: ($portal + "/alerts/" + .dfa)}]' )

cat <<< "$alert_details" > /tmp/report/deepfactor_alert_list.json

wget http://df-ci-assets-test1.s3-website-us-west-2.amazonaws.com/index.html -O /tmp/report/index.html

echo "${DF_FAIL_SEVERITY}"
if [ "${DF_FAIL_SEVERITY}" != 'disabled' ]; then
  p1=$( jq '.p1' < /tmp/report/deepfactor_summary.json )
  if [[ ${DF_FAIL_SEVERITY} == 'p1' ]] && [[ "$p1" -gt 0 ]]; then
    echo 'DeepFactor detected alerts above threshold P1. Failing build'
    exit 1
  fi
  p2=$( jq '.p2' < /tmp/report/deepfactor_summary.json )
  if [[ "${DF_FAIL_SEVERITY}" == 'p2' ]] && [[ "$p2" -gt 0 || "$p1" -gt 0 ]]; then
    echo 'DeepFactor detected alerts above threshold P2. Failing build'
    exit 1
  fi
  p3=$( jq '.p3' < /tmp/report/deepfactor_summary.json )
  if [[ "${DF_FAIL_SEVERITY}" == 'p3' ]] && [[ "$p3" -gt 0 ||  "$p2" -gt 0 ||  "$p1" -gt 0 ]]; then
    echo 'DeepFactor detected alerts above threshold P3. Failing build'
    exit 1
  fi
fi
