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

if [[ "$DF_SCAN_CONFIG_TYPE" == "owasp-zap-api" ]] && [[ -z "$DF_SCAN_API_DOCS_URL" ]]; then
    echo "Param \"scan-api-docs-url\" is required for the api scans"
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

if [[ -n "$DF_SCAN_CONFIG_AUTH_TYPE" ]] && [ "$DF_SCAN_CONFIG_AUTH_TYPE" == "form" ]; then
    if [[ -z "$DF_SCAN_AUTH_FORM_LOGIN_URI" ]] ||
       [[ -z "$DF_SCAN_AUTH_FORM_USERNAME" ]]  ||
       [[ -z "$DF_SCAN_AUTH_FORM_PASSWORD" ]]  ||
       [[ -z "$DF_SCAN_AUTH_FORM_DATA" ]]      ||
       [[ -z "$DF_SCAN_AUTH_FORM_LOGGEDIN" ]]  ||
       [[ -z "$DF_SCAN_AUTH_FORM_LOGGEDOUT" ]]; then
       echo "Parameters for Form Authentication missing"
       exit 1
    fi
fi

if [[ -n "$DF_SCAN_CONFIG_AUTH_TYPE" ]] && [ "$DF_SCAN_CONFIG_AUTH_TYPE" == "custom" ]; then
    if [[ -z "$DF_SCAN_AUTH_CUSTOM_TOKEN" ]]; then
       echo "Parameters \"scan-custom-token-auth\" missing for custom token authentication"
       exit 1
    fi
fi 

if [[ -z "$DF_SCAN_CONFIG_SCAN_URL" ]]; then
    echo "Param \"scan-url\" is missing"
    exit 1
fi 

if [[ -z "$DF_COMPONENT_VERSION" ]]; then
    DF_COMPONENT_VERSION="${CIRCLE_BUILD_NUM}"
fi
echo "compVersion:${DF_COMPONENT_VERSION} circleciBuild:${CIRCLE_BUILD_NUM}"

if [[ -z "$DF_SCAN_HOST" ]]; then
    SCAN_HOST=$( echo "$DF_SCAN_CONFIG_SCAN_URL" | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/' )
else
    SCAN_HOST=$DF_SCAN_HOST
fi

generate_start_scan_request()
{
    DF_AUTH_STRING=""
    case $DF_SCAN_CONFIG_AUTH_TYPE in 
        form)
            DF_AUTH_STRING=$(cat <<EOF
    "login_uri":"$DF_SCAN_AUTH_FORM_LOGIN_URI",
    "scan_user_name":"$DF_SCAN_AUTH_FORM_USERNAME",
    "scan_user_password":"$DF_SCAN_AUTH_FORM_PASSWORD",
    "logged_in_indicator":"$DF_SCAN_AUTH_FORM_LOGGEDIN",
    "logged_out_indicator":"$DF_SCAN_AUTH_FORM_LOGGEDOUT",
    "auth_type":"formBasedAuthentication",
EOF
)
            ;;
        custom)
            DF_AUTH_STRING=$(cat <<EOF 
            "custom_token":"$DF_SCAN_AUTH_CUSTOM_TOKEN",
            "auth_type":"custom",
EOF
)
            ;;
        *)
         DF_AUTH_STRING=$(cat <<EOF
         "auth_type":"none",
EOF
)
        ;;
    esac

    cat <<EOF
{
    "application_name":"$DF_APP",
    "component_name":"$DF_COMPONENT",
    "component_version":"$DF_COMPONENT_VERSION",
    "scan_config":
    {
        "scan_type":"$DF_SCAN_CONFIG_TYPE",
        "active_scan_policy_strength":"$DF_SCAN_CONFIG_STRENGTH",
        $DF_AUTH_STRING
        "external_scan_url":"$DF_SCAN_CONFIG_SCAN_URL",
        "api_scan_url":"$DF_SCAN_API_DOCS_URL",
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