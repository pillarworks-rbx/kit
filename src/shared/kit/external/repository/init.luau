local misc_utils = require("@shared/utils/misc")
local repository = {}

misc_utils.traverse(script, repository)

return repository