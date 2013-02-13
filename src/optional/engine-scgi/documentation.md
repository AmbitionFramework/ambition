# SCGI

## What is it for?

The <a href="http://en.wikipedia.org/wiki/Simple_Common_Gateway_Interface">SCGI</a> Engine plugin provides engine support for connecting to a SCGI-compliant web server. This can provide faster responses and better reliability than proxying through the built-in Raw engine in Ambition.

Most web servers provide SCGI support. These include, but are not limited to:
* <a href="http://httpd.apache.org/">Apache</a>
* <a href="http://www.lighttpd.net/">Lighttpd</a>
* Microsoft IIS (with <a href="http://woof.magicsplat.com/isapi_scgi/home">ISAPI SCGI extension</a>)
* <a href="http://nginx.org/">nginx</a>

## Installation and Configuration

The engine-scgi plugin can be installed using the usual Ambition plugin tool, and can be used immediately without configuration with sensible defaults. To always use SCGI, _engine_ must be set to _SCGI_ in your configuration file. Otherwise, to use the SCGI for one session, execute:

    ambition run --engine SCGI

To change the configuration of the SCGI plugin, edit your application's configuration file in the `config/` directory.

_scgi.port_ - Listening port of the SCGI server, and should match the web server configuraion. Defaults to 3200.

_scgi.threads_ - Number of listening threads for the SCGI server. Defaults to 10.

## Configuring a Web Server

### nginx

    server {
    	listen 80;
    	location / {
    		include scgi_params;
    		scgi_pass 127.0.0.1:3200;
    	}
    	location /static {
    		root /path/to/your/application/;
    	}
    }

### Apache 2.x

    <VirtualHost *:80>
    	DocumentRoot /path/to/empty/directory;
    	Alias /static/ /path/to/your/application/static/;
    	SCGIMount / 127.0.0.1:3200
    	<LocationMatch "/static">
    		SCGIHandler Off
    	</LocationMatch>
    </VirtualHost>
