--!optimize 2
--!native

local bootstrap = require("@shared/modules/bootstrap")
local misc_utils = require("@shared/utils/misc")

local combined_services = Instance.new("Folder")
local server_services = script.Parent.services

--// copy server services to combined services
misc_utils.copy(server_services, combined_services)

--// bootstrap services
bootstrap(combined_services)
