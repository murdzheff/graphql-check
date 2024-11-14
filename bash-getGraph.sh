JS_FILE="./getgraph.sh" OLD_FILE="./old_number.txt"
INTERVAL=60
FLAG=1
RETRY_INTERVAL=600 # 10 minutes in seconds

while true; do

  #proverka dali vremeto e mejdu 8 sutrinta i 1 prez noshta

  current_hour=$(date +"%-H")

  # proverka s netcat do saita i za chas

  if nc -z ledger-digitalid.oncustomer.com 443; then

    echo "Connection successful, proceeding with script execution."
    #ako mine, ama pri poslednata proverka e bil offline, prashta mail che sme obratno v igrata
    if [ "$FLAG" -eq 0 ]; then
      swaks --to admins_sofia@estiym.com \
        --from admins_sofia@estiym.com \
        --server smtp.estiym.com \
        --port 587 \
        --tls \
        --header "Subject: Ledger server Up" \
        --body "Ledger server is available again."

    fi

    # pravi zayavka do server-a za dosieta
    OUTPUT=$(bash $JS_FILE)
    echo "      " >>log.txt
    date "+%T" >>log.txt
    echo $OUTPUT >>log.txt
    echo "    " >>log.txt
    FLAG=1
    out=$(echo $OUTPUT)

    #ako ima novo dosie prashtame mail che ima dosie

    if [[ ("$current_hour" -gt 7 || "$current_hour" -lt 1) ]]; then
      if [[ "$out" == "true" ]]; then
        swaks --to admins_sofia@estiym.com \
          --from admins_sofia@estiym.com \
          --server smtp.estiym.com \
          --port 587 \
          --tls \
          --header "Subject: New Dossier for Ledger" \
          --body "A new dossier arrived, please review!"

      elif [[ "$out" == "false" ]]; then
        echo "There are no new cases..."
        #ako output-a ni e nqkakva javascript greshka znachi nai veroyatno cookie-to e zaminalo i trqbva da generirame novo
      else
        swaks --to admins_sofia@estiym.com \
          --from admins_sofia@estiym.com \
          --server smtp.estiym.com \
          --port 587 \
          --tls \
          --header "Subject: Ledger server failure - New cookie needed!" \
          --body "Please generate a new cookie and restart the container with -e COOKIE=<NEW COOKIE> !"

      fi
    fi
  else
    #ako netcat fail-ne da dostigne servera, piem edno kafe i probvame pak
    swaks --to admins_sofia@estiym.com \
      --from admins_sofia@estiym.com \
      --server smtp.estiym.com \
      --port 587 \
      --tls \
      --header "Subject: Ledger server failure!" \
      --body "Connection failed  retrying in 10 minutes."

    echo "Connection failed, retrying in 10 minutes." | mail -s "Ledger server failure" admins_sofia@estiym.com

    FLAG=0
    sleep $RETRY_INTERVAL
    continue
  fi

  # Wait for the specified interval before repeating the loop

  sleep $INTERVAL
done
