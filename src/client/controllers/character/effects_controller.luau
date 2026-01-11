--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local fluid = require("@pkg/fluid")
local group = require("@pkg/group")

local root, create = fluid.root, fluid.create

local debugger = require("@shared/debugger")
local effects = require("@shared/utils/effects")

local utility = require("@shared/utils/misc")

local root_component = require("@shared/ui/components/root")
local frame_component = require("@shared/ui/components/frame")
local boost_component = require("@shared/ui/components/kit/boost")

local effects_controller = {}

effects_controller.priority = 5
effects_controller.identifier = "effects_controller"

export type self = typeof(effects_controller)

function effects_controller.create_root(_self: self)
	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local player_gui = player.PlayerGui

	--// init the screengui
	local boost_root = root_component({
		Parent = player_gui,
		IgnoreGuiInset = true,
	}, {})

	local boost_frame = frame_component({
		Parent = boost_root.instance,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {}, {
		layout = create("UIListLayout")({
			Name = "layout",

			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),

			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})

	return boost_frame
end

function effects_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	root(function()
		local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

		--// init the screengui
		local boost_frame = self:create_root()

		local STEP_RATE = 0.1
		local REMOVE_GRACE = 0.15

		local active_effects = {} :: {
			[string]: {
				start: number,
				lifetime: number,
				last_seen: number,
			},
		}

		local boost_frames = {} :: {
			[string]: any,
		}

		self.group:add(RunService.PostSimulation:Connect(function()
			local now = os.clock()

			if utility.throttle(`step effects for {player.UserId}`, STEP_RATE) then
				local result = effects.step() or {}
				local effect_names = {}

				for _, data in pairs(result) do
					local name = data.effect

					active_effects[name] = {
						start = data.start,
						lifetime = data.lifetime,
						last_seen = now,
					}

					table.insert(effect_names, name)
				end

				if utility.get_table_size(effect_names) > 0 then
					local effects_table = table.concat(effect_names, ", ")

					debugger.log(`stepping player effects: {effects_table}`, "success")
				end
			end

			for name, effect in pairs(active_effects) do
				local elapsed = now - effect.start
				local percentage = math.clamp(elapsed / effect.lifetime, 0, 1)

				if not boost_frames[name] then
					boost_frames[name] = boost_component({
						Name = name,

						Parent = boost_frame.instance,
						Size = UDim2.fromOffset(100, 100),

						Position = UDim2.fromScale(0.5, 1),
						AnchorPoint = Vector2.new(0.5, 1),
					}, {
						visible = fluid.source(false),
						percentage = fluid.source(0),

						-- it's a source because in the boost story, i added a "boost_type" control
						-- so i could test both boost types easily
						boost_type = fluid.source(name),
					})
				end

				local boost = boost_frames[name]

				boost.states.visible(true)
				boost.states.percentage(1 - percentage)
			end

			for name, boost in pairs(boost_frames) do
				local effect = active_effects[name]

				if not effect or (now - effect.last_seen) > REMOVE_GRACE then
					boost.states.visible(false)

					task.delay(0.5, function()
						if boost_frames[name] == boost then
							boost.instance:Destroy()

							boost_frames[name] = nil
							active_effects[name] = nil
						end
					end)
				end
			end
		end))
	end)
end

function effects_controller.stop(self: self)
	--// clean this controller's group
	self.group:clean()
end

return effects_controller
