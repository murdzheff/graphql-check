JS_FILE="./getgraph.sh"
OLD_FILE="./old_number.txt"
INTERVAL=60
FLAG=1
RETRY_INTERVAL=600 # 10 minutes in seconds

# Check if DOMAIN is set
if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN is not set. Please define DOMAIN."
  exit 1
fi

swaks-send() {
  local subject="$1"
  local body="$2"
  swaks --to admins_sofia@"$DOMAIN" \
    --from admins_sofia@"$DOMAIN" \
    --server smtp."$DOMAIN" \
    --port 587 \
    --tls \
    --header "Subject: $subject" \
    --body "$body"
}

while true; do
  current_hour=$(date +"%-H")

  if nc -z ledger-digitalid.oncustomer.com 443; then
    echo "Connection successful, proceeding with script execution."
    if [ "$FLAG" -eq 0 ]; then
      swaks-send "Ledger server is up" "Ledger server Up"
    fi

    OUTPUT=$(bash "$JS_FILE")
    echo -e "\n$(date "+%T")\n$OUTPUT\n" >>log.txt
    FLAG=1
    out=$(echo "$OUTPUT")

    if [[ "$current_hour" -ge 8 && "$current_hour" -le 23 ]]; then
      if [[ "$out" == "true" ]]; then
        swaks-send "New Dossier for Ledger" "A new dossier arrived, please review!"
      elif [[ "$out" == "false" ]]; then
        echo "There are no new cases..."
      else
        swaks-send "Ledger server failure - New cookie needed!" "Please generate a new cookie and restart the container with -e COOKIE=<NEW COOKIE>!"
      fi
    fi

  else
    swaks-send "Ledger server failure!" "Connection failed, retrying in 10 minutes."
    FLAG=0
    sleep "$RETRY_INTERVAL"
    continue
  fi

  sleep "$INTERVAL"
done
