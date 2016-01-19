local Appconf={}
Appconf.name = 'framework'

Appconf.route='framework.routes.simple'
Appconf.bootstrap='app.bootstrap'
Appconf.app={}
Appconf.app.root=ngx.var.root .. '/'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'app/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'app/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
