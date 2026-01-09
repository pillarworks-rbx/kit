--!optimize 2
--!native
-- 
local misc_utils = require("@shared/utils/misc")
local repository = {} :: { [string]: any }

misc_utils.traverse(script, function(instance: Instance)
    if instance:IsA("ModuleScript") then
        repository[instance.Name] = require(instance)
    end
end)

return repository