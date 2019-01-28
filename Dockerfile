From ubuntu:18.04

# update ans upgrade image
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update 
RUN apt-get upgrade -y

# install some useful tool
RUN apt-get install nano wget git sudo -y

#apache
ADD ./configure_file/apache/apache_service.sh  /apache-service.sh
RUN apt-get install apache2 -y && chmod +x /*.sh && a2enmod rewrite
ADD ./configure_file/apache/apache_default  /etc/apache2/sites-available/000-defualt.conf
ADD ./configure_file/apache/supervisor.conf /etc/supervisor/conf.d/apache.conf
RUN service apache2 start


#php
#RUN add-apt-repository ppa:ondrej/php 
RUN apt-get update -y
RUN apt-get install -y php7.2
RUN php -v
RUN apt-get install -y  libapache2-mod-php7.2 php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-mysql php7.2-mbstring php7.2-zip
ADD ./configure_file/php/php.ini /etc/php7/apache2/php.ini

#phpmyadmin
RUN (echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/app-password password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections)
RUN apt-get install phpmyadmin -y
ADD ./configure_file/phpmyadmin/config.inc.php /etc/phpmyadmin/conf.d/config.inc.php
RUN chmod 777 /etc/phpmyadmin/conf.d/config.inc.php
RUN service apache2 restart
# start
VOLUME /var/www/html
EXPOSE 80 22 3306