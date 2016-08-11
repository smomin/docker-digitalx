#!/bin/sh
DIRECTORY="/opt/DigitalFactory-EnterpriseDistribution"

# Control will enter here if $DIRECTORY doesn't exist.
if [ ! -d "$DIRECTORY" ]; then
	java -jar "$DOWNLOADS/DigitalExperienceManager-EnterpriseDistribution-7.1.2.1-r54750.3813.jar" /jahia-install-mysql.xml
	cp -R $BUNDLES/* $DIRECTORY/digital-factory-data/modules/
fi
cd $DIRECTORY
/bin/sh start.sh