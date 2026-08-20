#!/bin/ash

set -eu

SECRET_PATH="${SECRET_PATH:-/run/secrets/cnpg}"
CONFIG_PATH="${CONFIG_PATH:-/config/config.xml}"

echo "Updating ${CONFIG_PATH} with secrets in ${SECRET_PATH}"

if [ ! -f "${CONFIG_PATH}" ]; then
  echo "No config file at ${CONFIG_PATH}"
  exit 1
fi

if [ "${VERBOSE:-}" = "true" ]; then
  echo "Current config.xml:"
  cat "${CONFIG_PATH}"

  stat "${CONFIG_PATH}"
fi

# Reads one key out of the mounted CNPG secret. Missing keys read as empty so
# that a secret without an optional key is not an error.
read_secret() {
  if [ -f "${SECRET_PATH}/$1" ]; then
    cat "${SECRET_PATH}/$1"
  fi
}

RESULT="$(cat "${CONFIG_PATH}")"

# Sets one <Config> child element, creating it when absent.
#
# `xmlstarlet ed -u` only rewrites elements that already exist -- against a
# config.xml that has never held a given element it silently does nothing. The
# servarr apps read these values with `persist: false`, so they never write
# them back either, and the app would quietly fall back to its compiled-in
# default. Creating the element when it is missing is what makes the value we
# were asked to set actually take effect.
set_value() {
  element="$1"
  value="$2"

  if [ -z "${value}" ]; then
    echo "  ${element}: no value in secret, leaving as-is"
    return 0
  fi

  if [ "$(printf '%s' "${RESULT}" | xmlstarlet sel -t -v "count(/Config/${element})" -)" = "0" ]; then
    RESULT="$(printf '%s' "${RESULT}" | xmlstarlet ed -s '/Config' -t elem -n "${element}" -v "${value}")"
    echo "  ${element}: created"
  else
    RESULT="$(printf '%s' "${RESULT}" | xmlstarlet ed -u "/Config/${element}" -v "${value}")"
    echo "  ${element}: updated"
  fi
}

DB_NAME="$(read_secret dbname)"

# The log database is not part of a CNPG-generated secret -- CNPG provisions a
# single database and names it in `dbname`. Servarr needs a second one, and
# defaults it to `<app>-log` when the element is absent. That default is the
# same for every instance of an app, so several servarr apps sharing one
# Postgres cluster would all target the same log database.
#
# Prefer an explicit `logdb` key when the secret carries one, so the database
# name is owned by whoever writes the secret rather than baked into this image.
# Otherwise derive it from the main database name.
LOG_DB_NAME="$(read_secret logdb)"
if [ -z "${LOG_DB_NAME}" ] && [ -n "${DB_NAME}" ]; then
  LOG_DB_NAME="${DB_NAME}_log"
fi

set_value PostgresPassword "$(read_secret password)"
set_value PostgresUser "$(read_secret username)"
set_value PostgresHost "$(read_secret host)"
set_value PostgresPort "$(read_secret port)"
set_value PostgresMainDb "${DB_NAME}"
set_value PostgresLogDb "${LOG_DB_NAME}"

if [ -z "${RESULT}" ]; then
  echo "Failed to update config.xml"
  exit 1
fi

if [ "${VERBOSE:-}" = "true" ]; then
  echo "Updated config.xml:"
  echo "${RESULT}"
fi

if [ "${DRY_RUN:-}" != "true" ]; then
  echo "${RESULT}" >"${CONFIG_PATH}"
  echo "Config updated successfully."
else
  echo "Dry run mode is on, not applying changes."
  exit 0
fi
