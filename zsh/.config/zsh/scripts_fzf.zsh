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


# ─── Ofload deployments ──────────────────────────────────────────────

# Reusable fzf git-branch picker. Prints the chosen branch name to stdout
# (the origin/ prefix is stripped) so it can be used inline, e.g.
#   gh workflow run ... --ref "$(_fzf_git_branch ~/path/to/repo)"
# Reads branches from the given repo dir (default: current dir) via `git -C`,
# so it works no matter where you run it from.
# Returns non-zero when the dir isn't a git repo; prints nothing on cancel.
_fzf_git_branch() {
  local repo=${1:-.}
  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository: $repo" >&2
    return 1
  }

  git -C "$repo" branch --all --sort=-committerdate --format='%(refname:short)' \
    | grep -vE '^origin/HEAD' \
    | fzf \
      --height=40% \
      --min-height=12 \
      --margin=5%,2%,2%,5% \
      --border=rounded \
      --info=inline \
      --ansi \
      --header="Choose branch — ${repo:t}" \
      --preview="git -C '$repo' log --oneline --graph --color=always --decorate -20 {}" \
      --preview-window='right,60%,border-left,wrap' \
    | sed 's#^origin/##'
}

# Defined as aliases (not functions) so they can be expanded in-place with
# `_expand_alias` (Ctrl-X Ctrl-A) into a multiline command you can edit before
# running — tweak the flags or the developer/environment value, then hit enter.
# The branch picker in $(...) only runs when the line is executed.
alias deploy-frontend='gh workflow run deploy-developer-env-new.yml \
	--repo=Ofload-2-0/ofload-frontend \
	--ref "$(_fzf_git_branch ~/ofload/ofload-frontend)" \
	-f developer=sijmen \
	-f skiptests=true \
	-f skipInfra=true'

alias deploy-shipment='gh workflow run deploy-dev.yml \
	--repo=Ofload-2-0/shipment-api \
	--ref "$(_fzf_git_branch ~/ofload/shipment-api)" \
	-f environment=sijmen'

alias deploy-eos='gh workflow run z_deploy-dev-new.yml \
	--repo=Ofload-2-0/ofload_site \
	--ref "$(_fzf_git_branch ~/ofload/ofload_site)" \
	-f developer_environment=sijmen'
