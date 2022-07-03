# Ambition Framework 0.2

## What is the Ambition Web Framework?

Ambition is a next-generation MVC web application framework, empowering
developers to create beautiful and expressive applications in minimal time, and
scale them to incredible heights. Written in and targeted at the Vala
programming language, find out how to get all the benefits of a static-typed
language without the pain or verbosity.

## Requirements

Ambition is written in the Vala programming language, and relies on other
libraries for its functionality. To build, you will need:

* Vala 0.54.0 or higher
* Meson 0.60 or higher

At minimum, the following libraries are required:

* glib-2.0 (2.32 or higher)
* gio-2.0
* gee-0.8
* readline
* libsoup-2.4
* json-glib-1.0
* log4vala-0.2 (https://github.com/nmelnick/Log4Vala)

## Installation

To install the project from the Git repository, you will need Vala 0.54 or
higher, and the Meson build system. Check out the repository, enter the
repository directory, and enter the following:

```
meson --prefix=/usr builddir
cd builddir
ninja
sudo ninja install
```

## Docker

This project can also be run directly from Docker. To build the Docker container
locally:

```
docker build --tag ambition:latest .
docker run -it ambition:latest
```

## Links

* http://www.ambitionframework.org
