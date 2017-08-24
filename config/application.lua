return {
    module_name = 'app',
    base_dir = ngx.var.root .. '/',
    version = '1.0.0',

    view = {
        path = ngx.var.root .. '/app/views/',
        suffix = '.html',
        auto_render = true,
    },
}
