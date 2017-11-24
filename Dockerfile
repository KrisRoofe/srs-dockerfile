FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y install git unzip autoconf automake libtool make g++ net-tools build-essential

RUN git clone https://github.com/ossrs/srs.git
RUN cd /srs && git checkout v2.0-r2

WORKDIR "/srs/trunk"
# CORS setting
RUN sed -i '/"video\/x-flv"/a\\t\/\/Add Access-Control-Allow-Origin for flv stream\n\tw->header\(\)->set\("Access-Control-Allow-Origin", "\*"\);' src/app/srs_app_http_stream.cpp

RUN unzip 3rdparty/CherryPy-3.2.4.zip -d objs/
RUN ./configure --with-http-api && make

# http_api support
ADD http.flv.live.conf conf/srs.conf
