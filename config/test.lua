local Appconf={}
Appconf.name = 'framework'

Appconf.route='framework.routes.simple'
Appconf.bootstrap='test.bootstrap'
Appconf.app={}
Appconf.app.root=ngx.var.root .. '/'

Appconf.controller={}
Appconf.controller.prefix = 'test.controllers.'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'test/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
