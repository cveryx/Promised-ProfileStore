--!strict
local Servers = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages --return to this later
local Promise = require(Packages.Promise)
local ProfileStore = require(Packages.ProfileStore)

local function deepMerge(a: {[string]: any}, b: {[string]: any})
	for k, v in pairs(a) do
		if typeof(v) == "table" and typeof(b[k]) == "table" then
			deepMerge(v, b[k])
		elseif b[k] == nil then
			b[k] = v
		end
	end
	return b
end

local function toKey(p: Player): string
	return tostring(p.UserId)
end

local M = {}

	local function makeSession(p: Player, profile: any)
		local released = false
		local s = {}
		s.player = p
		s.key = toKey(p)
		function s:get(): T
			return profile:Get()
		end
		function s:set(nextFn: (prev: T) -> T)
			profile:Set(nextFn(profile:Get()))
		end
		function s:patch(partial: {[string]: any})
			local cur = profile:Get()
			for k, v in pairs(partial) do
				cur[k] = v
			end
			profile:Set(cur)
		end
		function s:flush()
			profile:Save()
		end
		function s:release()
			if released then return end
			released = true
			live[p] = nil
			profile:Release()
		end
		function s:isActive(): boolean
			return not released
		end
		return s
	end

--TODO: start 

return M