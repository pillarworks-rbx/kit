--!optimize 2
--!native

local misc_utils = require("@shared/utils/misc")

local external_repository = require("@shared/kit/external/repository")
local repository = {} :: { [string]: any }

misc_utils.traverse(script, function(instance: Instance)
    if instance:IsA("ModuleScript") then
        repository[instance.Name] = require(instance)
    end
end)

for name, value in pairs(external_repository) do
    repository[name] = value
end

return repository