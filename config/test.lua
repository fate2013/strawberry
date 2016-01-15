local Appconf={}
Appconf.name = 'framework'

Appconf.route='vanilla.v.routes.simple'
Appconf.bootstrap='test.bootstrap'
Appconf.app={}
Appconf.app.root='./'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'test/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'test/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
