#!/usr/bin/env bash
set -eo pipefail
# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

ENV=$1
TAG=$2
PROVIDER=$3
COUNTER_LIMIT=20
if [[ -z "$ENV" ]] ; then
        echo "Environment should be set on startup with one of the below values"
        echo "ENV must be one of - DEV, QA, PROD or LOCAL"
        exit
fi

# source buildvar.conf

AWS_REGION=$(eval "echo \$${ENV}_AWS_REGION")
AWS_ACCESS_KEY_ID=$(eval "echo \$${ENV}_AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(eval "echo \$${ENV}_AWS_SECRET_ACCESS_KEY")
AWS_ACCOUNT_ID=$(eval "echo \$${ENV}_AWS_ACCOUNT_ID")
AWS_REPOSITORY=$(eval "echo \$${ENV}_AWS_REPOSITORY")
AWS_ECS_CLUSTER=$(eval "echo \$${ENV}_AWS_ECS_CLUSTER")
AWS_ECS_SERVICE=$(eval "echo \$${ENV}_AWS_ECS_SERVICE")

KAFKA_CLIENT_CERT=$(eval "echo \$${ENV}_KAFKA_CLIENT_CERT")
KAFKA_CLIENT_CERT_KEY=$(eval "echo \$${ENV}_KAFKA_CLIENT_CERT_KEY")
KAFKA_GROUP_ID=$(eval "echo \$${ENV}_KAFKA_GROUP_ID")
KAFKA_TOPIC_IGNORE_PREFIX=$(eval "echo \$${ENV}_KAFKA_TOPIC_IGNORE_PREFIX")
KAFKA_URL=$(eval "echo \$${ENV}_KAFKA_URL")
AUTHSECRET=$(eval "echo \$${ENV}_AUTHSECRET")
VALIDISSUERS=$(eval "echo \$${ENV}_VALIDISSUERS")
TC_API_BASE_URL=$(eval "echo \$${ENV}_TC_API_BASE_URL")
LOG_LEVEL=$(eval "echo \$${ENV}_LOG_LEVEL")
PORT=$(eval "echo \$${ENV}_PORT")

# email notifications config
ENABLE_EMAILS=$(eval "echo \$${ENV}_ENABLE_EMAILS")
MENTION_EMAIL=$(eval "echo \$${ENV}_MENTION_EMAIL")
REPLY_EMAIL_PREFIX=$(eval "echo \$${ENV}_REPLY_EMAIL_PREFIX")
REPLY_EMAIL_DOMAIN=$(eval "echo \$${ENV}_REPLY_EMAIL_DOMAIN")
ENABLE_DEV_MODE=$(eval "echo \$${ENV}_ENABLE_DEV_MODE")
DEV_MODE_EMAIL=$(eval "echo \$${ENV}_DEV_MODE_EMAIL")

TC_API_V3_BASE_URL=$(eval "echo \$${ENV}_TC_API_V3_BASE_URL")
TC_API_V4_BASE_URL=$(eval "echo \$${ENV}_TC_API_V4_BASE_URL")
TC_API_V5_BASE_URL=$(eval "echo \$${ENV}_TC_API_V5_BASE_URL")
MESSAGE_API_BASE_URL=$(eval "echo \$${ENV}_MESSAGE_API_BASE_URL")

DB_USER=$(eval "echo \$${ENV}_DB_USER")
DB_PASSWORD=$(eval "echo \$${ENV}_DB_PASSWORD")
DB_HOST=$(eval "echo \$${ENV}_DB_HOST")
DB_PORT=$(eval "echo \$${ENV}_DB_PORT")
DB_DATABASE=$(eval "echo \$${ENV}_DB_DATABASE")
DATABASE_URL=postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE;

family=$(eval "echo \$${ENV}_AWS_ECS_TASK_FAMILY")
echo "family--- " $family
AWS_ECS_CONTAINER_NAME=$(eval "echo \$${ENV}_AWS_ECS_CONTAINER_NAME")

API_CONTEXT_PATH=$(eval "echo \$${ENV}_API_CONTEXT_PATH")

AUTH0_URL=$(eval "echo \$${ENV}_AUTH0_URL")
AUTH0_AUDIENCE=$(eval "echo \$${ENV}_AUTH0_AUDIENCE")
TOKEN_CACHE_TIME=$(eval "echo \$${ENV}_TOKEN_CACHE_TIME")
AUTH0_CLIENT_ID=$(eval "echo \$${ENV}_AUTH0_CLIENT_ID")
AUTH0_CLIENT_SECRET=$(eval "echo \$${ENV}_AUTH0_CLIENT_SECRET")

echo $APP_NAME
task_template=`cat container.template`
task_def=$(printf "$task_template" $AWS_ECS_CONTAINER_NAME $AWS_ACCOUNT_ID $AWS_REGION $AWS_REPOSITORY $TAG $ENV "$KAFKA_CLIENT_CERT" "$KAFKA_CLIENT_CERT_KEY" $KAFKA_GROUP_ID "$KAFKA_TOPIC_IGNORE_PREFIX" $KAFKA_URL $DATABASE_URL $AUTHSECRET $TC_API_BASE_URL $TC_API_V3_BASE_URL $TC_API_V4_BASE_URL $TC_API_V5_BASE_URL $MESSAGE_API_BASE_URL $ENABLE_EMAILS $MENTION_EMAIL $REPLY_EMAIL_PREFIX $REPLY_EMAIL_DOMAIN $ENABLE_DEV_MODE $DEV_MODE_EMAIL $LOG_LEVEL "$VALIDISSUERS" $PORT "$API_CONTEXT_PATH" "$AUTH0_URL" "$AUTH0_AUDIENCE" $AUTH0_CLIENT_ID "$AUTH0_CLIENT_SECRET" $TOKEN_CACHE_TIME $AWS_ECS_CLUSTER $AWS_REGION $AWS_ECS_CLUSTER $ENV)
echo $task_def