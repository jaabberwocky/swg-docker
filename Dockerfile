# set base image
FROM openanalytics/r-base

MAINTAINER tobias.leong "tobias@data.gov.sg"


#### Dependencies ####

# get dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    apache2 \
    apache2-utils

# enable mods for rewrite and proxy_http for apache
RUN a2enmod rewrite
RUN a2enmod proxy_http

#### Authentication ####

# create htpasswd file
RUN mkdir -p /etc/httpd
RUN htpasswd -bc /etc/httpd/htpasswd.users shiny 1234

# move over custom configuration file
COPY config /var/tmp

# change permissions
RUN sudo chmod u+rwx /var/tmp/config

# append config file over
RUN sudo bash -c "cat /var/tmp/config > /etc/apache2/sites-enabled/000-default.conf"

#### Shiny Setup ####

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install required packages
RUN R -e "install.packages(c('ggplot2', 'dplyr'), repos='https://cloud.r-project.org/')"


#### Environment Settings ####

# expose port
EXPOSE 80

# copy shell script
RUN mkdir -p /etc/shell
COPY startup.sh /etc/shell/startup.sh
RUN chmod +x /etc/shell/startup.sh

# execute shell script
CMD ["bash", "/etc/shell/startup.sh"]
#CMD ["R", "-e", "shiny::runApp('root/apps/app.R', port=3838)"]
#CMD apachectl -D FOREGROUND

