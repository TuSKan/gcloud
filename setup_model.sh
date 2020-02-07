#!/bin/bash

# Setup of new C6 Analytics project

# Parte do cloud build precisa ser manual ainda
#gcloud builds submit $PROJECT_NAME

# ALTERNATIVE 1

# TODO
# alterar variáveis 
# clone do remote como submodulo
#	gcloud source repos clone c6_analytics --project=c6-analytics-production
#

while getopts r: option
do
case "${option}"
in
r) REPO_NAME=${OPTARG};;
esac
done

REPO_PROJ="c6-analytics-production"
TEMPLATE_NAME="project_template"
TEMPLATE_PROJ="c6-analytics-production"

mkdir $REPO_NAME
cd $REPO_NAME

git init

git config --global credential.'https://source.developers.google.com'.helper gcloud.sh

git remote add template https://source.developers.google.com/p/$TEMPLATE_PROJ/r/$TEMPLATE_NAME

git pull template submodule

gcloud source repos create $REPO_NAME --project=$REPO_PROJ

git remote add origin https://source.developers.google.com/p/$REPO_PROJ/r/$REPO_NAME

git add -A
git commit -m 'The beginning...'
git push -u origin master



