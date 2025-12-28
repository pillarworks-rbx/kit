--!optimize 2
--!native

local misc_utils = require("@shared/utils/misc")

local external_repository = require("@shared/kit/external/repository")
local repository = {}

misc_utils.traverse(script, repository)

for name, value in pairs(external_repository) do
    repository[name] = value
end

return repository