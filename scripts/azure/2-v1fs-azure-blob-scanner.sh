#!/bin/bash

# Function to download a file from a given URL
download_file() {
    local url=$1
    local output_file=$2
    echo "Downloading file from URL: $url"
    if curl -o "$output_file" "$url"; then
        echo "File downloaded successfully as $output_file"
    else
        echo "Failed to download file."
        exit 1
    fi
}

# Function to upload a file to an Azure Blob container
upload_to_azure_blob() {
    local file_path=$1
    local container_name=$2
    local blob_name=$3
    echo "Uploading file to Azure Blob container '$container_name' with blob name '$blob_name'"
    if az storage blob upload --account-name "$account_name" --container-name "$container_name" --name "$blob_name" --file "$file_path" --auth-mode key; then
        echo "File uploaded successfully."
    else
        echo "Failed to upload file to Azure Blob Storage."
        exit 1
    fi
}

# Function to retrieve tags of an Azure Blob
get_blob_tags() {
    local container_name=$1
    local blob_name=$2
    echo "Fetching tags for blob '$blob_name' in container '$container_name'"
    tags=$(az storage blob tag list --account-name "$account_name" --container-name "$container_name" --name "$blob_name" --auth-mode key --output json)
    if [ $? -eq 0 ]; then
        echo "Tags for the blob: $tags"
    else
        echo "Failed to fetch tags for the blob."
        exit 1
    fi
}

# Main script logic
echo "Enter your Azure Storage Account Name:"
read -r account_name

echo "Enter the Azure Storage Container Name:"
read -r container_name

echo "Enter the source file URL:"
read -r file_url

# Extract the file name from the URL
file_name=$(basename "$file_url")

# Step 1: Download the file
download_file "$file_url" "$file_name"

# Step 2: Upload the file to Azure Blob Storage
upload_to_azure_blob "$file_name" "$container_name" "$file_name"

# Step 3: Wait for 25 seconds
echo "Waiting for 25 seconds before checking tags..."
sleep 25

# Step 4: Retrieve and display Azure Blob tags
get_blob_tags "$container_name" "$file_name"

# Step 5: Clean up the local file
if [ -f "$file_name" ]; then
    rm "$file_name"
    echo "Local file '$file_name' removed after upload."
fi
