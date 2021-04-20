#!/bin/bash

echo

if [ "`id -u`" -ne "0" ]; then
	echo
	echo "Must run script with su"
	echo
	exit
fi

PILLAR_FILE=search.sls
PILLAR=/opt/so/saltstack/local/pillar/logstash/$PILLAR_FILE
PIPELINE_DIR=/opt/so/saltstack/local/salt/logstash/pipelines/config/custom
PIPELINE_FILE=DVM.conf

echo "Checking to see if $PIPELINE_FILE exits..."
if [ -f $PIPELINE_FILE ]; then
	echo " - Found $PIPELINE_FILE."
else
	echo " - Missing $PIPELINE_FILE.  Does it exist in the current directory?"
	exit
fi


echo "Checking SecurityOnion Layout..."
if [ -f $PILLAR ]; then
	echo " - Found Pillar file $PILLAR."
else
	echo " - Missing Pillar file $PILLAR. Is this the right version of SecurityOnion?"
	exit
fi
if [ -d $PIPELINE_DIR ]; then
	echo " - Found Pipeline directory $PIPELINE_DIR."
else
	echo " - Missing PIPELINE directory $PIPELINE_DIR. Is this the right version of SecurityOnion?"
	exit
fi

NEW_INSTALL=0
echo "Checking if this integration has been installed before..."
if [ -f $PIPELINE_DIR/$PIPELINE_FILE ]; then
	echo " - Found $PIPELINE_DIR/$PIPELINE_FILE. Existing installation."
else
	echo " - Looks like we have not installed here before."
	NEW_INSTALL=1
fi

PIPELINE_MATCH=0
echo "Checking to see if this version of $PIPELINE_FILE is already installed..."
diff $PIPELINE_FILE $PIPELINE_DIR/$PIPELINE_FILE > /dev/null
if [ $? -eq 0 ]; then
	echo " - $PIPELINE_DIR/$PIPELINE_FILE. Is already current."
	PIPELINE_MATCH=1
else
	echo " - $PIPELINE_DIR/$PIPELINE_FILE. Does not match the current file."
fi

PIPELINE_CONFIGURED=0
echo "Checking to see if $PILLAR is already configured with $PIPELINE_FILE..."
grep DVM.conf $PILLAR > /dev/null
if [ $? -eq 0 ]; then
	echo " - $PILLAR is already configured."
	PIPELINE_CONFIGURED=1
else
	echo " - $PILLAR is not yet confgiured."
fi

echo
echo
echo "Found the following..."
echo

if [ $NEW_INSTALL -eq 1 ]; then
	echo " - New Installation"
else
	echo " - Existing Installation"
fi

if [ $NEW_INSTALL -eq 1 ] && [ $PIPELINE_CONFIGURED -eq 1 ]; then
	echo " - Something is wrong with this installation.  Looks partially configured..."
	echo " - $PIPELINE_DIR/$PIPELINE_FILE does not exist but is configured in $PILLAR."
	echo
	exit
fi

if [ $PIPELINE_CONFIGURED -eq 1 ] && [ $PIPELINE_MATCH -eq 1 ]; then
	echo " - This version of $PIPELINE_FILE is already installed and configured."
	echo " - Nothing to do. exiting."
	echo
	exit
fi

echo
echo "The following actions will be taken:"
if [ $PIPELINE_CONFIGURED -eq 0 ]; then
	echo " - Modify the existing $PILLAR file."
fi
if [ $NEW_INSTALL -eq 0 ]; then
	echo " - Replace the $PIPELINE_FILE in $PIPELINE_DIR with the one here."
else
	echo " - Install the $PIPELINE_FILE into $PIPELINE_DIR."
fi

echo
echo
while true; do
	read -p "are you sure you want to continue (y/n)? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo;echo;exit;;
		* ) "Pease answer y/n.";;
	esac
done

echo

BACKUP_END=`date +%Y%m%d-%H%M%S`
if [ ! -d backup ]; then
	echo "Setting up for backup..."
	echo " - Creating backup directory"
	mkdir backup
fi

if [ $PIPELINE_CONFIGURED -eq 0 ]; then
	echo " - copying $PILLAR to backup"
	PILLAR_BACKUP=backup/$PILLAR_FILE.backup-$BACKUP_END
	cp $PILLAR $PILLAR_BACKUP
	echo " - Modifying $PILLAR"
	sed -e "/^.*_input_.*$/a\        - custom/DVM.conf" $PILLAR_BACKUP > $PILLAR
fi

if [ $PIPELINE_MATCH -eq 0 ] && [ $NEW_INSTALL -eq 0 ]; then
	echo " - Replacing $PIPELINE_FILE"
	cp $PIPELINE_FILE $PIPELINE_DIR
	chown socore:socore $PIPELINE_DIR/$PIPELINE_FILE
	chmod 644 $PIPELINE_DIR/$PIPELINE_FILE
fi

if [ $NEW_INSTALL -eq 1 ];then
	echo " - Installing $PIPELINE_FILE"
	cp $PIPELINE_FILE $PIPELINE_DIR
	chown socore:socore $PIPELINE_DIR/$PIPELINE_FILE
	chmod 644 $PIPELINE_DIR/$PIPELINE_FILE
fi 

echo
echo
echo "Remeber you need to restart logstash to ensure changes take effect."
echo " - use \"sudo so-logstash-restart\" to restart logstash"
echo " - Check /opt/so/log/logstash/logstash.log to ensure there are no errors"
echo
echo " completed."
echo


