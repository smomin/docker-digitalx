#!/bin/sh
DIRECTORY="/opt/DigitalFactory-EnterpriseDistribution"
# loop until mysql connection is successful
while sleep 5 && ! mysql -hmysql -uroot -pjahia -e ";" ;
do
	echo "MySQL connection not found!"
done

# Check connection again
if mysql -hmysql -uroot -pjahia  -e ";" ; then
	# Control will enter here if $DIRECTORY doesn't exist.
	if [ ! -d "$DIRECTORY" ]; then
		
		# if directory does not exists, then mean DX is not installed. 
		java -jar "$DOWNLOADS/DigitalExperienceManager-EnterpriseDistribution-7.1.2.1-r54750.3813.jar" /jahia-install-mysql.xml
		cp -R $BUNDLES/* $DIRECTORY/digital-factory-data/modules/
		sed -i -e 's/#cluster.activated\s*=\s*false/cluster.activated = true/g' \
			-e 's/#processingServer\s*=\s*true/processingServer = true/g' \
			-e '$ a jahia.session.redis.host = redis' \
			-e '$ a jahia.session.redis.port = 6379' \
			-e '$ a jahia.session.redis.database = 0' \
			-e '$ a jahia.session.redis.timeout = 2000' \
			-e '$ a jahia.session.cookieName = JSESSIONID' \
			-e '$ a jahia.session.cookiePath = /' \
			-e '$ a jahia.session.cookieMaxAge = -1' \
			-e '$ a jahia.session.useHttpOnlyCookie = true' \
			-e '$ a jahia.session.jvmRoute = node1' \
			$DIRECTORY/digital-factory-config/jahia/jahia.node.properties
		
		sed -i -e ':a' -e 'N' -e '$!ba' -e 's/<context-param>\n\s*<description>Spring Expression Language Support<\/description>\n\s*<param-name>springJspExpressionSupport<\/param-name>\n\s*<param-value>false<\/param-value>\n\s*<\/context-param>/SUBSTITUTETHIS/g' \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
		sed -e '/SUBSTITUTETHIS/ {' -e 'r /distributed-session-filter.xml' -e 'd' -e '}' -i \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml

		sed -i -e ':a' -e 'N' -e '$!ba' -e 's/<filter-mapping>\n\s*<filter-name>CharacterEncodingFilter<\/filter-name>\n\s*<url-pattern>\/\*<\/url-pattern>\n\s*<\/filter-mapping>/SUBSTITUTETHIS/g' \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
		sed -e '/SUBSTITUTETHIS/ {' -e 'r /distributed-session-filter-mapping.xml' -e 'd' -e '}' -i \
			$DIRECTORY/tomcat/webapps/ROOT/WEB-INF/web.xml
	fi
	cd $DIRECTORY
	/bin/sh start.sh
fi		
