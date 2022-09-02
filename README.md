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

The `main` branch is the current development branch, and may not be as stable
as a release tag. For production, choose a release tag and build from there.

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

## Hacking and Recommendations

TBD, but:

### Development Environment

Highly recommend the [Vala Language Server](https://github.com/vala-lang/vala-language-server) and something along the lines of the [Vala plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=prince781.vala).

### Linting

```
docker run -v "$PWD":/app valalang/lint:latest /usr/bin/io.elementary.vala-lint -c vala-lint.conf .
```

## Links

* http://www.ambitionframework.org
