local Schema = {}
Schema.__index = Schema

function Schema:new(model_class)
    return setmetatable({
        model_class = model_class,
    }, Schema)
end

return Schema
