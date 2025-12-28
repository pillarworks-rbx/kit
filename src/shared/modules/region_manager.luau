--!optimize 2
--!native

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local local_player = Players.LocalPlayer

local region_manager = {}
region_manager.__index = region_manager

local frame_counter = 2

local tracked_regions = {}
local render_connection

local function is_inside(region, root)
	local in_region = region.box.CFrame:PointToObjectSpace(root.Position)
	local half_size = region.box.Size / 2

	local is_inside = math.abs(in_region.X) <= half_size.X
		and math.abs(in_region.Y) <= half_size.Y
		and math.abs(in_region.Z) <= half_size.Z
	
	return is_inside
end

local function ensure_render_stepped()
	if render_connection then 
		return 
	end

	render_connection = RunService.RenderStepped:Connect(function()
		frame_counter += 1
		
		if frame_counter % 2 ~= 0 then
			return 
		end
		
		local character = local_player.Character
		
		if not character then 
			return 
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		
		if not root then 
			return
		end

		for _, region in pairs(tracked_regions) do
			local is_inside = is_inside(region, root)

			if is_inside and not region.player_inside then
				region.player_inside = true

				if region.callbacks.enter then
					task.spawn(region.callbacks.enter)
				end
			elseif not is_inside and region.player_inside then
				region.player_inside = false

				if region.callbacks.exit then
					task.spawn(region.callbacks.exit)
				end
			end
		end
	end)
end

--// RegionManager
function region_manager.new(box: BasePart, callbacks: { enter: () -> (), exit: () -> () })
	assert(box and box:IsA("BasePart"), "box must be a valid BasePart")
	assert(typeof(callbacks) == "table", "callbacks must be a table")

	local region = {
		box = box,
		callbacks = callbacks,
		player_inside = false,
	}

	table.insert(tracked_regions, region)
	ensure_render_stepped()

	return region
end

--// Removal
function region_manager.remove(region_object)
	for index, region in pairs(tracked_regions) do
		if region == region_object then
			table.remove(tracked_regions, index)
			
			break
		end
	end

	-- Stop the heartbeat if no regions left
	if #tracked_regions == 0 and render_connection then
		render_connection:Disconnect()
		render_connection = nil
	end
end

return region_manager