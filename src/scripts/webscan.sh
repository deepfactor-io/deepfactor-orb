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
    echo "Param \"app-name\" is missing"
    exit 1
fi

if [[ -z "$DF_COMPONENT" ]]; then
    echo "Param \"component-name\" is missing"
    exit 1
fi

# check the portal url is valid
curl -kfs "${DF_PORTAL_URL}/api/health" > /dev/null
status="$?"
if [[ "$status" != "0" ]]; then
   echo "The param DeepFactor portal_url is incorrect or is not reachable"
   exit 1
fi

if [[ -z "$DF_SCAN_CONFIG_TYPE" ]]; then
    echo "Param \"scan-type\" is missing"
    exit 1
fi

if [[ -z "$DF_SCAN_CONFIG_STRENGTH" ]]; then 
    echo "Param \"scan-strength\" is missing"
    exit 1
fi

if [[ -z "$DF_SCAN_CONFIG_AUTH_TYPE" ]]; then
    echo "Param \"scan-auth-type\" is missing"
    exit 1
fi

if [[ -z "$DF_SCAN_CONFIG_SCAN_URL" ]]; then
    echo "Param \"scan-url\" is missing"
    exit 1
fi 

if [[ -z "$DF_COMPONENT_VERSION" ]]; then
    DF_COMPONENT_VERSION="${CIRCLE_BUILD_NUM}"
fi
echo "compVersion:${DF_COMPONENT_VERSION} circleciBuild:${CIRCLE_BUILD_NUM}"

SCAN_HOST=$( echo "$DF_SCAN_CONFIG_SCAN_URL" | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/' )

generate_start_scan_request()
{
    cat <<EOF
{
    "application_name":"$DF_APP",
    "component_name":"$DF_COMPONENT",
    "component_version":"$DF_COMPONENT_VERSION",
    "scan_config":
    {
        "scan_type":"$DF_SCAN_CONFIG_TYPE",
        "active_scan_policy_strength":"$DF_SCAN_CONFIG_STRENGTH",
        "auth_type":"$DF_SCAN_CONFIG_AUTH_TYPE",
        "external_scan_url":"$DF_SCAN_CONFIG_SCAN_URL",
        "host":"$SCAN_HOST"
    }
}
EOF

}

status=$( curl -ks -X POST --data \
            "$(generate_start_scan_request)" \
            --write-out '%{http_code}' \
            --output /dev/null \
            "${DF_PORTAL_URL}/api/services/v1/webservices/scans" \
            -H "Authorization: Bearer ${DF_API_KEY}" )
if [ "$status" != 200 ]; then
    exit 1
fi