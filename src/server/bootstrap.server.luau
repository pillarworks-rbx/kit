--!optimize 2
--!native

local bootstrap = require("@shared/modules/bootstrap")
local misc_utils = require("@shared/utils/misc")

local parent = script.Parent :: Instance

local combined_services = {} :: { [string]: any }
local server_services = parent.services

--// copy server services to combined services
misc_utils.traverse(server_services, function(instance: Instance)
    if instance and instance:IsA("ModuleScript") then
        local module = require(instance)
        
        table.insert(combined_services, module)
    end
end)

--// bootstrap services
bootstrap(combined_services)
