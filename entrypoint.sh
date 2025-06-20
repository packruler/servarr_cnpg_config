#!/bin/ash

set -e

SECRET_PATH="/run/secrets/cnpg"
echo "Updating config.xml with secrets in ${SECRET_PATH}"

xmlstarlet ed \
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
   /config/config.xml > /config/config.xml

echo "Config updated successfully."
