cd ./modules/data_warehouse

echo "Fetching Project ID"
PROJECT_ID=$(gcloud config get project)
echo "Project ID is ${PROJECT_ID}"

echo -n "Provide the region (e.g. us-central1) where the top level deployment resources were created for the deployment: "
read REGION

echo "Fetching deployment name"
DEPLOYMENT_NAME=$(gcloud infra-manager deployments list --location ${REGION} --filter="labels.goog-solutions-console-deployment-name:* AND labels.goog-solutions-console-solution-id:data-warehouse" | sed -n 's/NAME: \(.*\)/\1/p')
echo "Deployment name is ${DEPLOYMENT_NAME}"

SERVICE_ACCOUNT=$(gcloud infra-manager deployments describe ${DEPLOYMENT_NAME} --location ${REGION} | sed -n 's/serviceAccount:.*\/\(.*\)@.*/\1/p')

echo -n "The deployment currently uses ${SERVICE_ACCOUNT} service account. If you want to use any other service account, please specify the name. Else, press enter to skip: "
read NEW_SERVICE_ACCOUNT

if [ -n "$NEW_SERVICE_ACCOUNT" ]; then
    SERVICE_ACCOUNT=${NEW_SERVICE_ACCOUNT}
fi

echo "Assigning required roles to the service account ${SERVICE_ACCOUNT}"
while IFS= read -r role || [[ -n "$role" ]]
do \
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="$role"
done < "roles.txt"

sed -i '/^resource "google_storage_bucket" "raw_bucket" {/,/^}/ s/labels = var.labels/labels = { data-warehouse = "true", make-it-mine = "true" }/' main.tf

echo -e "Labels for the 'google_storage_bucket' named 'raw_bucket' in the './main.tf' file have been updated to the following instead of reading from 'var.labels'. You can modify their values\n{
  \"data-warehouse\": \"true\",
  \"make-it-mine\": \"true\"
}"

read -p "Once done, press Enter to continue..."

cat <<EOF > input.tfvars
region="us-central1"
zone="us-central1-a"
project_id = "${PROJECT_ID}"
deployment_name = "${DEPLOYMENT_NAME}"
labels = {
  "goog-solutions-console-deployment-name" = "${DEPLOYMENT_NAME}",
  "goog-solutions-console-solution-id" = "data-warehouse"
}
EOF

echo "An input.tfvars has been created with a set of sample input terraform variables for the solution. You can modify their values."
read -p "Once done, press Enter to continue..."

echo "Deploying the solution"
gcloud infra-manager deployments apply projects/${PROJECT_ID}/locations/${REGION}/deployments/${DEPLOYMENT_NAME} --service-account projects/${PROJECT_ID}/serviceAccounts/${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com --local-source="." --inputs-file=./input.tfvars --labels="modification-reason=make-it-mine,goog-solutions-console-deployment-name=${DEPLOYMENT_NAME},goog-solutions-console-solution-id=data-warehouse,goog-config-partner=sc"
