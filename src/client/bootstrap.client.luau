--!optimize 2
--!native

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local bootstrap = require("@shared/modules/bootstrap")
local misc_utils = require("@shared/utils/misc")

local combined_controllers = Instance.new("Folder")
local client_controllers = script.Parent.controllers

--// copy client controllers to combined controllers
misc_utils.copy(client_controllers, combined_controllers)

function character_added()
	--// bootstrap controllers
	bootstrap(combined_controllers)
end

if player.Character then
	character_added()
end

player.CharacterAdded:Connect(character_added)
