#!/usr/bin/env bash

git fetch --depth 50 origin main:main

pwd=$(pwd) # save initial workingdir
error=0
# If the current branch is main, run a full check
if [ "$CI_COMMIT_REF_NAME" = "$CI_DEFAULT_BRANCH " ];then
  echo "INFO - Running on $CI_COMMIT_REF_NAME branch. Check all files."
  terraform fmt --recursive -check 1> /dev/null

  # terraform fmt --check returns non-zero code if the file is not formatted properly
  if [ $? -ne 0 ];then
    echo "ERROR - There are not properly formatted files."
    error=1
  fi
# If the current branch is not main, check only updated files
else
  # Get all the files which were updated in this branch.
  updatedFiles=$(git diff --diff-filter=AMR --name-only "origin/main..origin/$CI_COMMIT_REF_NAME")
  if [ $? -ne 0 ];then
    echo "ERROR - Failed to get the list of updated files."
    exit 1
  fi

  for file in $updatedFiles;do
    # if the file is a terraform file check the formatting
    if [[ "$file" == *.tf && -f "$file" ]];then
      # Run the formatter and check the return code
      terraform fmt -check "$file" 1> /dev/null
      if [ $? -ne 0 ];then
        echo "ERROR - File $file is not properly formatted."
        # Add the unformatted file to a list
        error=1
      fi
    fi
  done
fi
# Check if there was an error
if [ "$error" -ne 0 ];then
  # Loop over unformatted files and print a command to format them
  echo "INFO - Please format the terraform files properly."
  echo "INFO - Run terraform fmt -recursive to fix this issue"
  exit 1
fi
echo "INFO - all terraform files are properly formatted. Cheers."
