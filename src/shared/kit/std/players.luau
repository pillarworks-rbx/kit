--!optimize 2
--!native

local Players = game:GetService("Players")

return {
    from_hit = function(hit: BasePart): Player?
        if not hit or not hit.Parent then
            return nil
        end

        if not hit.Parent:FindFirstChildOfClass("Humanoid") then
            return nil
        end

        local player = Players:GetPlayerFromCharacter(hit.Parent)

        return player
    end,

    get_player = function(): Player?
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

        return player
    end,
    
    get_character = function(player: Player): Model?
        if not player then
            return nil
        end

        local character = player.Character or player.CharacterAdded:Wait()

        return character
    end,

    get_humanoid = function(player: Player): Humanoid?
        if not player then
            return nil
        end

        local character = player.Character or player.CharacterAdded:Wait()

        if not character then
            return nil
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")

        return humanoid
    end
}
