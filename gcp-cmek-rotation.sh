#!/bin/bash

# Variables
PROJECT_ID="YOUR_PROJECT_ID"
KEYRING="test"
KEY="quickstart"
LATEST_KEY_VERSION=$(gcloud kms keys versions list --project=$PROJECT_ID --key=$KEY --keyring=$KEYRING --format="value(name)" --location "global" | tail -n1)
RUNNING_VMS=$(gcloud compute instances list --project=$PROJECT_ID --format="table(name,zone,status)" --filter="status=RUNNING" | head | tail -n +2)

# Loop through running VMs
echo "$RUNNING_VMS" | while IFS= read -r line; do
    VM_NAME=$(echo $line | awk '{print $1}')
    ZONE=$(echo $line | awk '{print $2}')
    
    # Get Disks on VM
    DISKS=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format="value(disks.source)")
    # Loop through disks on running VMs
    echo "$DISKS" | while IFS= read -r disk; do
        # Get Key Version on Disk
        CURRENT_KEY_VERSION=$(gcloud compute disks describe $disk --zone=$ZONE --project=$PROJECT_ID --format="value(diskEncryptionKey.kmsKeyName)")
        # Check if reencryption is necessary
         if [ "$LATEST_KEY_VERSION" != "$CURRENT_KEY_VERSION" ]; then
             echo "Reencryption needed for VM: $VM_NAME, Disk: $disk"
            
             # Perform reencryption or any other actions needed
             # For example, stop the VM, take a snapshot, create a new disk with the latest key version, attach the new disk, and start the VM.
             gcloud compute instances stop $VM_NAME --zone=$ZONE --project=$PROJECT_ID
             SNAPSHOT_NAME="rotation-key-snapshot-$(date +"%Y%m%d%H%M%S")"
             gcloud compute disks snapshot $disk --snapshot-names=$SNAPSHOT_NAME --zone=$ZONE --project=$PROJECT_ID
             NEW_DISK_NAME="new-disk-$(date +"%Y%m%d%H%M%S")"
             BOOT_DISK_SIZE=$(gcloud compute disks describe $disk --zone=$ZONE --project=$PROJECT_ID --format="value(sizeGb)")
             gcloud compute disks create $NEW_DISK_NAME --source-snapshot=$SNAPSHOT_NAME --kms-key=projects/$PROJECT_ID/locations/global/keyRings/$KEYRING/cryptoKeys/$KEY --size=$BOOT_DISK_SIZE --zone=$ZONE --project=$PROJECT_ID
             gcloud compute instances detach-disk $VM_NAME --disk=$disk --zone=$ZONE --project=$PROJECT_ID
             gcloud compute instances attach-disk $VM_NAME --disk=$NEW_DISK_NAME --zone=$ZONE --project=$PROJECT_ID --boot
             gcloud compute instances start $VM_NAME --zone=$ZONE --project=$PROJECT_ID

             echo "Reencryption completed for VM: $VM_NAME, Disk: $disk"
         else
             echo "Reencryption not needed for VM: $VM_NAME, Disk: $disk"
         fi
    done
done


