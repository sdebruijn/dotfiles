# Custom fzf scripts

choose_aws_profile() {
  # Extract profile names from the AWS config file
  selected_profile=$(
    sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config \
    | fzf \
    --height=20% \
    --min-height=12 \
    --margin=5%,2%,2%,5% \
    --border=rounded \
    --info=inline \
    --header="Choose AWS profile" \
  )
  export AWS_PROFILE=$selected_profile
  echo "Set AWS profile to '$selected_profile'"
}
alias awsprofile='choose_aws_profile'


function dbdump() {
  PG_SERVICE_CONF="$HOME/.pg_service.conf"

  if [[ ! -f "$PG_SERVICE_CONF" ]]; then
    echo "File $PG_SERVICE_CONF not found!" >&2
    exit 1
  fi

  # Extract service names (lines starting with [)
  SERVICE=$(grep -E '^\[.*\]' "$PG_SERVICE_CONF" | tr -d '[]' |
    fzf \
    --height=20% \
    --min-height=12 \
    --margin=5%,2%,2%,5% \
    --border=rounded \
    --info=inline \
    --header="Choose database" \
  )
  if [[ -z "$SERVICE" ]]; then
    echo "No service selected." >&2
    exit 1
  fi

  echo "Start database dump of $SERVICE";

  pg_dump \
    --no-owner \
    --no-acl \
    --column-inserts \
    --data-only \
    --exclude-table='*_id_seq' \
    --exclude-table-data='*_id_seq' \
    --exclude-table=migrations \
    --exclude-table=api_clients \
    --exclude-table=failed_jobs \
    --exclude-table=ledgers \
    --exclude-table=msg_directions \
    "service=$SERVICE" \
     > $SERVICE-db-$(date +%Y-%m-%d-%H%M).sql  

    echo "Saved dump to $SERVICE-db-$(date +%Y-%m-%d-%H%M).sql";
}
