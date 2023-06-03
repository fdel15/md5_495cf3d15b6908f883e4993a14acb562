# Stop container that was started from the boot_prod.sh script
# assumes --name was specified as md5_prod in that script
docker container stop md5_prod
echo "================================"
echo "Successfully stopped container md5_prod"
echo "================================"
echo "These are the docker containers currently running on your machine: "
echo "================================"

docker ps