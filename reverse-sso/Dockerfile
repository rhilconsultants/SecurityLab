FROM centos
MAINTAINER Oren Oichman <Back to Root>

RUN dnf install -y httpd && dnf module enable mod_auth_openidc -y && dnf install -y mod_auth_openidc && dnf clean all

COPY run-httpd.sh /usr/sbin/run-httpd.sh
COPY ca.crt /etc/pki/ca-trust/source/anchors/rh-sso.crt

RUN update-ca-trust extract
RUN echo "PidFile /tmp/http.pid" >> /etc/httpd/conf/httpd.conf
RUN sed -i "s/Listen\ 80/Listen\ 8080/g"  /etc/httpd/conf/httpd.conf
RUN sed -i "s/\"logs\/error_log\"/\/dev\/stderr/g" /etc/httpd/conf/httpd.conf
RUN sed -i "s/CustomLog \"logs\/access_log\"/CustomLog \/dev\/stdout/g" /etc/httpd/conf/httpd.conf
RUN echo 'IncludeOptional /opt/app-root/*.conf' >> /etc/httpd/conf/httpd.conf
RUN mkdir /opt/app-root/ && chown apache:apache /opt/app-root/ && chmod 777 /opt/app-root/

USER apache

EXPOSE 8080 8081
ENTRYPOINT ["/usr/sbin/run-httpd.sh"]