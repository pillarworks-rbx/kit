--!optimize 2
--!native

local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local group = require("@pkg/group")
local region = require("@pkg/region")

local music_controller = {}

music_controller.priority = 3
music_controller.identifier = "music_controller"

export type self = typeof(music_controller)

type sound = {
    audio: string,
    volume: number
}

local ZONE_TAG = "pillarworks_music"

local SOUND_GROUP = SoundService:WaitForChild("music"):WaitForChild("pillars") :: SoundGroup
local ACTIVE_MUSIC = SOUND_GROUP:WaitForChild("active") :: Sound

ACTIVE_MUSIC.Looped = true

local tween_info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local zones = {} :: { BasePart }
local zone_sounds = {} :: { [BasePart]: sound }

function music_controller.start(self: self)
	self.group = group.create()

	for _, zone in pairs(CollectionService:GetTagged(ZONE_TAG)) do
    	if table.find(zones, zone) then
        	continue
    	end

		local sound = zone:FindFirstChild("audio") :: Sound?

		if sound then
			zone_sounds[zone] = {
				audio = sound.SoundId,
				volume = sound.Volume
			}

			sound:Destroy()
		end

		table.insert(zones, zone)
	end

	warn("zones:", zones)
    warn("zone_sounds:", zone_sounds)

	local current_zone: BasePart? = nil
	local active_tween: Tween? = nil
	local transition_id = 0

	local function fade_to(sound: sound?)
		transition_id += 1

		local my_id = transition_id

		if active_tween then
			active_tween:Cancel()
			active_tween = nil
		end

		if not sound or not sound.audio then
			active_tween = TweenService:Create(ACTIVE_MUSIC, tween_info, {
				Volume = 0,
			})

			if not active_tween then
				return
			end

			active_tween:Play()
			active_tween.Completed:Once(function()
				if transition_id ~= my_id then
					return
				end

				ACTIVE_MUSIC:Stop()
			end)

			return
		end

		-- Change track
		if ACTIVE_MUSIC.SoundId ~= sound.audio then
			ACTIVE_MUSIC.SoundId = sound.audio
			ACTIVE_MUSIC.TimePosition = 0
		end

		if not ACTIVE_MUSIC.IsPlaying then
			ACTIVE_MUSIC.Volume = 0
			ACTIVE_MUSIC:Play()
		end

		active_tween = TweenService:Create(ACTIVE_MUSIC, tween_info, {
			Volume = sound.volume,
		})

		if not active_tween then
			return
		end

		active_tween:Play()
	end

	local _regions = {}

	for _, zone in pairs(zones) do
		local new_region = region.new(zone, {
			enter = function()
				if current_zone ~= zone then
					current_zone = zone

					fade_to(zone_sounds[zone])
				end
			end,

			exit = function()
				if current_zone == zone then
					current_zone = nil

					fade_to(nil)
				end
			end,
		})

		table.insert(_regions, new_region)
	end
end

function music_controller.stop(self: self)
	self.group:clean()
end

return music_controller
