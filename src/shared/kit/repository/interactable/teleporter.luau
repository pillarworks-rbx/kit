--!optimize 2
--!native

local debugger = require("@shared/debugger")
local misc_utils = require("@shared/utils/misc")

local std = require("@kit/std")
local types = require("@kit/types")

local object_utils = std.object
local attributes = std.attributes
local players = std.players

local object = object_utils.register({
	events = {},

	attributes = {
		cooldown = attributes.attributes.number({
			default = 0.1,
		}),

		offset = attributes.attributes.cframe({
			default = CFrame.new(0, 0, 0),
		}),

		seamless = attributes.attributes.boolean({
			default = true,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, _pillar: pillar)
	local object_attributes = attributes.get(self)

	local cooldown = object_attributes.cooldown
	local offset = object_attributes.offset
	local seamless = object_attributes.seamless

	local player = players.from_hit(hit)

	if not player then
		return
	end

	local character = players.get_character(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end
	
	local instance = self.instance
    
    if not instance or not instance:IsA("Model") then
        return
    end
    
    local origin = instance:FindFirstChild("origin") :: Part?
    local destination = instance:FindFirstChild("destination") :: Part?
    
    if not origin or not destination then
        return
    end

	if misc_utils.throttle(`teleport {player.UserId} in {self.id}`, cooldown) then
	    local seamless_offset = if seamless then origin.CFrame:ToObjectSpace(root.CFrame) else CFrame.new()
		local true_offset = offset * seamless_offset:Inverse()
		
		local destination_cframe = destination.CFrame * CFrame.new(0, character:GetExtentsSize().Y / 2, 0) * true_offset
		
		root.CFrame = destination_cframe
	end
end

function object.events.load(self: object, pillar: pillar)
    local instance = self.instance
    
    if not instance or not instance:IsA("Model") then
        debugger.log(`object {self.id} is not a valid model`, "error")
        
        return
    end
    
    local origin = instance:FindFirstChild("origin") :: Part?
    local destination = instance:FindFirstChild("destination") :: Part?
    
    if not origin or not destination then
        debugger.log(`object {self.id} does not have an origin or destination`, "warn")
        
        return
    end
    
    self.group:add(origin.Touched:Connect(function(hit: BasePart)
        debugger.log(`object {self.id} has been hit by "{hit:GetFullName()}"`, "success")
        
		on_hit(self, hit, pillar)
	end))
    
    debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()
	
	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
