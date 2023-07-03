local replicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService('TweenService')
local values = replicatedStorage:WaitForChild("Values")
local dialogueVisibleVal = values:WaitForChild("DialogueVisible")
local dialogueSpeakerVal = values:WaitForChild("DialogueSpeaker")
local dialogueSpeakerCharacterVal = values:WaitForChild("DialogueSpeakerCharacter")
local dialogueMessageVal = values:WaitForChild("Message")
local dialogueColorVal = values:WaitForChild("DialogueColor")
local textColorVal = values:WaitForChild("TextColor")

local dialogueFrame = script.Parent:WaitForChild("DialogueFrame")
local viewport =  dialogueFrame:WaitForChild("Viewport")
local mainText = dialogueFrame:WaitForChild("MainText")
local speakerText = viewport:WaitForChild("Speaker")

local shakerModule = require(game.ReplicatedStorage:WaitForChild('CameraShaker'))

local Shaker = shakerModule.new(Enum.RenderPriority.Camera.Value, function(ShakeCF)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * ShakeCF
end)


local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local cameraInterpolateEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("cameraInterpolateEvent")
local cameraToPlayerEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("cameraToPlayerEvent")


player.CharacterAdded:Connect(function(newChar)
	character = newChar
end)

local function playSound(sound_id) -- Plays typing sound
	local sound = Instance.new("Sound",game.ReplicatedStorage)
	sound.SoundId = sound_id
	sound.Volume = .4
	sound.PlayOnRemove = true
	sound:Destroy()
end

local plr = game.Players.LocalPlayer --Current Player
local beam = script:WaitForChild("Beam"):Clone() --Create a clone of our template

local function pathToPart(beam, a0, part) --Function to make making paths easier
	local a1 = part:FindFirstChildOfClass("Attachment")--Find the attachment in the part
	if a1 then --If we found one, attach it
		beam.Attachment0 = a0 --Set attachments
		beam.Attachment1 = a1
	else --If there isn't one, let the scripter know
		warn("No attachment was inserted into "..part:GetFullName())
	end
end

game.ReplicatedStorage.Remotes.PathBeam.OnClientEvent:Connect(function()--Every time player respawns, connect beam again
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart") --Get humanoid root part
	local a0 = root:WaitForChild("RootRigAttachment") --Wait for root rig attachment
	pathToPart(beam, a0, workspace:WaitForChild("Chain").PrimaryPart) --Set attachments
	beam.Parent = char --Parent the beam to the new character
end)

game.ReplicatedStorage.Remotes.RemoveBeam.OnClientEvent:Connect(function()
	if player.Character:FindFirstChildOfClass('Beam') then
		player.Character:FindFirstChildOfClass('Beam'):Destroy()
	end
end)

