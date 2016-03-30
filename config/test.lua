local Appconf = {}
Appconf.name = 'test'

Appconf.route = 'framework.routes.simple'
Appconf.bootstrap = 'test.bootstrap'
Appconf.app = {}
Appconf.app.root = ngx.var.root .. '/'

Appconf.controller = {}
Appconf.controller.prefix = 'test.controllers.'

return Appconf
