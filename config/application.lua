return {
    debug = true,
    module_name = 'app',
    route = 'framework.routes.simple',
    base_dir = ngx.var.root .. '/',
    version = '1.0.0',

    view = {
        path = Appconf.app.root .. 'app/views/',
        suffix = '.html',
        auto_render = true,
    },
}
