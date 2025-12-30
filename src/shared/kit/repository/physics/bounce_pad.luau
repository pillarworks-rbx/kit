--!optimize 2
--!native

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players
local utility = std.utility

local object = objects.register({
	events = {},

	attributes = {
		force = attributes.attributes.number({
			min = 1,
			max = 100,
			default = 10,
		}),

		cooldown = attributes.attributes.number({
			min = 0.1,
			max = 100,
			default = 0.2,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, _pillar: pillar)
	local object_attributes = attributes.get(self)

	local force = object_attributes.force
	local cooldown = object_attributes.cooldown

	local player = players.from_hit(hit)

	if not player then
		return
	end

	local character = players.get_character(player)
	
	local humanoid = players.get_humanoid(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root or not humanoid then
		return
	end
	
	local instance = self.instance
    
    if not instance or not instance:IsA("Part") then
        return
    end

	if utility.throttle(`hit {player.UserId} in {self.id}`, cooldown) then
		local root_cf: CFrame = instance.CFrame
		local root_rv = root_cf.UpVector.Unit

		local new_force = force * 5

		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		root.AssemblyLinearVelocity = root_rv * new_force
	end
end

function object.events.load(self: object, pillar: pillar)
    local instance = self.instance
    
    if not instance or not instance:IsA("Part") then
        debugger.log(`object {self.id} does not have an instance or is not a part`, "warn")
        
        return
    end
    
    self.group:add(instance.Touched:Connect(function(hit: BasePart)
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
