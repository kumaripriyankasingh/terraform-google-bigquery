<walkthrough-metadata>
  <meta name="title" content="Edit Jumpstart Solution and deploy tutorial " />
   <meta name="description" content="Make it mine neos tutorial" />
  <meta name="component_id" content="1361081" />
  <meta name="unlisted" content="true" />
  <meta name="short_id" content="true" />
</walkthrough-metadata>

# Customize DataWarehouse With BigQuery Solution

This tutorial provides the steps for you to build your own proof of concept solution based on the chosen Jumpstart Solution and deploy it. You can customize the chosen Jump start solutions (JSS) deployments by creating your own copy of the source code. You can modify the infrastructure and application code as needed and redeploy the solutions with the changes.

Each solution should be edited and deployed by one user at a time to avoid conflicts.

## Know your solution

Here are the details of the DataWarehouse With BigQuery Jump Start Solution chosen by you.

Solution Guide: [here](https://cloud.google.com/solutions/data-warehouse)

The code for the solution is avaiable at the following location
* Infrastructure code is present as part of `./modules/data_warehouse/main.tf`
* Application code directory is located under `./modules/data_warehouse/src`

## Explore or Edit the solution as per your requirement

As an example, you can edit `main.tf` file in `./modules/data_warehouse/` to update labels for resource type: `google_storage_bucket` and name: `raw_bucket` like below

```
 labels = {
    data-warehouse = "true",
    make-it-mine   = "true"
  }
```

NOTE: The changes in infrastructure may lead to reduction or increase in the incurred cost.

Please note: to open your recently used workspace:
* Go to the `File` menu.
* Select `Open Recent Workspace`.
* Choose the desired workspace.

---
**Navigate to Data Warehouse module directory**

Use the following command to change the working directory to the `modules/data_warehouse`:
```bash
cd modules/data_warehouse
```

**Automated deployment**

Execute the below command if you want an automated deployment to happen without following the full tutorial.

The step is optional and you can continue with the full tutorial if you want to understand the individual steps involved in the script.

```bash
chmod +x ./deploy.sh
./deploy.sh
```


## Gather the required information for intializing gcloud command

In this step you will gather the information required for the deployment of the solution

---
**Project ID**

Use the following command to see the projectId:

```bash
gcloud config get project
```

```
Use above output to set the <var>PROJECT_ID</var>
```
---
**Deployment Region**

```
Provide the region (e.g. us-central1) where the top level deployment resources were created for the deployment <var>REGION</var>
```
---
**Deployment Name**

Run the following command to get the existing deployment name:
```bash
gcloud infra-manager deployments list --location <var>REGION</var> --filter="labels.goog-solutions-console-deployment-name:* AND labels.goog-solutions-console-solution-id:data-warehouse"
```

```
Use the NAME value of the above output to set the <var>DEPLOYMENT_NAME</var>
```


## Deploy the solution


---
**Fetch Deployment details**
```bash
gcloud infra-manager deployments describe <var>DEPLOYMENT_NAME</var> --location <var>REGION</var>
```
From the output of this command, note down the input values provided in the existing deployment in the `terraformBlueprint.inputValues` section.

Also note the serviceAccount from the output of this command. The value of this field is of the form 
```
projects/<var>PROJECT_ID</var>/serviceAccounts/<serice-account>@<var>PROJECT_ID</var>.iam.gserviceaccount.com
```

```
Note <service-account> part and set the <var>SERVICE_ACCOUNT</var> value.
You can also set it to any exising service account.
```

---
**Assign the required roles to the service account**
```bash
while IFS= read -r role || [[ -n "$role" ]]
do \
gcloud projects add-iam-policy-binding <var>PROJECT_ID</var> \
  --member="serviceAccount:<var>SERVICE_ACCOUNT</var>@<var>PROJECT_ID</var>.iam.gserviceaccount.com" \
  --role="$role"
done < "roles.txt"
```

---
**Create Terraform input file**

Create a file named `input.tfvars`.

Find the sample content below and modify it by providing the respective details.
```
delete_contents_on_destroy=True
region="us-central1"
project_id = "<var>PROJECT_ID</var>"
deployment_name = "<var>DEPLOYMENT_NAME</var>"
labels = {
  "goog-solutions-console-deployment-name" = "<var>DEPLOYMENT_NAME</var>",
  "goog-solutions-console-solution-id" = "data-warehouse"
}
```

---
**Deploy the solution**

Execute the following command to trigger the re-deployment. 
```bash
gcloud infra-manager deployments apply projects/<var>PROJECT_ID</var>/locations/<var>REGION</var>/deployments/<var>DEPLOYMENT_NAME</var> --service-account projects/<var>PROJECT_ID</var>/serviceAccounts/<var>SERVICE_ACCOUNT</var>@<var>PROJECT_ID</var>.iam.gserviceaccount.com --local-source="." --inputs-file=./input.tfvars --labels="modification-reason=make-it-mine,goog-solutions-console-deployment-name=<var>DEPLOYMENT_NAME</var>,goog-solutions-console-solution-id=data-warehouse,goog-config-partner=sc"
```

---
**Monitor the Deployment**

Execute the following command to get the deployment details.

```bash
gcloud infra-manager deployments describe <var>DEPLOYMENT_NAME</var> --location <var>REGION</var>
```

Monitor your deployment at [JSS deployment page](https://console.cloud.google.com/products/solutions/deployments?pageState=(%22deployments%22:(%22f%22:%22%255B%257B_22k_22_3A_22Labels_22_2C_22t_22_3A13_2C_22v_22_3A_22_5C_22modification-reason%2520_3A%2520make-it-mine_5C_22_22_2C_22s_22_3Atrue_2C_22i_22_3A_22deployment.labels_22%257D%255D%22))).

## Save your edits to the solution

Use any of the following methods to save your edits to the solution

---
**Download your solution in tar file**
* Click on the `File` menu
* Select `Download Workspace` to download the whole workspace on your local in compressed format.

---
**Save your solution to your git repository**

Set the remote url to your own repository
```bash 
git remote set-url origin [your-own-repo-url]
```

Review the modified files, commit and push to your remote repository branch.
<walkthrough-inline-feedback></walkthrough-inline-feedback>
  
