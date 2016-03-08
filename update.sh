#!/bin/bash

echo -- BEGIN UPDATE DNS --
echo Date/Time: $(date +"%Y-%m-%d %T")

# Get configuration variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
domain_name=$(jq -r '.domainName' $DIR/config.json)
hosted_zone_id=$(jq -r '.hostedZoneId' $DIR/config.json)

# Request current IP from remote service
current_ip=$(curl -s https://api.ipify.org)

# Get last transmitted IP
old_ip=$(jq -r '{Changes}[][0].ResourceRecordSet.ResourceRecords[0].Value' $DIR/record-set.json)

echo Comparing current ip \($current_ip\) with old ip \($old_ip\)

# Compare the current IP with last transmitted IP
if [ "$old_ip" != "$current_ip" ]; then
  echo Result: IP has changed to $current_ip, updating DNS

  # Update the JSON data file if IP has changed
  cat <<EOF > $DIR/record-set.json
{
  "Comment": "Updates A record for rpi current external IP address",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$domain_name",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$current_ip"
          }
        ]
      }
    }
  ]
}
EOF

  # Make UPSERT request to AWS for domain name
  echo $(aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch file://$DIR/record-set.json)
else
  echo Result: IP address has not changed from $current_ip
fi

echo -- END UPDATE DNS --
