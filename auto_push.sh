#!/bin/bash

echo "------------Begin------------"

message=$1
if [ ! -n "$1" ] ;then
message="modify"
fi

git add .
git commit -m "$message"
echo "commit message is $message"
git push

echo "-------------End-------------"

