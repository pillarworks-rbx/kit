--!optimize 2
--!native

local group = require("@shared/modules/group")

export type pillar = {
    id: string,
    name: string,
    difficulty: string,
    creator: string,
}

export type object<T> = T & {
    id: string,
    
	events: {
		load: (self: object<T>, pillar: pillar) -> ()?,
		unload: (self: object<T>, pillar: pillar) -> ()?,
	},

	attributes: { [string]: { [string]: any } },

	group: group.ItemGroup,
	instance: BasePart,
}

export type pillar_data = {
	id: string,
	group: group.ItemGroup,
}

return nil
