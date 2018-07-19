#!/bin/bash

echo "------------Begin------------"

message=$1
if [ ! -n "$1" ] ;then
message="modify"
fi

git add .
git commit -m $message
echo $message
git push

echo "-------------End-------------"

