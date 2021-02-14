#!/bin/bash

if [ -z ${RH_SSO_FQDN} ]; then
	echo "Environment variable RH_SSO_FQDN undefined"
	exit 1
elif [[ -z $CLIENT_ID ]]; then
	echo "Environment variable CLIENT_ID undefined"
	exit 1
elif [[ -z $CLIENT_SECRET ]]; then
	echo "Environment variable CLIENT_SECRET undefined"
	exit 1
elif [[ -z $REVERSE_SSO_ROUTE ]]; then
	echo "Environment variable REVERSE_SSO_ROUTE undefined"
	exit 1
elif [[ -z ${DST_SERVICE_NAME} ]]; then
	echo "Environment variable DST_SERVICE_NAME undefined"
	exit 1
elif [[ -z $RH_SSO_REALM ]]; then
	echo "Environment variable RH_SSO_REALM undefined"
	exit 1
elif [[ -z ${DST_SERVICE_PORT} ]]; then
	echo "Environment variable DST_SERVICE_PORT undefined"
	exit 1
fi


echo "
<VirtualHost *:8080>
        OIDCProviderMetadataURL https://${RH_SSO_FQDN}/auth/realms/${RH_SSO_REALM}/.well-known/openid-configuration
        OIDCClientID $CLIENT_ID
        OIDCClientSecret $CLIENT_SECRET
        OIDCRedirectURI https://${REVERSE_SSO_ROUTE}/oauth2callback
		OIDCCryptoPassphrase openshift

		<Directory "/opt/app-root/">
	   		AllowOverride All
		</Directory>

        <Location />
	        AuthType openid-connect
    	    Require valid-user
			ProxyPreserveHost on
			ProxyPass	http://${DST_SERVICE_NAME}:${DST_SERVICE_PORT}/
			ProxyPassReverse	http://${DST_SERVICE_NAME}:${DST_SERVICE_PORT}/
        </Location>
</VirtualHost>
" > /tmp/reverse.conf

#sed -i "s/RH_SSO_URL/${RH_SSO_URL}/g" /tmp/reverse.conf
#sed -i "s/CLIENT_ID/${CLIENT_ID}/g" /tmp/reverse.conf
#sed -i "s/CLIENT_SECRET/${CLIENT_SECRET}/g" /tmp/reverse.conf
#sed -i "s/REVERSE_SSO_ROUTE/${REVERSE_SSO_ROUTE}/g" /tmp/reverse.conf

mv /tmp/reverse.conf /opt/app-root/reverse.conf


/usr/sbin/httpd $OPTIONS -DFOREGROUND
