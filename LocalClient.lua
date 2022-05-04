--//Variables\\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorSystemRS = ReplicatedStorage:WaitForChild("DoorSystem")
linkedTrainString = script.LinkedTrain.Value
repeat task.wait(1) until (linkedTrainString ~= "" and game:IsLoaded())
local DoorSystemEvent = DoorSystemRS:WaitForChild(linkedTrainString .. "event")
local RunService = game:GetService("RunService")


local DoorTypes = {}

local DoorWorkers = {}
DoorWorkers["DoorWork"] = {}
DoorWorkers["Interlock"] = {}

local e = {}


--// Custom \\--

do
	
	
	DoorTypes.LocoCab = {}
	
	
	DoorTypes.LocoCab.Init = function(packet)
		
		local NewInstance = packet.reference:Clone()
		NewInstance.Name = "CopiedCabDoor"
		NewInstance.Parent = workspace.CurrentCamera
		NewInstance.Anchored = true
		for _,v in pairs(NewInstance:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
			end
			if v:IsA("Weld") then
				v:Destroy()
			end
			
		end
		
		for _,v in pairs(packet.reference) do
			v.CanCollide = false
			v.Transparency = 1

		end
		DoorWorkers["DoorWork"][packet.reference]["New"] = NewInstance
		DoorWorkers["DoorWork"][packet.reference]["Old"] = packet.reference
		DoorWorkers["DoorWork"][packet.reference]["delta"] = DoorTypes.LocoCab.delta
		DoorWorkers["DoorWork"][packet.reference]["Open"] = DoorTypes.LocoCab.Open
		DoorWorkers["DoorWork"][packet.reference]["Close"] = DoorTypes.LocoCab.Close
		DoorWorkers["DoorWork"][packet.reference]["Progress"] = 0
		DoorWorkers["DoorWork"][packet.reference]["Open"] = false
		DoorWorkers["DoorWork"][packet.reference]["AncCheck"] = packet.reference.AncestryChanged:connect(function()
			if not  packet.reference.Parent then
				DoorWorkers["DoorWork"][packet.reference]["New"]:Destroy()
				DoorWorkers["DoorWork"][packet.reference] = nil
			end
		end)
	end
	
	
	DoorTypes.LocoCab.Open = function()
		
	end
	
	
	DoorTypes.LocoCab.Close = function()

	end
	
	
	
	DoorTypes.LocoCab.delta = function(door, delta)
		
		if door.Open then
			
			door.Progress = math.min(1, door.Progress + delta)
		end
		if not door.Open then

			door.Progress = math.max(0, door.Progress - delta)
		end
		
		door.New.CFrame = door.Old.HingeRef.Value.CFrame * CFrame.Angles(0, door.Progress*90, 0)
		
	end
	
	
end






local function AddDoor(packet)
	--//Custom to thing
	if DoorWorkers["DoorWork"][packet.reference] then
		print("Already referenced!")
		return
	end
	local FoundDoorModule = DoorTypes[packet.reference:GetAttribute("LocalDoorType")]
	if FoundDoorModule then
		FoundDoorModule.Init(packet)
		
	end
	
	
end





local function RemoveDoor(packet)
	--//Custom to thing
	DoorWorkers["DoorWork"][packet.reference] = nil
end



local function OpensDoors(list)
	if (typeof(list) ~= "table") then
		return false
	end
	for _,v in pairs(list) do
		if DoorWorkers["DoorWork"][v] then
			DoorWorkers["DoorWork"][v]["Open"] = true
		end
	end
end




local function CloseDoors(list)
	if (typeof(list) ~= "table") then
		return false
	end
	for _,v in pairs(list) do
		if DoorWorkers["DoorWork"][v] then
			DoorWorkers["DoorWork"][v]["Open"] = false
		end
	end
end





RunService.RenderStepped:connect(function(delta)
	for _,v in pairs(DoorWorkers.DoorWork) do
		v.delta(v, delta)
		
	end
end)




DoorSystemEvent.OnClientEvent:connect(function(action, packet)
	
	
	if action == "respond-init" then
		
		for i,v in pairs(packet.DoorWorkers) do
			AddDoor(v)
		end
		
		return
	end
	
	if action == "AddDoor" then
		AddDoor(packet)
		return
	end
	
	
	if action == "OpenDoors" then
		OpensDoors(packet.doors)
		return
	end
	
	
	
	
	if action == "CloseDoors" then
		CloseDoors(packet.doors)
		return
	end
	
	

	
end)

DoorSystemEvent:FireServer({["act"] = "init"})
