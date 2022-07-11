#!/bin/bash

currentVersion="0.0.1"

httpSingleUpload()
{
   response=$(curl -A curl -# --upload-file "$1" "https://transfer.sh/$2") || { echo "Failure!"; return 1;}
   printUploadResponse
}

printUploadResponse()
{
fileID=$(echo "$response" | cut -d "/" -f 4)
  cat <<EOF
Transfer File URL: $response
EOF
}

singleUpload()
{

  for i in $@
  do
    
    filePath=$(echo "$i" | sed 's/~/$HOME/g')

    if [ ! -e "$filePath" ]; then
    {
      echo "Error: invalid file path";
      return 1;
    };
    fi

    tempFileName=$(echo "$i" | sed "s/.*\///")

    echo "Uploading $tempFileName"

    httpSingleUpload "$filePath" "$tempFileName"
  done
}

singleDownload()
{
  filePath_d=$(echo "$1" | sed 's/\.\///g')
  echo "Downloading $3"
  response_d=$(curl -# --url "https://transfer.sh/$2/$3" --output "$filePath_d/$3")
  printDownloadResponse
}

printDownloadResponse()
{
  fileID=$(echo "$response" | cut -d "/" -f 4)
  cat <<EOF
Success!
EOF
}

while getopts 'dvh' OPTION; do
  case $OPTION in
    d)
        singleDownload "$2" "$3" "$4"
	exit 1
	;;		  
    v) 
      echo "$currentVersion"
      exit 1
      ;;
    h)
      echo " Description: Bash tool to transfer files from the command line. 
        Usage: 
        -d  Download file from https://transfer.sh/{particular folder} 
        -h  Show the help about attributes. Show examples 
	-v  Get the tool version 
    
        Examples: 
          ./transfer.sh test.txt 
	  
	  ./transfer.sh test.txt test2.txt ...
	  
	  ./transfer.sh -v

	  ./transfer.sh -h

      "
      exit 1
      ;; 
  esac 
done

singleUpload "$@" || exit 1
