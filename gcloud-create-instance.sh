
#! /bin/bash

while getopts p:n option
do
case "${option}"
in
p) PROJ=${OPTARG};;
n) NAME=${OPTARG};;
esac
done

gcloud compute --project "$PROJ" \
	instances create $NAME \
	--zone "southamerica-east1-b" \
	--machine-type "n1-standard-4" \
	--image-project debian-cloud \
	--image-family "debian-9" \
	--create-disk "size=50GB" \
	--deletion-protection \
	--metadata-from-file startup-script="gcloud_install.sh"
