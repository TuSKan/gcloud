#! /bin/bash

while getopts p:n: option
do
case "${option}"
in
p) PROJ=${OPTARG};;
n) NAME=${OPTARG};;
esac
done

#--preemptible

gcloud compute --project $PROJ \
	instances create $NAME \
	--zone "southamerica-east1-b" \
 	--machine-type "n1-standard-4" \
 	--image-project debian-cloud \
 	--image-family "debian-9" \
 	--boot-disk-size "50GB" \
 	--deletion-protection \
	--tags "rstudio,jupyter,shiny,mlserver" \
 	--metadata-from-file startup-script="init_script.sh" \
	--scopes="bigquery,cloud-platform,cloud-source-repos,compute-rw,datastore,default,storage-full,sql-admin,userinfo-email,pubsub,service-control,service-management,taskqueue,trace,monitoring,logging-write"
