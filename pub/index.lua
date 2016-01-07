local config = require('config.application')
local app = require('vanilla.v.application'):new(config)
app:bootstrap():run()
