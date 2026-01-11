--!optimize 2
--!native

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local bootstrap = require("@shared/modules/bootstrap")
local misc_utils = require("@shared/utils/misc")

local parent = script.Parent :: Instance

local combined_controllers = {} :: { [string]: any }
local client_controllers = parent.controllers

function parse_fn(instance: Instance)
    if instance and instance:IsA("ModuleScript") then
        local module = require(instance)
        
        table.insert(combined_controllers, module)
    end
end

--// copy client controllers to combined controllers
misc_utils.traverse(client_controllers, parse_fn, "ModuleScript")

function character_added()
	--// bootstrap controllers
	bootstrap(combined_controllers)
end

if player.Character then
	character_added()
end

player.CharacterAdded:Connect(character_added)
