Basic guide for strawberry
===========================
It's an openresty web framework, contains MVC and ORM

     ___  ____  ___    __  _    _  ___  ___  ___   ___   _  _ 
    / __)(_  _)(  ,)  (  )( \/\/ )(  ,)(  _)(  ,) (  ,) ( \/ )
    \__ \  )(   )  \  /__\ \    /  ) ,\ ) _) )  \  )  \  \  / 
    (___/ (__) (_)\_)(_)(_) \/\/  (___/(___)(_)\_)(_)\_)(__/  

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

                           client
                            +  ^
                    request |  |response
                            |  |
                            v  +
                        application
                             +
                             | route
                             |
                             v
                     controller:action
                       +            +
                       |            |
             relation  v            v
    ar+-+ar+----------+ar     redis_cluster
                       +            +
         query_builder |            |
                       v            v
                   connection   connection
                       +            +
                       |            |
                       v            v
                     mysql        redis


###	HowToUse
####	MVC

*	Define controller
	-	reference test/controllers/test.lua

*	Define action
	-	an action is a function of controller
	-	each action should return a response

*	Define model, extends framework.db.mysql.active_record

*	Visit http://server/module_layer1/module_layer2/controller/action and see the response

####	ORM
#####	Active Record
*	find
	-	return query instance delegate the model

*	select columns
	-	eg:select({"id", "name"})

*	from table
	-	eg:from("user")

*	conditions
	-	where("name", "zhangkh")
	-	where_in("name", {"zhangkh", "zcc"})
	-	where_like("name", "z%")
	-	where_multi({"or", "name='zhangkh'", {"and", "id=2", "name='zcc'"}})
		>	where (name='zhangkh' or (id=2 and name='zcc'))

*	group by
	-	eg:group_by("age"):group_by("sex")
		>	group by age,sex

*	order by
	-	eg:order_by({"age", "desc"}):order_by({"name", "asc"}), default "asc"
		>	order by age desc, name asc

*	limit
	-	eg:limit(5)

*	offset
	-	eg:offset(10)

*	one: get one row

*	all: query all matched rows

*	as_array: return array instead of model instance

#####	Relation
*	has one
	-	return one-one relation, foreign key in destination table

*	has many
	-	return one-many relation

*	belongs_to_many
	-	return many-many relation which has a junction table
	-	by default, junction table is the two related model names joined in alphabetical order

*	example: see test/models/user.lua


### TODO
*	eager loading of relation

*   more unittest

*	more doc

*   Service Locator

*	optimize orm
