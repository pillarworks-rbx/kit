--!optimize 2
--!native

local group = require("@pkg/group")

--[=[
	@class types
	@tag kit
	
	this module contains types *used by kit scripts*.
]=]

--[=[
	@interface pillar
	@within types
	
	@field id string -- the id of the pillar.
	@field name string -- the name of the pillar.
	
	@field difficulty string -- the difficulty of the pillar.
	@field creator string -- the creator of the pillar.

	represents a pillar that the player can play.
]=]
export type pillar = {
    id: string,
    name: string,
    
    difficulty: string,
    creator: string,
}

--[=[
	@interface object
	@within types
	
	@field id string -- the id of the object.
	@field attributes { [string]: { [string]: any} } -- the attributes of the object.
	@field instance BasePart -- the instance of the object.
	
	@field events { load: (self: object<T>, pillar: pillar) -> ()?, unload: (self: object<T>, pillar: pillar) -> ()? } -- the lifecycle events of the object.
	@field group item_group -- the group of the object.
	
	represents a pillar (or everpresent) object.
]=]
export type object<T> = T & {
    id: string,
    
	events: {
		load: (self: object<T>, pillar: pillar) -> ()?,
		unload: (self: object<T>, pillar: pillar) -> ()?,
	},

	attributes: { [string]: { [string]: any } },

	group: group.item_group,
	instance: BasePart,
}

--[=[
	@interface pillar_data
	@within types
	
	@field id string -- the id of the pillar.
	@field group item_group -- the group of the pillar.
	
	represents a pillar that the player can play.
]=]
export type pillar_data = {
	id: string,
	group: group.item_group,
}

return nil
