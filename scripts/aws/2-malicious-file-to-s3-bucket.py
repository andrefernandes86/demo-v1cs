import boto3
import requests
import os
import time

def download_file(url, local_filename):
    """
    Download a file from a URL and save it locally.
    """
    try:
        print(f"Downloading file from URL: {url}")
        response = requests.get(url, stream=True)
        response.raise_for_status()
        with open(local_filename, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"File downloaded successfully as {local_filename}")
    except requests.exceptions.RequestException as e:
        print(f"Error downloading file: {e}")
        raise

def upload_to_s3(local_file, bucket_name, s3_key):
    """
    Upload a file to an S3 bucket.
    """
    try:
        print(f"Uploading file to S3 bucket '{bucket_name}' with key '{s3_key}'")
        s3 = boto3.client('s3')
        s3.upload_file(local_file, bucket_name, s3_key)
        print("File uploaded successfully.")
    except Exception as e:
        print(f"Error uploading file to S3: {e}")
        raise

def get_s3_object_tags(bucket_name, s3_key):
    """
    Retrieve the tags of an S3 object.
    """
    try:
        print(f"Fetching tags for object '{s3_key}' in bucket '{bucket_name}'")
        s3 = boto3.client('s3')
        response = s3.get_object_tagging(Bucket=bucket_name, Key=s3_key)
        tags = response.get("TagSet", [])
        if tags:
            print(f"Tags for the object: {tags}")
        else:
            print("No tags found for the object.")
    except Exception as e:
        print(f"Error fetching tags for the object: {e}")
        raise

def main():
    """
    Main function to handle input and execute file transfer.
    """
    try:
        # Input destination S3 bucket and source URL
        bucket_name = input("Enter the destination S3 bucket name: ").strip()
        file_url = input("Enter the source file URL: ").strip()

        # Generate a local file name from the URL
        local_file = file_url.split("/")[-1]

        # Download the file from the URL
        download_file(file_url, local_file)

        # Upload the file to S3
        upload_to_s3(local_file, bucket_name, local_file)

        # Wait for 25 seconds
        print("Waiting for 25 seconds before checking tags...")
        time.sleep(25)

        # Check the tags of the uploaded file
        get_s3_object_tags(bucket_name, local_file)

        # Cleanup local file
        if os.path.exists(local_file):
            os.remove(local_file)
            print(f"Local file '{local_file}' removed after upload.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
