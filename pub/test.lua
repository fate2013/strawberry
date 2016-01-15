local config = require('config.test')
local app = require('framework.application'):new(config)
app:bootstrap():run()
