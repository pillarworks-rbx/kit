---
sidebar_position: 1
---

# getting started
to get started, use the template over at `assets/templates/object.luau`.

copy it into the `src/shared/kit/external/repository` folder so it can be recognised by the kit.

:::warning
if you don't copy the template into the `src/shared/kit/external/repository` folder, the object will not work when ported over to pillarworks! this is the same reason why editing core scripts will not work either.
:::

the object template should look something like this:
```lua title="assets/templates/object.luau"
--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("debugger"))

local std =
	require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("kit"):FindFirstChild("std"))
local types =
	require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("kit"):FindFirstChild("types"))

local object_utils = std.object

local object = object_utils.register({
	events = {},

	attributes = {},
})

export type pillar = types.pillar
export type object = types.processed_object<typeof(object)>

function object.events.load(self: object, _pillar: pillar)
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
		delta_time = math.clamp(delta_time, 0, 1)

		-- do whatever here
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
```

all objects have two events implemented. these are:
- `object.events.load`: this fires when the object is loaded into the pillar/game.
- `object.events.unload`: this fires when the object is unloaded from the pillar/game.

all objects have three variables injected, which you can access using `self.` these are:
- `self.id`: the id of the object.
- `self.group`: the group that the object belongs to for memory management. this is a derivative of the pillar's group.
- `self.instance`: the instance of the object in the game.

:::tip
you can find more documentation relating to object groups [here](https://pesde.dev/packages/pillarworks/group).
:::

:::warning
do not modify any of the injected variables. this may cause unexpected behavior and glitches.
:::
