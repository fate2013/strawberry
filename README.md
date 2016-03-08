Basic guide for lua web framework
=================================
An openresty web framework, contains MVC and ORM

### HowToStart
*	Install openresty
	-	wget https://openresty.org/download/ngx_openresty-1.9.7.2.tar.gz
	-	tar zxvf ngx_openresty-1.9.7.2.tar.gz
	-	cd ngx_openresty-1.9.7.2/
	-	./configure
	-	make
	-	make install

*	Config vhost
	-	edit openresty nginx config file, add line: include sites-enabled/*;
	-	copy vhost config file to openresty config directory: sudo cp config/nginx.conf /usr/local/openresty/nginx/conf/sites-enabled/{{$project_name}}

*	Start openresty
	-	sudo /usr/local/openresty/nginx/sbin/nginx

*	Configure application and write code
	-	edit app/config/*.lua
	-	write controller to process requests. Reference app/controllers/index.lua
	-	write models to hold reusable business code

###	Architecture



### TODO

*	more doc

*   Service Locator

*	optimize orm
