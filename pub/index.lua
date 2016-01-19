local config = require 'config.application'
local app = require('framework.application'):new(config)
app:bootstrap():run()
