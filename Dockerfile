FROM ubuntu:20.04
EXPOSE 8099

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Init
RUN apt-get update \
	&& apt-get install -y \
		software-properties-common build-essential wget git valac \
		libglib2.0-dev libgee-0.8-dev libjson-glib-dev libreadline-dev \
		libsoup2.4-dev libgda-5.0-dev libgda-5.0-postgres meson ninja-build \
	&& mkdir /ambition-src /ambition-src/ambition

WORKDIR /ambition-src
COPY . /ambition-src/ambition
RUN git clone https://github.com/nmelnick/Log4Vala.git log4vala \
	&& git clone https://github.com/AmbitionFramework/libgscgi.git \
	&& git clone https://github.com/AmbitionFramework/almanna.git \
	&& cd libgscgi \
	&& make && make install \
	&& cd ../log4vala \
	&& meson --prefix=/usr builddir && cd builddir \
	&& ninja && ninja install \
	&& cd ../../almanna \
	&& meson --prefix=/usr builddir && cd builddir \
	&& ninja && ninja install \
	&& cd ../..
RUN cd ambition \
	&& meson --prefix=/usr builddir && cd builddir \
	&& ninja && ninja install

# Launch
CMD bash
