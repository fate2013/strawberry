local ErrorController = {}

function ErrorController:error()
    local view = self:getView()
    view:assign(self.err)
    return view:display()
end

return ErrorController
