#!/bin/sh
DIRECTORY="/opt/DigitalFactory-EnterpriseDistribution"

# Loop until mysql connection is successful
while sleep 5 && ! mysql -hmysql -uroot -pjahia -e ";" ;
do
	echo "MySQL connection not found!"
done

# If browsing then this node must be a second node in the cluster.  Wait til processing node is up before continuing with this node's setup.
if [ -n "$BROWSING" ]; then
  while [ $(curl --write-out %{http_code} --silent --output /dev/null http://node1:8080) != "200" -a $(curl --write-out %{http_code} --silent --output /dev/null http://node1:8080) != "401" ]
  do
    echo "DX connection not found!"
    sleep 15
  done
fi

# Check connection again
if mysql -hmysql -uroot -pjahia  -e ";" ; then
	# Control will enter here if $DIRECTORY doesn't exist.
	if [ ! -d "$DIRECTORY" ]; then

    # Check if node is Processing or Browsing to use the correct installation file.
		if [ -n "$BROWSING" ]; then
		  installFile="/jahia-install-mysql-browsing.xml"
		else
		  installFile="/jahia-install-mysql.xml"
		fi

		# if directory does not exists, then mean DX is not installed. 
		java -jar "$DOWNLOADS/DigitalExperienceManager-EnterpriseDistribution-7.1.2.1-r54750.3813.jar" $installFile
		cp -R $BUNDLES/* $DIRECTORY/digital-factory-data/modules/

    # Set a common directory for the generated resources.
    sed -i -e 's/#jahiaGeneratedResourcesDiskPath\s*=\s*\${jahia.data.dir}\/generated-resources/jahiaGeneratedResourcesDiskPath = \/opt\/generated-resources/g' \
			$DIRECTORY/digital-factory-config/jahia/jahia.properties

    if [ -n "$BROWSING" ]; then
      sed -i -e 's/#processingServer\s*=\s*true/processingServer = false/g' \
        $DIRECTORY/digital-factory-config/jahia/jahia.node.properties
     else
		  sed -i -e 's/#processingServer\s*=\s*true/processingServer = true/g' \
        $DIRECTORY/digital-factory-config/jahia/jahia.node.properties
		fi

		# Add in Distributed Session configuration
		sed -i -e '$ a jahia.session.redis.host = redis' \
			-e '$ a jahia.session.redis.port = 6379' \
			-e '$ a jahia.session.redis.database = 0' \
			-e '$ a jahia.session.redis.timeout = 2000' \
			-e '$ a jahia.session.cookieName = JSESSIONID' \
			-e '$ a jahia.session.cookiePath = /' \
			-e '$ a jahia.session.cookieMaxAge = -1' \
			-e '$ a jahia.session.useHttpOnlyCookie = true' \
			-e '$ a jahia.session.jvmRoute = node1' \
			$DIRECTORY/digital-factory-config/jahia/jahia.node.properties

		# Add filters for Distributed Sesssion
		sed -i -e ':a' -e 'N' -e '$!ba' -e 's/<context-param>\n\s*<description>Spring Expression Language Support<\/description>\n\s*<param-name>springJspExpressionSupport<\/param-name>\n\s*<param-value>false<\/param-value>\n\s*<\/context-param>/SUBSTITUTETHIS/g' \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
		sed -e '/SUBSTITUTETHIS/ {' -e 'r /distributed-session-filter.xml' -e 'd' -e '}' -i \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml

    # Add filter mappings for Distributed Sesssion
		sed -i -e ':a' -e 'N' -e '$!ba' -e 's/<filter-mapping>\n\s*<filter-name>CharacterEncodingFilter<\/filter-name>\n\s*<url-pattern>\/\*<\/url-pattern>\n\s*<\/filter-mapping>/SUBSTITUTETHIS/g' \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
		sed -e '/SUBSTITUTETHIS/ {' -e 'r /distributed-session-filter-mapping.xml' -e 'd' -e '}' -i \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
	fi
	cd $DIRECTORY
	/bin/sh start.sh
fi		
