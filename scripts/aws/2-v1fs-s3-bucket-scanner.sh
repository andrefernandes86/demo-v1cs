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

# Function to upload a file to an S3 bucket
upload_to_s3() {
    local file_path=$1
    local bucket_name=$2
    local s3_key=$3
    echo "Uploading file to S3 bucket '$bucket_name' with key '$s3_key'"
    if aws s3 cp "$file_path" "s3://$bucket_name/$s3_key"; then
        echo "File uploaded successfully."
    else
        echo "Failed to upload file to S3."
        exit 1
    fi
}

# Function to retrieve tags of an S3 object
get_s3_tags() {
    local bucket_name=$1
    local s3_key=$2
    echo "Fetching tags for object '$s3_key' in bucket '$bucket_name'"
    tags=$(aws s3api get-object-tagging --bucket "$bucket_name" --key "$s3_key" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Tags for the object: $tags"
    else
        echo "Failed to fetch tags for the object."
        exit 1
    fi
}

# Main script logic
echo "Enter the destination S3 bucket name:"
read -r bucket_name

echo "Enter the source file URL:"
read -r file_url

# Extract the file name from the URL
file_name=$(basename "$file_url")

# Step 1: Download the file
download_file "$file_url" "$file_name"

# Step 2: Upload the file to S3
upload_to_s3 "$file_name" "$bucket_name" "$file_name"

# Step 3: Wait for 25 seconds
echo "Waiting for 25 seconds before checking tags..."
sleep 25

# Step 4: Retrieve and display S3 tags
get_s3_tags "$bucket_name" "$file_name"

# Step 5: Clean up the local file
if [ -f "$file_name" ]; then
    rm "$file_name"
    echo "Local file '$file_name' removed after upload."
fi
