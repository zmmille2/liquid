FROM debian:stable
MAINTAINER Cole Gleason <cagleas2@illinois.edu>
RUN apt-get update && apt-get -y install build-essential \
    nginx \
    supervisor \
    sqlite3 \
    python \
    python-dev \
    python-setuptools \
    uwsgi \
    libmysqlclient-dev \
    libldap2-dev \
    libsasl2-dev

RUN easy_install pip
RUN pip install uwsgi
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default

ADD docker /liquid
ADD liquid /liquid/app

WORKDIR /liquid

RUN cp wsgi.py app/wsgi.py
RUN cp local_settings.py app/local_settings.py
RUN pip install -r app/requirements.txt

RUN python app/manage.py syncdb --noinput
RUN python app/manage.py migrate

# setup all the configfiles
RUN ln -s /liquid/nginx-liquid.conf /etc/nginx/sites-enabled/
RUN ln -s /liquid/supervisor.conf /etc/supervisor/conf.d/

# setup exim4 mail server
RUN /liquid/exim.sh

EXPOSE 80
CMD ["/liquid/run.sh"]
