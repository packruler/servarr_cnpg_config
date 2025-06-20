#!/bin/ash

set -e

SECRET_PATH="/run/secrets/cnpg"
echo "Updating config.xml with secrets in ${SECRET_PATH}"

if [ "${VERBOSE}" == "true" ]; then
  echo "Current config.xml:"
  cat /config/config.xml
  
  stat /config/config.xml
fi

RESULT=$(xmlstarlet ed \
  -u '/Config/PostgresPassword' \
  -v "$(cat ${SECRET_PATH}/password)" \
  -u '/Config/PostgresUser' \
  -v "$(cat ${SECRET_PATH}/username)" \
  -u '/Config/PostgresHost' \
  -v "$(cat ${SECRET_PATH}/host)" \
  -u '/Config/PostgresPort' \
  -v "$(cat ${SECRET_PATH}/port)" \
  -u '/Config/PostgresMainDb' \
  -v "$(cat ${SECRET_PATH}/dbname)" \
  /config/config.xml)

if [[ $? -ne 0 || -z "$RESULT" ]]; then
  echo "Failed to update config.xml"
  exit 1
fi

echo "${RESULT}" >/config/config.xml
echo "Config updated successfully."

if [ "${VERBOSE}" == "true" ]; then
  echo "Updated config.xml:"
  cat /config/config.xml
fi
