--[[
	// FileName: DoorControl.lua
	// Written by: Jake Baxter
	// Version v0.1.0
	// Description: Door control stuff -- SERVER
	// Contributors:
--]]


--[[Settings]]--

local Module = script.TrainType1 --//Change to module
local DoorPreSetup = {} --//Add doors premade, if not keep as {}



--[[Variables]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventStorage
local BindableEvent = script.SendToClients
local HttpService = game:GetService("HttpService")
local GeneratedUUID = HttpService:GenerateGUID(false)
local StoredInformation = {}
local temp = {}
local RemoteEvent


--[[Init]]--

do
	if not ReplicatedStorage:FindFirstChild("DoorSystem") then
		local NewFolder = Instance.new("Folder")
		NewFolder.Parent = ReplicatedStorage
		NewFolder.Name = "DoorSystem"
	end
	EventStorage = game:GetService("ReplicatedStorage"):WaitForChild("DoorSystem")
	
	
	RemoteEvent = Instance.new("RemoteEvent", EventStorage)
end


RemoteEvent.Name = GeneratedUUID .. "event"

StoredInformation.DoorWorkers = DoorPreSetup 


RemoteEvent.OnServerEvent:Connect(function(plr, packetSent)
	
	
	if (typeof(packetSent) ~= "table") then
		return
	end
	
	
	if (packetSent["act"] == "init") then
		
		for _,v in pairs(StoredInformation.DoorWorkers) do
			RemoteEvent:FireAllClients("AddDoor", v)
		end
		
		
	end
	
	
end)



BindableEvent.Event:connect(function(packetSent)
	
	if (typeof(packetSent) ~= "table") then
		return false
	end	
	
	
	if (packetSent["act"] == "AddDoor") then
		if (StoredInformation.DoorWorkers[packetSent.reference]) then
			return false
		end
		
		
		if not (typeof(packetSent.reference) == "Instance") then
			return false
		end
		
		StoredInformation.DoorWorkers[packetSent.reference] = packetSent
		
		for _,v in pairs(game.Players:GetPlayers()) do
			RemoteEvent:FireClient(v, "AddDoor", packetSent)
		end
		
		
		return true

	end
	
	
	if (packetSent["act"] == "RemoveDoor") then
		if not (typeof(packetSent.reference) == "Instance") then
			return false
		end

		StoredInformation.DoorWorkers[packetSent.reference] = nil
		
		RemoteEvent:FireAllClients("RemoveDoor", packetSent)
		
		return true

	end
	
	
	
	if (packetSent["act"] == "OpenDoors") then
		if not (typeof(packetSent.doors) == "table") then
			return false
		end

		RemoteEvent:FireAllClients("OpenDoors", packetSent)

		return true

	end
	
	
	if (packetSent["act"] == "CloseDoors") then
		if not (typeof(packetSent.doors) == "table") then
			return false
		end

		RemoteEvent:FireAllClients("CloseDoors", packetSent)

		return true

	end
	
	
	
	

	
end)

local LocalScript = Module
if LocalScript then
		local function addMyLocalScript(player)
			local localScript = LocalScript:Clone()
			local playerGui = player:WaitForChild("PlayerGui")
			local trainGui = player:FindFirstChild("PersistentTrainGui")
			if not trainGui then
				trainGui = Instance.new("ScreenGui")
				trainGui.Name = "PersistentTrainGui"
				trainGui.ResetOnSpawn = false
				trainGui.Parent = playerGui
			end
			localScript.Parent = trainGui
			localScript.LinkedTrain.Value = GeneratedUUID
		end
	
			
		-- Loop through all players when model added
		for _, player in pairs(game.Players:GetPlayers()) do
				addMyLocalScript(player)
		end

			-- Add script when player is added
		game.Players.PlayerAdded:connect(addMyLocalScript)
else
		warn("Door system will not work for (reference): " .. script)
end



for _,v in pairs(script.Parent:GetDescendants()) do
	if v:GetAttribute("LocalDoorType") then
		v.ClickDetector:connect(function()
			script.SendToClients:Fire({["act"] = "AddDoor", ["reference"] = v, ["doorModuleType"] = v:GetAttribute("DoorModuleType")})
		end)
	end
end