#!/usr/bin/env zsh

# Place for custom scripts
function dumpeos() {
  echo 'Start database dump eos';

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
    "service=eos" \
     > eos-db-$(date +%Y-%m-%d-%H%M).sql  

    echo "Saved dump to eos-db-$(date +%Y-%m-%d-%H%M).sql";
}

function longlines() {
  local all=0 agent=0 warn_flag=0 err_flag=0
  for arg in "$@"; do
    case "$arg" in
      -a|--all)               all=1 ;;
      -w|--warning)           warn_flag=1 ;;
      -e|--error)             err_flag=1 ;;
      --agent|--no-color)     agent=1 ;;
      -h|--help)
        echo "Usage: longlines [options]"
        echo ""
        echo "Reports lines exceeding 110 characters in the diff against main."
        echo ""
        echo "Options:"
        echo "  -a, --all        Check all PHP files in app/, database/, tests/, config/, routes/"
        echo "  -w, --warning    Show only warnings (111–120 chars)"
        echo "  -e, --error      Show only errors (121+ chars)"
        echo "  --agent          Omit ANSI colours and append the line length after W/E"
        echo "  --no-color       Alias for --agent"
        echo "  -h, --help       Show this help message"
        return 0 ;;
    esac
  done

  # If neither filter flag is set, show both; if one or both are set, show only flagged
  local show_warn show_err
  if (( warn_flag || err_flag )); then
    show_warn=$warn_flag; show_err=$err_flag
  else
    show_warn=1; show_err=1
  fi

  local _flush='
    BEGIN {
      LIMIT = 110  # maximum allowed line length
      WARN  = 10   # chars over LIMIT before escalating from warning to error
      # chars (LIMIT+1)..(LIMIT+WARN): W — warning zone (yellow text in color mode)
      # chars (LIMIT+WARN+1)+:         E — error zone   (red text in color mode)
    }
    function flushFile(    i, maxw, name, is_warn, severity, linelen, any) {
      if (nfindings == 0) return
      any = 0
      for (i = 1; i <= nfindings; i++) {
        is_warn = (length(buf_post[i]) <= WARN)
        if ((is_warn && show_warn) || (!is_warn && show_err)) { any = 1; break }
      }
      if (!any) { delete buf_line; delete buf_pre; delete buf_post; nfindings = 0; return }
      if (any_printed) printf "\n"
      any_printed = 1
      name = prevfile; sub(/^\.\//, "", name)
      printf "%s\n", name
      maxw = length("" buf_line[nfindings])
      for (i = 1; i <= nfindings; i++) {
        is_warn = (length(buf_post[i]) <= WARN)
        if (is_warn && !show_warn) continue
        if (!is_warn && !show_err) continue
        shown++
        severity = is_warn ? "W" : "E"
        if (agent) {
          linelen = length(buf_pre[i]) + length(buf_post[i])
          printf ":%*d: %s %d %s%s\n", maxw, buf_line[i], severity, linelen, buf_pre[i], buf_post[i]
        } else if (is_warn) {
          printf ":%*d: %s %s\033[33m%s\033[0m\n", maxw, buf_line[i], severity, buf_pre[i], buf_post[i]
        } else {
          printf ":%*d: %s %s\033[33m%s\033[31m%s\033[0m\n", maxw, buf_line[i], severity, buf_pre[i], substr(buf_post[i],1,WARN), substr(buf_post[i],WARN+1)
        }
      }
      delete buf_line; delete buf_pre; delete buf_post
      nfindings = 0
    }
  '

  local gawk_args=(-v show_warn=$show_warn -v show_err=$show_err -v agent=$agent)

  if (( all )); then
    find app database tests config routes -name "*.php" 2>/dev/null | sort | xargs gawk "${gawk_args[@]}" "$_flush"'
      FILENAME != prevfile { flushFile(); prevfile = FILENAME }
      length($0) > LIMIT {
        nfindings++
        buf_line[nfindings] = FNR
        buf_pre[nfindings]  = substr($0, 1, LIMIT)
        buf_post[nfindings] = substr($0, LIMIT+1)
      }
      END { flushFile(); if (shown == 0) print "No lines exceed " LIMIT " characters." }
    '
  else
    git diff main | gawk "${gawk_args[@]}" "$_flush"'
      /^diff --git / { match($0, /w\/(.+)$/, arr); file = arr[1] }
      /^\+\+\+/ { next }
      /^@@/ { match($0, /\+([0-9]+)/, arr); line = arr[1] + 0; next }
      /^\+/ {
        if (length($0) - 1 > LIMIT) {
          if (file != prevfile) { flushFile(); prevfile = file }
          content = substr($0, 2)
          nfindings++
          buf_line[nfindings] = line
          buf_pre[nfindings]  = substr(content, 1, LIMIT)
          buf_post[nfindings] = substr(content, LIMIT+1)
        }
        line++; next
      }
      /^ / { line++ }
      END { flushFile(); if (shown == 0) print "No lines exceed " LIMIT " characters." }
    '
  fi
}
