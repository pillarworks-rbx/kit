--!optimize 2
--!native

local misc_utils = require("@shared/utils/misc")

local fluid = require("@pkg/fluid")
local root, create, spring = fluid.root, fluid.create, fluid.spring

local boost_colours = {
	speed = Color3.fromRGB(255, 100, 100),
	jump = Color3.fromRGB(150, 255, 150),
}

local boost_images = {
	speed = "rbxassetid://10249261576",
	jump = "rbxassetid://2238767564",
}

local spring_speed, spring_damping = 20, 1

return function(
	props: { [string]: any | fluid.Source<any> },
	states: { [string]: fluid.Source<any> },
	children: { [string]: Instance }?
)
	local new_props = table.clone(props)
	local parent = new_props.Parent

	local boost_root, boost_base, boost_bar, boost_image
	local created_children

	root(function()
		boost_root = create("Frame")({
			Size = spring(function()
				local size = new_props.Size
				local visible = states.visible()

				local offset = visible and 0 or 15

				return UDim2.new(size.X.Scale, size.X.Offset - offset, size.Y.Scale, size.Y.Offset - offset)
			end, spring_speed, spring_damping),

			Position = spring(function()
				local position = new_props.Position
				local visible = states.visible()

				local offset = visible and 0 or 5

				return UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + offset)
			end, spring_speed, spring_damping),

			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			Parent = parent,
		})

		boost_base = create("Frame")({
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundColor3 = Color3.fromRGB(0, 0, 0),

			BackgroundTransparency = spring(function()
				local visible = states.visible()

				return visible and 0.5 or 1
			end, spring_speed, spring_damping),

			BorderSizePixel = 0,

			Parent = boost_root,
		})

		boost_bar = create("Frame")({
			Size = UDim2.new(1, -8, 0, 4),
			Position = UDim2.new(0.5, 0, 1, -4),
			AnchorPoint = Vector2.new(0.5, 1),

			Rotation = 180,

			BackgroundColor3 = function()
				local boost_type = states.boost_type()

				return boost_colours[boost_type] or Color3.fromRGB(255, 255, 255)
			end,

			BackgroundTransparency = spring(function()
				local visible = states.visible()

				return visible and 0.5 or 1
			end, spring_speed, spring_damping),

			BorderSizePixel = 0,

			Parent = boost_base,
		})

		boost_image = create("ImageLabel")({
			Name = "image",
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Position = UDim2.new(0.5, 0, 0.5, -3),
			AnchorPoint = Vector2.new(0.5, 0.5),

			Image = function()
				local boost_type = states.boost_type()

				return boost_images[boost_type] or ""
			end,

			ImageTransparency = spring(function()
				local visible = states.visible()

				return visible and 0.25 or 1
			end, spring_speed, spring_damping),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Parent = boost_base,
		})

		if children and typeof(children) == "table" and misc_utils.get_table_size(children) > 0 then
			for name, value in pairs(children) do
				boost_root[name] = value
			end
		end

		created_children = {
			base = {},
			root = {},
			bar = {},
			image = {},
		}

		created_children.base.corner = create("UICorner")({
			Name = "corner",
			Parent = boost_base,

			CornerRadius = UDim.new(0, 6),
		})

		created_children.bar.gradient = create("UIGradient")({
			Name = "gradient",
			Parent = boost_bar,

			Transparency = function()
				local percentage = math.clamp(states.percentage(), 0, 1)

				return NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(percentage, 0),
					NumberSequenceKeypoint.new(math.clamp(percentage + 0.01, 0, 1), 1),
					NumberSequenceKeypoint.new(1, 1),
				})
			end,
		})

		created_children.bar.corner = create("UICorner")({
			Name = "corner",
			Parent = boost_bar,

			CornerRadius = UDim.new(1, 0),
		})

		created_children.image.aspect_ratio = create("UIAspectRatioConstraint")({
			Name = "aspect_ratio",
			AspectRatio = 1,
			Parent = boost_image,
		})
	end)

	return {
		instance = boost_root,
		children = created_children,
		states = states,
	}
end
