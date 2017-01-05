FROM ubuntu:16.04
EXPOSE 8099

# Init
# valac is 0.30 in 16.04, which is acceptable
RUN apt-get update \
	&& apt-get install -y \
		software-properties-common build-essential wget cmake git valac \
		libglib2.0-dev libgee-0.8-dev libjson-glib-dev libreadline-dev \
		libsoup2.4-dev libgda-5.0-dev libgda-5.0-postgres \
	&& wget http://mirrors.us.kernel.org/ubuntu/pool/universe/c/couchdb-glib/libcouchdb-glib-1.0-2_0.7.4-0ubuntu3_amd64.deb \
	&& wget http://mirrors.us.kernel.org/ubuntu/pool/universe/c/couchdb-glib/libcouchdb-glib-dev_0.7.4-0ubuntu3_amd64.deb \
	&& dpkg -i libcouchdb-glib-1.0-2_0.7.4-0ubuntu3_amd64.deb libcouchdb-glib-dev_0.7.4-0ubuntu3_amd64.deb \
	&& mkdir /ambition-src /ambition-src/ambition

WORKDIR /ambition-src
COPY . /ambition-src/ambition
RUN git clone https://github.com/nmelnick/Log4Vala.git log4vala \
	&& git clone https://github.com/AmbitionFramework/libgscgi.git \
	&& git clone https://github.com/AmbitionFramework/almanna.git \
	&& cd libgscgi \
	&& make && make install \
	&& cd ../log4vala \
	&& mkdir build && cd build \
	&& cmake .. \
	&& make && make install \
	&& cd ../../almanna \
	&& mkdir build && cd build \
	&& cmake .. \
	&& make && make install \
	&& cd ../../ambition \
	&& mkdir build && cd build \
	&& cmake .. \
	&& make && make install

# Launch
CMD bash
