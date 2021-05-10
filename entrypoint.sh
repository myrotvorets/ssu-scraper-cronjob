#!/bin/sh

set -x

: "${SMTP_RELAY:=}"
: "${CRONJOB_MAILTO:=}"

if [ -n "${SMTP_RELAY}" ] && [ -n "${CRONJOB_MAILTO}" ]; then
    /usr/bin/node index.js | mailx -E -S "smtp=smtp://${SMTP_RELAY}" -s "[CRON] SSU Scraper" "${CRONJOB_MAILTO}"
    exit_code=$?
    rm -f "${HOME}/dead.letter"
    exit "${exit_code}"
else
    exec /usr/bin/node index.js
fi
