#!/bin/bash

# Elasticsearch host and port
ES_HOST="http://elasticsearch:9200"

# Function to create index with mapping
create_index() {
  INDEX_NAME=$1
  MAPPING_FILE=$2

  if curl --silent --fail -XHEAD "$ES_HOST/$INDEX_NAME"; then
    echo "Index $INDEX_NAME already exists"
  else
    echo "Creating index $INDEX_NAME"
    curl -X PUT "$ES_HOST/$INDEX_NAME" -H 'Content-Type: application/json' -d @"$MAPPING_FILE"
  fi
}

# Wait for Elasticsearch to start
until curl --silent "$ES_HOST" >/dev/null; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

# Create indices with their mappings
create_index "btcu" "/usr/share/elasticsearch/mappings/btcu.json"

# Add additional indices as needed
#create_index "other_index" "/usr/share/elasticsearch/mappings/other_mapping.json"
