#!/bin/bash

# check apache dependencies are running
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
sudo a2enmod headers

service apache2 restart
# start first process : apache2 server
apachectl -D FOREGROUND

# start second process : r shiny app
# remember USE RSCRIPT instead of R -e because latter does not work in sh
Rscript -e "shiny::runApp('root/apps/app.R', port=3838)"