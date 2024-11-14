#!/bin/bash

if [ -z "$COOKIE" ]; then
  echo "Error: COOKIE environment variable is not set."
  exit 1
fi

url="https://ledger-digitalid.oncustomer.com/internal/graphql/"

# GraphQL query as JSON
data='{
  "query": "{
    dossierLocatorQuery(
      filters: [],
      phase: [],
      status: [],
      assigned: \"roleFilter\",
      order: \"id desc\",
      start: 0,
      length: 25
    ) {
      total
      filtered
      resultSet {
        id
        timestamp
        creationTimestamp
        dossierNumber
        workflowTreeLabel
        dossierTemplate {
          name
        }
        mainParticipant {
          personPersonNameFullName
          personPersonNameName
          personPersonNameMiddleName
          personPersonNameSurname1
          personPersonNameSurname2
        }
        treeType {
          treelevel1
          treelevel2
          treelevel3
          treelevel4
        }
      }
    }
  }"
}'

# Send request with curl
response=$(curl -s -X POST "$url" \
  -H "Content-Type: application/json" \
  -H "Cookie: $COOKIE" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" \
  -H "Accept: */*" \
  -H "Accept-Language: en-US,en;q=0.5" \
  -d "$data")

# Check for "VALIDATION" in workflowTreeLabel
if echo "$response" | grep -q '"workflowTreeLabel":"[^"]*VALIDATION'; then
  echo "true"
else
  echo "false"
fi
