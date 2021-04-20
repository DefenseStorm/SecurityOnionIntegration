#!/bin/bash

if [ "`id -u`" -ne "0" ]; then
	echo
	echo "Must run script with su"
	echo
	exit
fi

PILLAR=/opt/so/saltstack/local/pillar/logstash/search.sls
PIPELINE_DIR=/opt/so/saltstack/local/salt/logstash/pipelines/config/custom
PIPELINE_FILE=DVM.conf

echo "Checking to see if $PIPELINE_FILE exits..."
if [ -f $PIPELINE_FILE ]; then
	echo "Found $PIPELINE_FILE."
else
	echo "Missing $PIPELINE_FILE.  Does it exist in the current directory?"
	exit
fi


echo "Checking SecurityOnion Layout..."
if [ -f $PILLAR ]; then
	echo "Found Pillar file $PILLAR."
else
	echo "Missing Pillar file $PILLAR. Is this the right version of SecurityOnion?"
	exit
fi
if [ -d $PIPELINE_DIR ]; then
	echo "Found Pipeline directory $PIPELINE_DIR."
else
	echo "Missing PIPELINE directory $PIPELINE_DIR. Is this the right version of SecurityOnion?"
	exit
fi

NEW_INSTALL=0
echo "Checking if this integration has been installed before..."
if [ -f $PIPELINE_DIR/$PIPELINE_FILE ]; then
	echo "Found $PIPELINE_DIR/$PIPELINE_FILE. Existing installation."
	NEW_INSTALL=1
else
	echo "Looks like we have not installed here before."
fi

PIPELINE_MATCH=0
echo "Checking to see if this version of $PIPELINE_FILE is already installed..."
diff $PIPELINE_FILE $PIPELINE_DIR/$PIPELINE_FILE > /dev/null
if [ $? -eq 0 ]; then
	echo "$PIPELINE_DIR/$PIPELINE_FILE. Is already current."
	PIPELINE_MATCH=1
else
	echo "$PIPELINE_DIR/$PIPELINE_FILE. Does not match the current file."
fi

PIPELINE_CONFIGURED=0
echo "Checking to see if $PILLAR is already configured with $PIPELINE_FILE..."
grep DVM.conf $PILLAR > /dev/null
if [ $? -eq 0 ]; 
	echo "$PILLAR is already configured."
	PIPELINE_CONFIGURED=1
else
	echo "$PILLAR is not yet confgiured."
fi







