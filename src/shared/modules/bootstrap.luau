--!optimize 2
--!native

return function(services: Folder)
    local framework = require("@shared/modules/framework")
    
	--// run all services
	framework.run(services)
end
