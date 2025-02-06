#!/bin/bash

USER="user"
PASS="pass"
URL="https://base_url/rest/API/content/pageid?expand=body.storage"

# Retrieve JSON response
response=$(curl -s -u "${USER}:${PASS}" -X GET \
         -H "Content-Type: application/json" "${URL}")

# Print every match starting with "CRHPCDR"
echo "${response}" | grep -o 'CRHPCDR[^"]*'