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
#   - we are not adding interactive terminal. CTL-C will not kill app when we do
#     not add this (with -it option) which can be confusing and seem buggy
##
docker run \
  --rm \
  -e RAILS_ENV=production \
  -p 3000:3000 \
  --name md5_prod \
  -d \
  md5_book:latest # name of image we built above

echo "App successfully started!"
echo "You can access it on your local machine by going to http://localhost:3000/ in your browser"