#!/bin/bash

PROJECT_ID="anthos-lab-339504"
gcloud config set project ${PROJECT_ID}

# enable services / APIs
gcloud services enable \
	anthos.googleapis.com \
	anthosgke.googleapis.com \
	anthosaudit.googleapis.com \
	cloudresourcemanager.googleapis.com \
	container.googleapis.com \
	gkeconnect.googleapis.com \
	gkehub.googleapis.com \
	opsconfigmonitoring.googleapis.com \
	serviceusage.googleapis.com \
	stackdriver.googleapis.com \
	monitoring.googleapis.com \
	logging.googleapis.com

