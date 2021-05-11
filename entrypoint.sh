#!/bin/sh

set -x

: "${SMTP_RELAY:=}"
: "${CRONJOB_MAILTO:=}"
: "${CRONJOB_SENDER:="$(id -un)@$(hostname -f)"}"

if [ -n "${SMTP_RELAY}" ] && [ -n "${CRONJOB_MAILTO}" ]; then
    /usr/bin/node index.js 2>&1 | \
        mailx -E \
            -S "smtp=smtp://${SMTP_RELAY}" \
            -S hostname="$(hostname -f)" \
            -S sender="${CRONJOB_SENDER}" \
            -s "[CRON] SSU Scraper" \
            "${CRONJOB_MAILTO}"

    exit_code=$?
    rm -f "${HOME}/dead.letter"
    exit "${exit_code}"
else
    exec /usr/bin/node index.js
fi
