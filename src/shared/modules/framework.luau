--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local framework = {}

function run_lifecycle(singletons: { any }, lifecycle: string)
    for _, singleton in pairs(singletons) do
        if singleton[lifecycle] then
            singleton[lifecycle](singleton)
        end
    end
end

function framework.run(modules: Folder)
    local singletons = {}
    
    for _, module in pairs(modules:GetChildren()) do
        local singleton = require(module)
        
        table.insert(singletons, singleton)
    end
    
    run_lifecycle(singletons, "init")
    run_lifecycle(singletons, "start")
    
    if RunService:IsServer() then
        game:BindToClose(function()
            run_lifecycle(singletons, "stop")
        end)
    else
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local character = player.Character or player.CharacterAdded:Wait()
        
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            run_lifecycle(singletons, "stop")
        end)
    end
end

return framework