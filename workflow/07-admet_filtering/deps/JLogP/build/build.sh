#!/bin/bash

# Building JLogP
if [ -d ../lib ]; then
    if [ -d lib ]; then
        cp -r ../lib/*.jar lib/
    else
        cp -r ../lib .        
    fi 
fi


find ../src/jlogp/ -name *.java > javafiles.txt
javac -cp lib/cdk-2.3.jar @javafiles.txt -encoding utf-8 -d .

if [ "$?" != "0" ]; then
    rm javafiles.txt
	echo "Failed to create JLogP.jar."
    exit -1
fi

rm javafiles.txt


echo "Manifest-Version: 1.0" > manifest.mf
echo "Main-Class: jlogp.JLogP" >> manifest.mf
echo "Class-Path: lib/cdk-2.3.jar" >> manifest.mf
echo >> manifest.mf

jar cvfm JLogP.jar manifest.mf jlogp 

if [ "$?" = "0" ]; then
    rm -rf manifest.mf JLogP
else
	echo "Failed to create JLogP.jar."
    exit -1
fi

echo "--------------------- Done building JLogP.jar ---------------------"
