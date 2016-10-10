FROM debian:jessie
MAINTAINER Odoo S.A. <info@odoo.com>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            node-clean-css \
            python-pyinotify \
            python-renderpm \
            python-support \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install Odoo
ENV ODOO_VERSION 10.0
ENV ODOO_RELEASE 20161007
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && echo '1d7a801c9103167bfe7da0ae4191104992e16924 odoo.deb' | sha1sum -c - \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb
####################################
# Copy entrypoint script and Odoo configuration file
#COPY ./entrypoint.sh /
#RUN chown odoo /entrypoint.sh
#RUN chmod 777  /entrypoint.sh
#COPY ./openerp-server.conf /etc/odoo/
#RUN chown odoo /etc/odoo/openerp-server.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
#RUN mkdir -p /mnt/extra-addons \
#        && chown -R odoo /mnt/extra-addons
#VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
#EXPOSE 8069 8071

# Set the default config file
#ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# Set default user when running the container
#USER odoo

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["odoo-bin"]
###################################"

USER root
RUN mkdir -p /var/log/odoo
RUN chown odoo /var/log/odoo
RUN chmod 777 -R /var/log/odoo
# Execution environment 
# USER 0 # Copy entrypoint script , Odoo Service script and Odoo configuration file 
COPY ./entrypoint.sh /
RUN chown odoo /entrypoint.sh
RUN chmod 777  /entrypoint.sh
COPY ./openerp-server.conf /etc/
RUN chown odoo /etc/openerp-server.conf
RUN chmod 777 /etc/openerp-server.conf

#ADD sources/pip-req.txt /opt/sources/pip-req.txt
#RUN pip install -r /opt/sources/pip-req.txt
#COPY /opt/odoo/openerp-server /etc/init.d/  # added by self
#COPY ./openerp-server /etc/init.d/
#RUN chmod 755 /etc/init.d/openerp-server
#RUN chown root: /etc/init.d/openerp-server
# Create service sudo service odoo-server start 
#RUN update-rc.d openerp-server defaults
# Start odoo service 
RUN service odoo status
# Mount /opt/odoo to allow restoring filestore and /mnt/extra-addons for users addons 
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/opt/odoo", "/mnt/extra-addons"]
# Expose Odoo services 
EXPOSE 8069 8071 
# Set the default config file 
ENV OPENERP_SERVER /etc/openerp-server.conf 
# Set default user when running the container 
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/opt/odoo/openerp-server"]
