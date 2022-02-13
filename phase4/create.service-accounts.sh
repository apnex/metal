#!/bin/bash

PROJECT_ID="anthos-lab-339504"
gcloud config set project ${PROJECT_ID}

## component-access permissions
### account
gcloud iam service-accounts create component-access-sa \
	--display-name "Component Access Service Account" \
	--project ${PROJECT_ID}
### key
gcloud iam service-accounts keys create component-access-key.json \
	--iam-account component-access-sa@${PROJECT_ID}.iam.gserviceaccount.com
### iam
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:component-access-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/serviceusage.serviceUsageViewer"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:component-access-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/iam.roleViewer"

## connect-register permissions
### account
gcloud iam service-accounts create connect-register-sa \
	--project ${PROJECT_ID}
### key
gcloud iam service-accounts keys create connect-register-key.json \
	--iam-account connect-register-sa@${PROJECT_ID}.iam.gserviceaccount.com
### iam
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:connect-register-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/gkehub.admin"

## logging-monitoring permissions
### account
gcloud iam service-accounts create logging-monitoring-sa \
	--project=${PROJECT_ID}
### key
gcloud iam service-accounts keys create logging-monitoring-key.json \
	--iam-account logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com
### iam
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/stackdriver.resourceMetadata.writer"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/opsconfigmonitoring.resourceMetadata.writer"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/logging.logWriter"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/monitoring.metricWriter"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
	--member "serviceAccount:logging-monitoring-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role "roles/monitoring.dashboardEditor"