local function createViewportModel(char)
	if not char then return end

	local viewport = script.Parent:WaitForChild("DialogueFrame"):WaitForChild("Viewport")

	local alreadyexistingmodel = viewport:FindFirstChildOfClass("Model")
	if alreadyexistingmodel then
		alreadyexistingmodel:Destroy()
	end
	
	local alreadyExistingCamera = viewport:FindFirstChildOfClass("Camera")
	if alreadyExistingCamera then
		alreadyExistingCamera:Destroy()
	end

	local fake_char = char:Clone()

	for each, descendant in pairs (fake_char:GetDescendants()) do
		if descendant:IsA('Script') or descendant:IsA('LocalScript') or descendant.Name =="NPCInteract" then
			descendant:Destroy()
		elseif descendant:IsA('BasePart') then
			descendant.Anchored = not true
		elseif descendant:IsA('Humanoid') then
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		--[[elseif descendant:IsA("Motor6D") and PlatformstandToggle then
			--descendant.Transform = CFrame.new()
			descendant.DesiredAngle = 0
		end]]
		end
	end
	fake_char.Name = "Model"
	fake_char.Parent = workspace
	fake_char:SetPrimaryPartCFrame(CFrame.new(0, 10000, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	game:GetService("RunService").Heartbeat:Wait()
	fake_char.Parent = viewport
	char.Archivable = true


	local viewportCamera = Instance.new("Camera")
	local npc_model = viewport:WaitForChild("Model")
	viewportCamera.Parent = viewport
	viewportCamera.CameraSubject = npc_model
	viewportCamera.FieldOfView = 20
	viewport.CurrentCamera = viewportCamera

	local focusPosition = npc_model:WaitForChild("Head").Position
	local Distance = 8

	viewportCamera.CFrame = CFrame.new(focusPosition + npc_model.Head.CFrame.LookVector * Distance, npc_model.Head.Position)
	return fake_char
end

dialogueSpeakerCharacterVal:GetPropertyChangedSignal("Value"):Connect(function()
	---- remove previous camera / character
	--for _, child in ipairs(viewport:GetChildren()) do
	--	if not child:IsA("TextLabel") then
	--		child:Destroy()
	--	end
	--end
	
	--local dCharacter = dialogueSpeakerCharacterVal.Value
	--if not dCharacter:IsDescendantOf(workspace) then return end
	
	--local dCam = Instance.new("Camera")
	--dCam.CameraType = Enum.CameraType.Scriptable
	--dCam.Parent = viewport
	
	--local newCharacter = dCharacter:Clone()
	--newCharacter.Parent = viewport
	
	--viewport.CurrentCamera = dCam
	
	--newCharacter.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	--dCam.CFrame = newCharacter.Head.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 0, 2.6)
	
	createViewportModel(dialogueSpeakerCharacterVal.Value)
end)

dialogueVisibleVal:GetPropertyChangedSignal("Value"):Connect(function()
	dialogueFrame.Visible = dialogueVisibleVal.Value
end)

dialogueSpeakerVal:GetPropertyChangedSignal("Value"):Connect(function()
	if dialogueSpeakerVal == 'Kidnapper' or dialogueSpeakerVal == 'Chain' or (dialogueSpeakerVal == 'Hazel' and game.ReplicatedStorage.BadHazel.Value) then
		mainText.TextStrokeTransparency = 0
		speakerText.TextStrokeTransparency = 0
	else
		mainText.TextStrokeTransparency = 1
		speakerText.TextStrokeTransparency = 1
	end
	speakerText.Text = string.upper(dialogueSpeakerVal.Value)
end)

dialogueMessageVal:GetPropertyChangedSignal("Value"):Connect(function()
	if dialogueMessageVal.Value == 'None' then
		dialogueFrame.Visible = false
		return
	else
		dialogueFrame.Visible = true
	end
	playSound("rbxassetid://915576050")
	mainText.Text = dialogueMessageVal.Value
end)

textColorVal:GetPropertyChangedSignal("Value"):Connect(function()
	for _, label in ipairs(dialogueFrame:GetDescendants()) do
		if label:IsA("TextLabel") then
			label.TextColor3 = textColorVal.Value
		end
	end
end)

dialogueColorVal:GetPropertyChangedSignal("Value"):Connect(function()
	dialogueFrame.BackgroundColor3 = dialogueColorVal.Value
end)

cameraInterpolateEvent.OnClientEvent:Connect(function(posEnd,focusEnd,duration)
	if not player:findFirstChild("secretEnding") then
		local camera = game.Workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		
		--local CameraInfo = TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
		--local CameraTween = TweenService:Create(camera,CameraInfo,{CFrame = posEnd})
		--CameraTween:Play()

		camera:Interpolate(
			posEnd,
			focusEnd,
			duration
		)
	end
end)

cameraToPlayerEvent.OnClientEvent:Connect(function()
	local camera = game.Workspace.CurrentCamera

	repeat wait()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	until workspace.CurrentCamera.CameraType == Enum.CameraType.Custom
	
	repeat wait()
		workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
	until workspace.CurrentCamera.CameraSubject == player.Character.Humanoid
end)

local renderPriority = Enum.RenderPriority.Camera.Value - 1
local runService = game:GetService("RunService")

local function tweenParts(partA, partB, duration)
	print("Begin Lerp")
	local cfA, cfB = partA.CFrame, partB.CFrame --start and end CFrames
	local t0 = tick() --start time
	
	local c
	c = runService.RenderStepped:Connect(function()
		local t = tick()
		local a = math.min(1, (t-t0)/duration) --how much to lerp between A and B, as a number from 0 to 1
		partA.CFrame = cfA:Lerp(cfB, a)

		if a >= 1 then
			c:Disconnect()
			--a is guaranteed to reach 1, so no need to set partA.CFrame to cfB
		end
	end)
end

values.Objective:GetPropertyChangedSignal("Value"):Connect(function()
	if values.Objective.Value ~= "None" then
		script.Parent.Objective.Visible = true
		script.Parent.Objective:TweenPosition(UDim2.new(0.006, 0,0.414, 0))
	else
		script.Parent.Objective:TweenPosition(UDim2.new(-0.2, 0,0.414, 0))
		wait(1)
		script.Parent.Objective.Visible = false
	end
	
	script.Parent.Objective.Info.Text = values.Objective.Value
end)

values.Timer:GetPropertyChangedSignal("Value"):Connect(function()
	workspace.Audio.Tick:Play()
	if values.Timer.Value ~= "None" then
		script.Parent.Timer.Visible = true
		script.Parent.TimerShw.Visible = true
		script.Parent.Timer:TweenPosition(UDim2.new(0.416, 0,0.019, 0))
		script.Parent.TimerShw:TweenPosition(UDim2.new(0.416, 0,0.019, 0))
	elseif script.Parent.Timer.Position ~= UDim2.new(0.416, 0,-0.2, 0) then
		script.Parent.Timer:TweenPosition(UDim2.new(0.416, 0,-0.2, 0))
		script.Parent.TimerShw:TweenPosition(UDim2.new(0.416, 0,-0.2, 0))
		return
	end
	
	script.Parent.Timer.Dark.TextLabel.Text = values.Timer.Value
end)

values.Timer.Changed:Connect(function(new)
	if values.Timer.Value == "None" then
		wait(2)
		script.Parent.Timer.Visible = false
		script.Parent.TimerShw.Visible = false
	end
end)

game.ReplicatedStorage.Remotes.UpShake.OnClientEvent:Connect(function()
	Shaker:Start()
	
	Shaker:Shake(shakerModule.Presets.Explosion)
	
	wait(3)
	
	Shaker:Stop()
	wait(1)
	script["rock move"]:Play()
end)

game.ReplicatedStorage.Notification.OnClientEvent:Connect(function(Amount)
	game:GetService('StarterGui'):SetCore('SendNotification', {
		Title = 'Coins Earnt',
		Text = 'You got ' .. tostring(Amount) .. ' coins!',
		Icon = 'rbxassetid://6740408114'
	})
end)

game.ReplicatedStorage.TweenCamera.OnClientEvent:Connect(function(pos)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local CameraTween = TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{CFrame = pos}
	)
	
	CameraTween:Play()
end)

local PetModule = require(game.ReplicatedStorage.PetFollowModule)

game.ReplicatedStorage.ShowPet.OnClientEvent:Connect(function(PetName)
	PetModule:AddPet(game.Players.LocalPlayer,PetName)
end)

game.ReplicatedStorage.Remotes.ResetCameraAdded.OnClientEvent:Connect(function()
	wait(1)
	repeat wait()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	until workspace.CurrentCamera.CameraType == Enum.CameraType.Custom
	
	repeat wait()
		workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
	until workspace.CurrentCamera.CameraSubject == player.Character.Humanoid
end)

repeat wait() until workspace:FindFirstChild('Interaction')

wait(1)

for _, Model in ipairs(workspace.Interaction:GetChildren()) do
	spawn(function()
		local Detector = Model:WaitForChild('ClickDetector')
		Detector.MouseClick:Connect(function()
			if game.ReplicatedStorage.ItemsEnabled.Value then
				Model:Destroy()
				game.ReplicatedStorage.Remotes.ItemDone:FireServer()
			end
		end)
	end)
end


