#!/bin/bash

# build image from Dockerfile and tag as latest
docker build . -t md5_book:latest

##
# Start a container using the image with the following options:
#
# -rm removes container after it is stopped
# -e sets an environment variable to run the app in production
# -p binds port 3000 to container port 3000 so you can access app from your
#    local machine by going to localhost:3000
# --name specifies name for container which we can reference to stop it
#
# --detach run container in background. This works for prod because:
#   - we are not logging input/output in prod environment
#   - we are not adding interactive terminal (-it option). CTL-C will not kill 
#     app when we do not add this which can be confusing and seem buggy
#
# -v mount volume of sqlite database to have persistence if you need to stop/start
#    the container
##
ABSOLUTE_PATH_OF_MD5_APP=$(pwd | grep -o ".*md5_495cf3d15b6908f883e4993a14acb562")
docker run \
  --rm \
  -e RAILS_ENV=production \
  -p 3000:3000 \
  --name md5_prod \
  -d \
  -v $ABSOLUTE_PATH_OF_MD5_APP/db/production.sqlite3:/app/db/production.sqlite3 \
  md5_book:latest # name of image we built above

echo "App is booting up!"

# Ensure app has started before exiting script to prevent awkward minute where
# it looks like localhost:3000 is broken
start=0
appStarted=0
while [ $start -lt 15 ]; do
  httpCode=$(curl -s -o /dev/null -w "%{http_code}" localhost:3000)
  if [ $httpCode -eq 200 ]; then
    appStarted=1
    break
  fi
  start=$((start + 1))
  echo .
  sleep 10
done

if [ $appStarted -eq 1 ]; then
  echo "App has successfully booted!"
  echo "You can access it on your local machine by going to http://localhost:3000/ in your browser"
else
  echo "Something has gone wrong"
  docker logs md5_prod
fi