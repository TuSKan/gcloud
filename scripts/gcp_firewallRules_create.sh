
#! /bin/bash

while getopts p: option
do
case "${option}"
in
p) PROJ=${OPTARG};;
esac
done

gcloud compute \
	--project=$PROJECT_ID \
	firewall-rules create allow-rstudio \
	--direction=INGRESS \
	--priority=1000 \
	--network=default \
	--action=ALLOW \
	--rules=tcp:8787 \
	--source-ranges=0.0.0.0/32 \
	--target-tags="rstudio"

gcloud compute \
	--project=$PROJECT_ID \
	firewall-rules create allow-jupyter \
	--direction=INGRESS \
	--priority=1000 \
	--network=default \
	--action=ALLOW \
	--rules=tcp:8888 \
	--source-ranges=0.0.0.0/32 \
	--target-tags="jupyter"

gcloud compute \
	--project=$PROJECT_ID \
	firewall-rules create allow-shiny \
	--direction=INGRESS \
	--priority=1000 \
	--network=default \
	--action=ALLOW \
	--rules=tcp:3838 \
	--source-ranges=0.0.0.0/32 \
	--target-tags="shiny"

gcloud compute \
	--project=$PROJECT_ID \
	firewall-rules create allow-mlserver \
	--direction=INGRESS \
	--priority=1000 \
	--network=default \
	--action=ALLOW \
	--rules=tcp:5000 \
	--source-ranges=0.0.0.0/32 \
	--target-tags="mlserver"