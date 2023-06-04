#!/bin/bash

PDF_FILE_PATH=$1

docker exec md5_prod rake "pdf:create_embeddings[$PDF_FILE_PATH]"