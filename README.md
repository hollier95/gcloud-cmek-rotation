
# Automated Disk Reencryption Script for Virtual Machines

This Bash script automates the reencryption process for disks attached to running virtual machines within a Google Cloud project. Reencryption is carried out using Google Cloud Key Management Service (KMS) to ensure data security.

## Prerequisites

Before running this script, ensure you meet the following requirements:

1. **Google Cloud Environment**: Make sure you have an active project in the Google Cloud Platform (GCP) where the resources (virtual machines, disks, KMS keys, etc.) that the script will manage are located.

2. **Google Cloud SDK (gcloud)**: The script employs `gcloud` commands to interact with Google Cloud services. Make sure you have the [Google Cloud SDK](https://cloud.google.com/sdk) installed and have configured your account for access to the relevant project. You should be logged in to your Google Cloud account by running `gcloud auth login`.

3. **KMS Key and Version**: You should have already created a keyring and key in Google Cloud KMS. The names of the keyring and key should match the values specified in the script (`KEYRING` and `KEY`). Additionally, ensure that at least one version of this key exists.

4. **Running Virtual Machines**: The script is designed to manage the disks of running virtual machines. Make sure you have active virtual machines in your project.

## Script Details

The script uses the following variables to achieve its functionality:

- `PROJECT_ID`: The ID of your Google Cloud project.
- `KEYRING`: The name of the keyring in Google Cloud KMS where the encryption key is stored.
- `KEY`: The name of the encryption key to use for reencryption.
- `LATEST_KEY_VERSION`: The most recent version of the encryption key obtained from the KMS key versions list.
- `RUNNING_VMS`: A list of running virtual machines obtained using the `gcloud compute instances list` command.
- `VM_NAME`: A variable to store the name of the current virtual machine being processed.
- `ZONE`: The zone in which the current virtual machine is located.
- `DISKS`: A list of disks associated with the current virtual machine.
- `disk`: A variable to store the name of a specific disk in the inner loop iterating through disks.
- `CURRENT_KEY_VERSION`: The current encryption key version used for the disk being processed.

## Using the Script

1. Copy the script into a file with a `.sh` extension, e.g., `gcp-cmek-rotation.sh`.
2. Open a command line or terminal.
3. Make sure you're logged in to your Google Cloud account by running `gcloud auth login`.
4. Navigate to the directory where the script file is located.
5. Provide execution permission to the script using the following command:
   ```
   chmod +x gcp-cmek-rotation.sh
   ```
6. Run the script using the following command:
   ```
   ./gcp-cmek-rotation.sh
   ```

Ensure that you comprehend the actions that the script will execute on your resources. Customize the script to suit your specific needs before running it. Feel free to adjust the links and instructions to match your particular requirements and environment.
