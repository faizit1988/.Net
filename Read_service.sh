#!/bin/bash

# Set the file path
file_path="/path/to/file"

# Loop through the file
while read -r service_name version; do
  # Do something with the values
  echo "Service name: $service_name, Version: $version"
done < "$file_path"
