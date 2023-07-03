local physics = game:GetService("PhysicsService")
physics:CreateCollisionGroup("npcs")
physics:CreateCollisionGroup("characters")
physics:CreateCollisionGroup('Parting')
local tweenService = game:GetService('TweenService')

physics:CollisionGroupSetCollidable("npcs","characters",false)
physics:CollisionGroupSetCollidable("npcs","npcs",false)
physics:CollisionGroupSetCollidable("characters","characters",false)
physics:CollisionGroupSetCollidable('Parting','npcs',false)
local ZonePlus = require(game.ReplicatedStorage.Modules.Zone)
local CageZone = ZonePlus.new(workspace.CageZone)
local BusZone = ZonePlus.new(workspace.BusZone)
local CaveZone = ZonePlus.new(workspace.CaveCrossZone)
local LavaZone = ZonePlus.new(workspace.LavaEndZone)

local cameraInterpolateEvent = game.ReplicatedStorage.Remotes.cameraInterpolateEvent
local cameraToPlayerEvent = game.ReplicatedStorage.Remotes.cameraToPlayerEvent

local remotes = game:GetService("ReplicatedStorage").Remotes
local hideDialogueEvent = remotes.HideDialogue
local dialogueMessageEvent = remotes.DialogueMessage
local updateViewportEvent = remotes.UpdateViewport
local randomCharacter
local randomCharacterName
local MessageValue = game.ReplicatedStorage.Values:WaitForChild('Message')
local CollectionService = game:GetService('CollectionService')

local cheerAnimation = "http://www.roblox.com/asset/?id=507770677"
local disagreeAnimation = "http://www.roblox.com/asset/?id=4841401869"
local walkAnimation = "http://www.roblox.com/asset/?id=913402848"
local idleAnimation = "http://www.roblox.com/asset/?id=507766388"
local values = game.ReplicatedStorage.Values

local waitSymbols = {'.',',','?'}

local idleControllers = {
	["Chain"] = workspace.Chain.Humanoid:LoadAnimation(script.idle);
	['Death Dollie'] = workspace.Parents.DeathDollie.Humanoid:LoadAnimation(script.idle);
	['Escapee'] = workspace.Parents.Escapee.Humanoid:LoadAnimation(script.idle);
	['Jenna'] = workspace.Jenna.Humanoid:LoadAnimation(script.idle);
	['Clown'] = workspace.Clown.Humanoid:LoadAnimation(script.idle);
}

local mainSpeakers = {
	["Chain"] = workspace.Chain;
	['Death Dollie'] = workspace.Parents.DeathDollie;
	['Escapee'] = workspace.Parents.Escapee;
	['Clown'] = workspace.Clown;
	['Jenna'] = workspace.Jenna;
	['Boss'] = workspace.HazelBoss
}

physics:SetPartCollisionGroup(workspace.BossBattle.BossBlocker,'Parting')


for index, part in ipairs(workspace.Chain:GetDescendants()) do
	if part:IsA("BasePart") then
		physics:SetPartCollisionGroup(part, "npcs")
	end
end


for index, part in ipairs(workspace.Clown:GetDescendants()) do
	if part:IsA("BasePart") then
		physics:SetPartCollisionGroup(part, "npcs")
	end
end

for index, part in ipairs(workspace.Parents.Escapee:GetDescendants()) do
	if part:IsA("BasePart") then
		physics:SetPartCollisionGroup(part, "npcs")
	end
end

for index, part in ipairs(workspace.HazelBoss:GetDescendants()) do
	if part:IsA("BasePart") then
		physics:SetPartCollisionGroup(part, "npcs")
	end
end

idleControllers.Chain:Play()

local charColors = {
	["Default"] = Color3.fromRGB(70,70,70),
	["Dummy"] = Color3.fromRGB(0,0,0)
}


local function playNpcAnimation(model,animationId)
	coroutine.wrap(function()
		local animation = Instance.new("Animation",model)
		animation.AnimationId = animationId
		local humanoid = model:findFirstChild("Humanoid")
		humanoid:LoadAnimation(animation):Play()
		wait(1)
		animation:Destroy()
	end)()
end

local function onCharacterAdded(character,plr)
	character:WaitForChild("Head")
	character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("Humanoid")
	character:WaitForChild("UpperTorso")
	
	wait(0.2)
	
	for index, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			physics:SetPartCollisionGroup(part, "characters")
		end
	end
	
	game.ReplicatedStorage.Remotes.ResetCameraAdded:FireClient(plr)
	
	local humanoid = character:WaitForChild("Humanoid")
	
	wait(1)
	
	
	if game.MarketplaceService:UserOwnsGamePassAsync(plr.UserId,61436828) then
		humanoid.MaxHealth = 150
		wait(1)
		humanoid.Health = humanoid.MaxHealth
	end
	
	if game.MarketplaceService:UserOwnsGamePassAsync(plr.UserId,18947536) then
		return
	end
	
	humanoid.BodyHeightScale.Value = 0.68
	humanoid.BodyDepthScale.Value = 0.8
	humanoid.BodyWidthScale.Value = 0.8
	humanoid.HeadScale.Value = 0.9
	humanoid.NameDisplayDistance = 0
end

local function onPlayerAdded(player)
	if player.Character then
		onCharacterAdded(player.Character,player)
	end
	
	if game.MarketplaceService:UserOwnsGamePassAsync(player.UserId,61437552) then
		script.Parent.AddMonster:Fire(player)
	end
	
	local ItemsFound = Instance.new('IntValue',player)
	ItemsFound.Name = 'ItemsFound'
	
	player.CharacterAdded:Connect(function(NewChar)
		onCharacterAdded(NewChar,player)
	end)
end

game.ReplicatedStorage.Remotes.ItemDone.OnServerEvent:Connect(function(plr)
	plr.ItemsFound.Value +=1
end)

game.Players.PlayerAdded:Connect(onPlayerAdded)

local function getRandomCharacter()
	local players = game:GetService("Players"):GetPlayers()

	repeat
		local number = math.random(1,#players)
		local randomPlayer = players[number]
		randomCharacter = randomPlayer.Character
	until randomCharacter

	randomCharacter.Archivable = true
end


local FinishedMaze = false
local PlayerWhoFoundMazeExit = ""

workspace.clue1.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if FinishedMaze == true then

		else
			FinishedMaze = true
			PlayerWhoFoundMazeExit = hit.Parent.Name
		end
	end
end)

local Finishedclue = false
local PlayerWhoFoundMazeExit = ""

workspace.clue2.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if Finishedclue == true then

		else
			Finishedclue = true
			PlayerWhoFoundMazeExit = hit.Parent.Name
		end
	end
end)


local function TypewriteMessage(Message,DialogueHideDelay)
	print('Begin Typewrite')
	for i = 1,string.len(Message) do
		MessageValue.Value = string.sub(Message,1,i)
		for _, Letter in ipairs(waitSymbols) do
			if string.sub(Message,i,i) == Letter then
				wait(1)
			end
		end
		wait(0.05)
	end
	
	if tonumber(DialogueHideDelay) then
		wait(DialogueHideDelay)
	else
		wait(3.5)
	end
	
	MessageValue.Value = 'None'
end

local function Message(speaker, msg, name, dialogueHideDelay)
	if speaker:lower() == "random" then
		getRandomCharacter()
		if name then
			values.DialogueSpeaker.Value = name
		else
			values.DialogueSpeaker.Value = randomCharacter.Name
		end
		values.DialogueSpeakerCharacter.Value = randomCharacter
	elseif mainSpeakers[speaker] then
		if name then
			values.DialogueSpeaker.Value = name
		else
			values.DialogueSpeaker.Value = mainSpeakers[speaker].Name
		end
		values.DialogueSpeakerCharacter.Value = mainSpeakers[speaker]
	elseif speaker:lower() == "previous" then
		values.DialogueSpeaker.Value = randomCharacter.Name
		values.DialogueSpeakerCharacter.Value = randomCharacter
	else
		if name then
			values.DialogueSpeaker.Value = name
		else
			values.DialogueSpeaker.Value = speaker
		end
		values.DialogueSpeakerCharacter.Value = workspace:FindFirstChild(speaker)
	end
	
	TypewriteMessage(msg, dialogueHideDelay or '')
end

local function Countdown(Start)
	for i = Start,0,-1 do
		values.Timer.Value = i
		wait(1)
	end
	wait(.2)
	values.Timer.Value = 'None'
end

local function hideDialogue()
	hideDialogueEvent:FireAllClients()
end

local function moveNPC(npc,pos)
	local maxWaitTime = 15
	local walkAnim = Instance.new("Animation")
	local idleAnim = Instance.new("Animation")
	walkAnim.AnimationId = walkAnimation
	idleAnim.AnimationId = idleAnimation
	
	if idleControllers[npc.Name] then
		idleControllers[npc.Name]:Stop()
	end
	
	local walkController = npc.Humanoid:LoadAnimation(walkAnim)
	walkController:Play()
	
	
	npc.Humanoid:MoveTo(pos.Position)
	npc.Humanoid.MoveToFinished:Wait()
	print("Stopping")
	walkController:Stop()
	
	if idleControllers[npc.Name] then
		idleControllers[npc.Name]:Play()
	end
end

local function Objective(text)
	values.Objective.Value = text
end

local function Transition()
	for _, player in ipairs(game.Players:GetPlayers()) do
		spawn(function()
			game.ServerStorage.Assets.Transition:Clone().Parent = player.PlayerGui
		end)
	end
end

local function ToMS(s)
	return ("%02i:%02i"):format(s/60%60, s%60)
end


local function TvCutscene()
	local CutceneFinished = Instance.new('BindableEvent')
	
	local LiveIn = workspace.TelevsionMain.SurfaceGui.LiveInFrame.LiveIn
	
	for _, Light in ipairs(workspace:GetDescendants()) do
		if Light:IsA('PointLight') or Light:IsA('SurfaceLight') or Light:IsA('SpotLight') then
			Light.Enabled = false
		end
	end
	
	workspace.TelevsionMain.SurfaceGui.LiveInFrame.Visible = true
	workspace.Audio.HouseTheme:Stop()
	workspace.Audio.Spooky:Play()
	
	workspace.TelevsionMain.PointLight.Enabled = true
	workspace.Audio.Power:Play()
	Message('Chain','Scary movie time!')
	
	cameraInterpolateEvent:FireAllClients(workspace.TelevsionMain.CFrame * CFrame.new(0,0,-6),workspace.TelevsionMain.CFrame,4)
	
	coroutine.resume(coroutine.create(function()
		for i = 30,0,-1 do
			local NewI = ToMS(i)
			LiveIn.Text = tostring(NewI)
			wait(1)
		end
		CutceneFinished:Fire()
	end))
	wait(4.5)
	
	Message('Random','The newest movie out right now! Explorer Elizabeth!')
	
	cameraToPlayerEvent:FireAllClients()
	Objective('Take a seat in one of the chairs.')
	Countdown(15)
	Objective('None')

	for _, Player in ipairs(game.Players:GetPlayers()) do
		coroutine.wrap(function()
			Player.Rounds.Value += 1
			Player.Character.Humanoid.WalkSpeed = 0
			Player.Character.Humanoid.JumpPower = 0
		end)()
	end
	
	CutceneFinished.Event:Wait()
	
	cameraInterpolateEvent:FireAllClients(workspace.TelevsionMain.CFrame * CFrame.new(0,0,-6),workspace.TelevsionMain.CFrame,4)
	workspace.TelevsionMain.SurfaceGui.LiveInFrame.Visible = false
	workspace.TelevsionMain.SurfaceGui.VideoFrame.Visible = true
	workspace.TelevsionMain.SurfaceGui.VideoFrame:Play()
	wait(3)
	workspace.Audio.Spooky:Stop()
	workspace.Audio.Tension:Play()
	wait(.5)
	workspace.TelevsionMain.SurfaceGui.VideoFrame:Pause()
	workspace.TelevsionMain.SurfaceGui.EmergencyCastFrame.Visible = true
	wait(2)
	workspace.TelevsionMain.SurfaceGui.MF1:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,1)
	for _, Player in ipairs(game.Players:GetPlayers()) do
		local PlayerVote = Instance.new('IntValue',game.ReplicatedStorage.PlayerList)
		PlayerVote.Name = Player.Name
	end
	Message('Elizabeth','I am Explorer Elizabeth. I am announcing the end of Roblox on JULY 1ST!')
	Message('Elizabeth','Starting today, I will be banning ROBLOXians until I\'m the last alive!')
	Message('Elizabeth','If you think this movie is a joke... let me show you!')
	cameraToPlayerEvent:FireAllClients()
	Message('Elizabeth','Pick a friend of yours!')
	game.Workspace.livingseats:Destroy()
	game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.Home
	if #game.Players:GetPlayers() >= 1 then
		for _, Player in ipairs(game.Players:GetPlayers()) do
			spawn(function()
				game.ServerStorage.Assets.VotingUI:Clone().Parent = Player.PlayerGui
			end)
		end
		Countdown(10)
		for _, Player in ipairs(game.Players:GetPlayers()) do
			spawn(function()
				if Player.PlayerGui:FindFirstChild('VotingUI') then
					Player.PlayerGui.VotingUI:Destroy()
				end
			end)
		end
		local ChosenKick = game.ReplicatedStorage.PlayerList:GetChildren()[1]
		for _, PlayerVote in ipairs(game.ReplicatedStorage.PlayerList:GetChildren()) do
			if PlayerVote.Value > ChosenKick.Value then
				ChosenKick = PlayerVote
			end
		end
		ChosenKick = game.Players:FindFirstChild(ChosenKick.Name)
		if ChosenKick then
			Message('Elizabeth',('Congrats %s, you have been chosen to get banned!'):format(ChosenKick.Name))
			pcall(function()
				ChosenKick.Character.Humanoid.Jump = true
				ChosenKick.Character.HumanoidRootPart.CFrame = workspace.kickedteleport.CFrame * CFrame.new(0,1,0)
			end)
		end
	end
	coroutine.resume(coroutine.create(function()
		wait(1)

	end))
	cameraInterpolateEvent:FireAllClients(workspace.trapcam.CFrame,workspace.trapfocus.CFrame,4)
	for _, Player in ipairs(game.Players:GetPlayers()) do
		spawn(function()
			if Player.Character and Player.Character.Humanoid.Health > 0 then
				local humanoid = Player.Character.Humanoid
				if humanoid.SeatPart then
					-- Delay a restore original seat position...
					local seatPart = humanoid.SeatPart
					local originalSeatCFrame = seatPart.CFrame

					delay(4, function()
						seatPart.CFrame = originalSeatCFrame
					end)

					-- Do a futile attempt to unseat the player
					humanoid.SeatPart:Sit(nil)
					humanoid.Sit = false
					humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
				end
			end
		end)
	end
	wait(6)
	game.Workspace.trap1.CanCollide = false
	game.Workspace.trap2.CanCollide = false
	game.Workspace.trap3.CanCollide = false
	game.Workspace.trap4.CanCollide = false
	wait(3)
	game.Workspace.trap1.CanCollide = true
	game.Workspace.trap2.CanCollide = true
	game.Workspace.trap3.CanCollide = true
	game.Workspace.trap4.CanCollide = true
	for _, Player in ipairs(game.Players:GetPlayers()) do
		coroutine.wrap(function()
			if Player.Character and Player.Character.Humanoid.Health > 0 then
				Player.Character.Humanoid.JumpPower = 50
				Player.Character.Humanoid.WalkSpeed = 16
			end
		end)()
	end
	Message('Elizabeth','Now you are all NEXT!')
	wait()
	game.ServerStorage.Assets.Monster:Clone().Parent = workspace
	game.ServerStorage.Assets.ParticlePart:Clone().Parent = workspace
	workspace.Monster.PrimaryPart.Anchored = false
	workspace.ParticlePart.CFrame = workspace.Monster.PrimaryPart.CFrame
	workspace.ParticlePart.Anchored = true
	cameraInterpolateEvent:FireAllClients(
		workspace.Monster.Head.CFrame * CFrame.new(0,0,-4),
		workspace.Monster.Head.CFrame,
		5
	)
	
	
	
	workspace.Monster:Destroy()
	for _, Emitter in ipairs(workspace.ParticlePart:GetChildren()) do
		if Emitter:IsA('ParticleEmitter') then
			Emitter.Enabled = false
		end
	end
	workspace.ParticlePart:Destroy()
	game.ServerStorage.Assets.Monster:Clone().Parent = workspace
	game.ServerStorage.Assets.ParticlePart:Clone().Parent = workspace
	workspace.Monster.PrimaryPart.Anchored = false
	workspace.Monster.PrimaryPart.CFrame = workspace.Monster.PrimaryPart.CFrame * CFrame.new(0,0,-1)
	workspace.ParticlePart.CFrame = workspace.Monster.PrimaryPart.CFrame
	workspace.ParticlePart.Anchored = true
	wait()
	Message('Random','SHE\'S REAL! RUN!!!')
	wait(4)
	workspace.Audio.Tension:Stop()
	cameraToPlayerEvent:FireAllClients()
	workspace.Audio.Invisible:Play()
	workspace.Monster:Destroy()
	workspace.ParticlePart:Destroy()
	workspace.Scary:Stop()
	script.Parent.MonsterLogic.Disabled = false
	script.Parent.EnageFight.Value = true
	script.Parent.FlickerLights.Value = true
	wait(workspace.Audio.Invisible.TimeLength - 6.5)
	script.Parent.FlickerLights.Value = false
	script.Parent.ResetPlayer:Fire()
	wait(.4)
	script.Parent.MonsterLogic.Disabled = true
	if workspace:FindFirstChild('Monster') then
		workspace.Monster:Destroy()
	end

	workspace.Audio.Invisible:Stop()
	workspace.Audio.Recovery:Play()

	if workspace:FindFirstChild('ParticlePart') then
		workspace.ParticlePart:Destroy()
	end

	wait(1)

	for _, Light in ipairs(workspace:GetDescendants()) do
		if Light:IsA('PointLight') or Light:IsA('SurfaceLight') or Light:IsA('SpotLight') then
			Light.Enabled = true
		end
	end
	cameraToPlayerEvent:FireAllClients()

	Message('Elizabeth','Hahaha! That\'s just a little taste of what\'s to come.')
	
	Message('Elizabeth','If you wish to find me, look for the first clue in the forest... see you soon! :)')
	for _, frame in ipairs(workspace.TelevsionMain.SurfaceGui:GetChildren()) do
		frame.Visible = false
	end
	workspace.TelevsionMain.SurfaceGui.VideoFrame.Visible = true
	workspace.TelevsionMain.SurfaceGui.VideoFrame:Play()
	delay(5, function()
		workspace.TelevsionMain.SurfaceGui.VideoFrame:Pause()
		workspace.TelevsionMain.SurfaceGui.VideoFrame.Visible = false
	end)
	for _, Player in ipairs(game.Players:GetPlayers()) do
		if Player.Character and Player.Character.Humanoid.Health > 0 then
			Player.Character.Humanoid.WalkSpeed = 16
			Player.Character.Humanoid.JumpPower = 50
		end
	end
end







-----------------------------------------------------------------------------------------------------------------------------------

workspace.Audio.MainTheme:Play()
wait(21)

for _, Player in ipairs(game.Players:GetPlayers()) do
	pcall(function()
		game.BadgeService:AwardBadge(Player.UserId,2127389935)
	end)
end

print('Starting Story')



--cameraInterpolateEvent:FireAllClients(workspace.Chain.Head.CFrame * CFrame.new(0,0,-6),workspace.Chain.Head.CFrame,4)
--wait(2.8)
--playNpcAnimation(workspace.Chain, cheerAnimation)
--Message('Random','Thank you guys for coming out to the woods.. I\'ll get straight to the point.')
--Message('Random', 'Why do we need to be so secretive?')
--cameraToPlayerEvent:FireAllClients()
--Message('Chain','Everyone take a seat, I\'ll explain what\'s going on.')
Transition()
wait(3)
-- SCARY MUSIC INSERT FOOTNOTE

for _, Player in ipairs(game.Players:GetPlayers()) do
	coroutine.wrap(function()
	Player.Character.Humanoid.WalkSpeed = 0
	Player.Character.Humanoid.JumpPower = 0
	end)()
end
alltableseats = game.Workspace.InsideCastle["Long Table and Chairs"].Seats:GetChildren()
game.Workspace.InsideCastle["Long Table and Chairs"].ChainSeat:Sit(game.Workspace.Chain.Humanoid)
--game.Workspace.InsideCastle["Long Table and Chairs"].KingSeat:Sit(game.Workspace.King.Humanoid) for second character to sit

for i, player in ipairs(game.Players:GetChildren()) do
	local randomseat = math.random(1, #alltableseats)
	alltableseats[randomseat]:Sit(player.Character.Humanoid)
	table.remove(alltableseats, randomseat)

	--game.ServerStorage.Assets.Apple:Clone().Parent = player.Backpack
	--game.ServerStorage.Assets.TurkeyLeg:Clone().Parent = player.Backpack
end

--workspace.InsideCastle["Long Table and Chairs"].ChainSeat:Sit(workspace.Chain.Humanoid)
--workspace.InsideCastle["Long Table and Chairs"].KingSeat:Sit(workspace.King.Humanoid)

wait(1)
cameraInterpolateEvent:FireAllClients(workspace.CamDoorPart.CFrame,workspace.DoorFocus.CFrame,1)
Message('Chain','Thank you everyone for coming! We are in great danger.')
cameraInterpolateEvent:FireAllClients(workspace.CamDoorPart2.CFrame,workspace.DoorFocus.CFrame,8)
Message('Chain','Death Dollie, a new monster has returned to ROBLOX.')
cameraInterpolateEvent:FireAllClients(workspace.CamDoorPart3.CFrame,workspace.DoorFocus.CFrame,8)
Message('Chain','It\'s said that she is the strongest hacker on ROBLOX. She even hacked Jenna the Hacker and Elizabeth..')
cameraToPlayerEvent:FireAllClients()
Message('Random','So why are we here in the woods?')
Message('Chain','Death Dollie can\'t find us if we are hiding! We don\'t want to get involved.')


cameraInterpolateEvent:FireAllClients(workspace.frontdoorcam.CFrame,workspace.frontdoorcamfocus.CFrame,1)
workspace.Audio.doorknockin:Play()
Message('Random','Someone\'s at the door, how\'d they find us!?')
game.Workspace.Chain.Humanoid.Jump = true
moveNPC(workspace.Chain, workspace.HazelPart1)
moveNPC(workspace.Chain, workspace.HazelPart2)
wait(.5)
game.Workspace.InsideCastle.cabindoor1.Parent = game.ServerStorage
Message('Chain','Hello?')
cameraInterpolateEvent:FireAllClients(workspace.footprintcam.CFrame,workspace.footprintfocus.CFrame,3)
Message('Random','There\'s footprints! Chain we got to follow them!')
cameraToPlayerEvent:FireAllClients()
Message('Chain','Fine, follow me but stay BEHIND ME!')
workspace.Audio.MainTheme:Stop()
workspace.Audio.walkinwoods:Play()
for _, Player in ipairs(game.Players:GetPlayers()) do
	coroutine.wrap(function()
		Player.Character.Humanoid.WalkSpeed = 16
		Player.Character.Humanoid.JumpPower = 50
	end)()
end
workspace.woundedseat:Sit(game.Workspace.woundedperson.Humanoid)
Objective('Follow Chain!')
game.ReplicatedStorage.Remotes.PathBeam:FireAllClients()
moveNPC(workspace.Chain, workspace.HazelPart3)
wait()
moveNPC(workspace.Chain, workspace.HazelPart4)
wait(2.5)
moveNPC(workspace.Chain, workspace.HazelPart5)
wait()
moveNPC(workspace.Chain, workspace.HazelPart6)
wait()
moveNPC(workspace.Chain, workspace.HazelPart7)
wait()
moveNPC(workspace.Chain, workspace.HazelPart8)
wait()
moveNPC(workspace.Chain, workspace.HazelPart9)
wait()
moveNPC(workspace.Chain, workspace.HazelPart10)
game.ReplicatedStorage.Remotes.RemoveBeam:FireAllClients()
Objective('None')
wait()
for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		if Player.Character and Player.Character.Humanoid.Health > 0 then
			local humanoid = Player.Character.Humanoid
			if humanoid.SeatPart then
				-- Delay a restore original seat position...
				local seatPart = humanoid.SeatPart
				local originalSeatCFrame = seatPart.CFrame

				delay(4, function()
					seatPart.CFrame = originalSeatCFrame
				end)

				-- Do a futile attempt to unseat the player
				humanoid.SeatPart:Sit(nil)
				humanoid.Sit = false
				humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
			end
			Player.Character.HumanoidRootPart.CFrame = workspace.forestteleport.CFrame * CFrame.new(math.random(-2.5,2.5),0,math.random(-2,2))
			Player.Character.Humanoid.WalkSpeed = 16
			Player.Character.Humanoid.JumpPower = 50
			--workspace.Chain:SetPrimaryPartCFrame(workspace.hazelforest.CFrame * CFrame.new(0,1,0))
		end
	end)
end
workspace.Audio.walkinwoods:Stop()
workspace.Audio.wounded:Play()
game.ServerStorage.dolliebarrier.Parent = game.Workspace
wait()
cameraInterpolateEvent:FireAllClients(workspace.hammercam.CFrame,workspace.hammerfocus.CFrame,2)
Message('Escapee','Help! She\'s here! DEATH DOLLIE is after me!')
Message('Escapee','I escaped her factory! She trapped so many people in there and is experimenting on them!')
Message('Escapee','You have to help me! Her factory is a nightmare!')
cameraInterpolateEvent:FireAllClients(workspace.hammercam2.CFrame,workspace.hammerfocus.CFrame,2)
workspace.ChainHammer.Transparency = 0
local HammerTween = game.TweenService:Create(workspace.ChainHammer, TweenInfo.new(1.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, false, 0), {CFrame = workspace.FakeHammer.CFrame})
HammerTween:Play()
wait(0.75)
spawn(function()
	wait(0.075)
	game.Lighting.Blur.Size = 7.5
	game.TweenService:Create(game.Lighting.Blur, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0), {Size = 1}):Play()
end)
HammerTween:Destroy()
for i, v in pairs(game.Workspace.woundedperson:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CanCollide = false
	end
end
workspace.ChainHammer.CanCollide = true
workspace.ChainHammer.Anchored = false
game.ReplicatedStorage.Events.ShakeCamera:FireAllClients('SlowMo')
game.Workspace.woundedperson.Head.Particles.Enabled = true
workspace.Gravity = 5
workspace["Hit by bat 2"]:Play()
game.Workspace.woundedperson.RagdollR15.Activate.Value = true
wait(1)
game.Workspace.woundedperson.Head.Particles.Enabled = false
wait(0.5)
wait(2)
for i, v in pairs(game.Workspace.woundedperson:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CanCollide = true
	end
end
wait(1)
workspace.Gravity = 196
game.Workspace.woundedperson:FindFirstChildOfClass('BodyColors'):Destroy()
game.ReplicatedStorage.BodyColors:Clone().Parent = game.Workspace.woundedperson
game.Workspace.woundedperson.Head.face:Destroy()
game.Workspace.woundedperson.Head.BillboardGui:Destroy()
for i, v in pairs(game.Workspace.woundedperson:GetDescendants()) do
	if v:IsA('BasePart') then
		v.Material = Enum.Material.ForceField
		v.CanCollide = false
		v.Anchored = true
		game:GetService("TweenService"):Create(v, TweenInfo.new(6, Enum.EasingStyle.Sine), {Position = v.Position + Vector3.new(0, 20, 0), Transparency = 1, Orientation = v.Orientation + Vector3.new(115, 160, 141)}):Play()
	end
end
cameraToPlayerEvent:FireAllClients()
Message('Random','WHAT JUST HAPPENED!')
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.banhammer


wait()
game.ServerStorage.Assets.Monster:Clone().Parent = workspace
game.ServerStorage.Assets.ParticlePart:Clone().Parent = workspace
workspace.Monster.PrimaryPart.Anchored = false
workspace.ParticlePart.CFrame = workspace.Monster.PrimaryPart.CFrame
workspace.ParticlePart.Anchored = true
cameraInterpolateEvent:FireAllClients(workspace.chasecam.CFrame,workspace.chasefocus.CFrame,5)
Message('Death Dollie','I happened...')
Message('Death Dollie','and I WILL have my revenge!')
wait()

cameraToPlayerEvent:FireAllClients()
Objective('Run from Death Dollie!')
workspace.Monster:Destroy()
for _, Emitter in ipairs(workspace.ParticlePart:GetChildren()) do
	if Emitter:IsA('ParticleEmitter') then
		Emitter.Enabled = false
	end
end
workspace.ParticlePart:Destroy()
game.ServerStorage.Assets.Monster:Clone().Parent = workspace
game.ServerStorage.Assets.ParticlePart:Clone().Parent = workspace
workspace.Monster.PrimaryPart.Anchored = false
workspace.Monster.PrimaryPart.CFrame = workspace.Monster.PrimaryPart.CFrame * CFrame.new(0,0,-1)
workspace.ParticlePart.CFrame = workspace.Monster.PrimaryPart.CFrame
workspace.ParticlePart.Anchored = true
wait()
Message('Random','SHE\'S REAL! RUN!!!')
wait(4)
workspace.Audio.wounded:Stop()
workspace.Audio.Invisible:Play()
workspace.Monster:Destroy()
workspace.ParticlePart:Destroy()
workspace.Scary:Stop()
script.Parent.MonsterLogic.Disabled = false
script.Parent.EnageFight.Value = true
script.Parent.FlickerLights.Value = true
wait(workspace.Audio.Invisible.TimeLength - 6.5)
script.Parent.FlickerLights.Value = false
script.Parent.ResetPlayer:Fire()
wait(.4)
script.Parent.MonsterLogic.Disabled = true
if workspace:FindFirstChild('Monster') then
	workspace.Monster:Destroy()
end

workspace.Audio.Invisible:Stop()
workspace.Audio.Recovery:Play()

if workspace:FindFirstChild('ParticlePart') then
	workspace.ParticlePart:Destroy()
end

wait(1)

for _, Light in ipairs(workspace:GetDescendants()) do
	if Light:IsA('PointLight') or Light:IsA('SurfaceLight') or Light:IsA('SpotLight') then
		Light.Enabled = true
	end
end
Objective('None')

Message('Death Dollie','I\'ll let you live, but STAY AWAY from my factory or else...')
Message('Random','Chain, we have to find her factory and stop those experiments!')
Message('Chain','I think I know where it is, follow me but stay quiet!')
Transition()
wait()
workspace.Audio.Recovery:Stop()
workspace.Audio.forestnight:Play()
game.Lighting.Ambient = Color3.fromRGB(50,50,50)
game.Lighting.Brightness = .5
game.Lighting.EnvironmentSpecularScale = 0
game.Lighting.EnvironmentDiffuseScale = 0
game.Lighting.OutdoorAmbient = Color3.fromRGB(50,50,50)
wait(2)
for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		if Player.Character and Player.Character.Humanoid.Health > 0 then
			local humanoid = Player.Character.Humanoid
			if humanoid.SeatPart then
				-- Delay a restore original seat position...
				local seatPart = humanoid.SeatPart
				local originalSeatCFrame = seatPart.CFrame

				delay(4, function()
					seatPart.CFrame = originalSeatCFrame
				end)

				-- Do a futile attempt to unseat the player
				humanoid.SeatPart:Sit(nil)
				humanoid.Sit = false
				humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
			end
			Player.Character.HumanoidRootPart.CFrame = workspace.experiments.CFrame * CFrame.new(math.random(-2.5,2.5),0,math.random(-2,2))
			Player.Character.Humanoid.WalkSpeed = 16
			Player.Character.Humanoid.JumpPower = 50
			workspace.Chain:SetPrimaryPartCFrame(workspace.chainexp.CFrame * CFrame.new(0,1,0))
			moveNPC(workspace.Chain, workspace.HazelPart11)
		end
	end)
end
Message('Chain','Follow my lead guys, and be QUIET!')
game.Workspace.factorydoor1:Destroy()
moveNPC(workspace.Chain, workspace.HazelPart12)
wait()
moveNPC(workspace.Chain, workspace.HazelPart13)
wait()
moveNPC(workspace.Chain, workspace.HazelPart14)
cameraInterpolateEvent:FireAllClients(workspace.jennacam1.CFrame,workspace.jennafocus.CFrame,5)
Message('Random','Is that Jenna... the hacker? What\'s she doing here!?')
Message('Chain','We can\'t hear her, the microphone is broken!')
cameraToPlayerEvent:FireAllClients()
Message('Chain','Quick, find batteries so we can turn the microphone on to talk to her!')


Objective('Batteries Found: 0/10 🔋')

for _, Player in ipairs(game.Players:GetPlayers()) do
	if Player.Character and Player.Character.Humanoid.Health > 0 then
		Player.Character.Humanoid.WalkSpeed = 16
		Player.Character.Humanoid.JumpPower = 50
	end
end

local LolliesFound = 0

for i = 1,10 do
	coroutine.wrap(function()
		local NewLolly = game.ServerStorage.Assets.Lollipop:Clone()
		local ChosenSpawn

		repeat 
			wait()
			ChosenSpawn = workspace.LolipopSpawns:GetChildren()[math.random(1,#workspace.LolipopSpawns:GetChildren())]
		until not CollectionService:HasTag(ChosenSpawn,'LollyTaken')

		CollectionService:AddTag(ChosenSpawn,'LollyTaken')

		NewLolly.Parent = workspace.LollyStorage
		NewLolly:SetPrimaryPartCFrame(ChosenSpawn:GetPrimaryPartCFrame())

		NewLolly.PrimaryPart.ClickDetector.MouseClick:Connect(function(Player)
			NewLolly.PrimaryPart.ClickDetector:Destroy()
			LolliesFound += 1
			Objective(('Batteries Found: %s/10 🔋'):format(tostring(LolliesFound)))
			for _, part in ipairs(NewLolly:GetDescendants()) do
				if part:IsA('BasePart') then
					tweenService:Create(part,TweenInfo.new(.2),{Transparency = 1}):Play()
				end
			end
			game:GetService('Debris'):AddItem(NewLolly,1)
		end)

		for _, Part in ipairs(NewLolly:GetChildren()) do
			if Part:IsA('BasePart') then
				Part.Touched:Connect(function(Hit)
					local plr = game.Players:GetPlayerFromCharacter(Hit.Parent)
					if plr then
						NewLolly.PrimaryPart.ClickDetector:Destroy()
						LolliesFound += 1
						Objective(('Batteries Found: %s/10 🔋'):format(tostring(LolliesFound)))
						for _, part in ipairs(NewLolly:GetDescendants()) do
							if part:IsA('BasePart') then
								tweenService:Create(part,TweenInfo.new(.2),{Transparency = 1}):Play()
							end
						end
						game:GetService('Debris'):AddItem(NewLolly,1)
					end
				end)
			end
		end
	end)()
end

repeat wait()

until LolliesFound >= 10

workspace.Audio.Success:Play()
Objective('None')
workspace.LollyStorage:ClearAllChildren()

wait(1)

Message('Chain','We found them all! Now we can hear her!')
cameraInterpolateEvent:FireAllClients(workspace.jennacam2.CFrame,workspace.jennafocus.CFrame,2)
Message('Jenna','YES! It\'s me Jenna! Death Dollie captured me and is attacking every other hacker on ROBLOX!')
cameraToPlayerEvent:FireAllClients()
Message('Random','Wait... does that mean Death Dollie is good?')
Message('Jenna','NO! She is evil still, she just wants to be the ONLY hacker!')
Message('Jenna','She\'s knows you\'re here, you have to escape! Go through the gates!')
cameraInterpolateEvent:FireAllClients(workspace.gatecam.CFrame,workspace.gatefocus.CFrame,8)
wait(1)
local TweenService = game:GetService("TweenService")
local escaperoot = workspace.escapedoor1
local upity = TweenInfo.new()

local escapeup = TweenService:Create(escaperoot, upity, {
	CFrame = escaperoot.CFrame * CFrame.new(0, (escaperoot.Size.Y) + (escaperoot.Size.Y), 0)
})

if 1 == 1 then
	escapeup:Play()
	wait(1)
end
Message('Random','There! The door is open! Go!')
workspace.Audio.forestnight:Stop()
workspace.Audio.obbyintense:Play()
cameraInterpolateEvent:FireAllClients(workspace.obby1cam.CFrame,workspace.obby1focus.CFrame,3)
Message('Chain','No! It\'s an obby.. we have no choice, COMPLETE THE OBBY!')
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.firstobbyend
cameraToPlayerEvent:FireAllClients()
game.Workspace.Obby1blocker:Destroy()
Objective('Complete the Obby!')
workspace.Chain:SetPrimaryPartCFrame(workspace.forestteleport.CFrame * CFrame.new(0,1,0))
Countdown(35)
Objective('None')
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.mobfight
game.ServerStorage.obby1lava.Parent = game.Workspace

Transition()
wait(2)
workspace.Audio.obbyintense:Stop()
workspace.Audio.mobfight2:Play()
for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		if Player.Character and Player.Character.Humanoid.Health > 0 then
			local humanoid = Player.Character.Humanoid
			if humanoid.SeatPart then
				-- Delay a restore original seat position...
				local seatPart = humanoid.SeatPart
				local originalSeatCFrame = seatPart.CFrame

				delay(4, function()
					seatPart.CFrame = originalSeatCFrame
				end)

				-- Do a futile attempt to unseat the player
				humanoid.SeatPart:Sit(nil)
				humanoid.Sit = false
				humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
			end
			Player.Character.HumanoidRootPart.CFrame = workspace.scifitp.CFrame * CFrame.new(math.random(-2.5,2.5),0,math.random(-2,2))
			Player.Character.Humanoid.WalkSpeed = 16
			Player.Character.Humanoid.JumpPower = 50
			workspace.Chain:SetPrimaryPartCFrame(workspace.chainscifi.CFrame * CFrame.new(0,1,0))
		end
	end)
end
wait(3.8)
Message('Random','Where are we?!.')
Message('Random','It looks like Death Dollie\'s world, did we teleport to a new universe?')
cameraInterpolateEvent:FireAllClients(workspace.mobcam.CFrame,workspace.mobfocus.CFrame,2)
wait(1)
game.Workspace.firstdoormob:Destroy()
Message('Random','Look! It\'s Death Dollie\'s minions!')
Message('Chain','Prepare to fight! We were MADE FOR THIS!')
cameraToPlayerEvent:FireAllClients()
game.Workspace.stayminion:Destroy()
game.ServerStorage.Assets.Minion1.Parent = workspace
game.ServerStorage.Assets.Minion2.Parent = workspace
Objective('Fight Death Dollie\'s Minions!')
repeat wait()

until game.ReplicatedStorage.ClownsDead.Value >= 2

Objective('None')
Message('Random','We did it! Let\'s follow the tunnel and stop Death Dollie!')
Transition()
workspace.Audio.mobfight2:Stop()
workspace.Audio.cameratime:Play()
wait(1)
cameraInterpolateEvent:FireAllClients(workspace.surveycam.CFrame,workspace.surveyfocus.CFrame,1)
wait(3)
Message('Death Dollie','Grrr! They are getting closer... I have to set up more defenses!')
Message('Death Dollie','If that doesn\'t work, I\'ll have to finish them myself!')
Transition()
wait(2)
cameraToPlayerEvent:FireAllClients()
workspace.Audio.cameratime:Stop()
workspace.Audio.twoholes:Play()
for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		if Player.Character and Player.Character.Humanoid.Health > 0 then
			local humanoid = Player.Character.Humanoid
			if humanoid.SeatPart then
				-- Delay a restore original seat position...
				local seatPart = humanoid.SeatPart
				local originalSeatCFrame = seatPart.CFrame

				delay(4, function()
					seatPart.CFrame = originalSeatCFrame
				end)

				-- Do a futile attempt to unseat the player
				humanoid.SeatPart:Sit(nil)
				humanoid.Sit = false
				humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
			end
			Player.Character.HumanoidRootPart.CFrame = workspace.holetps.CFrame * CFrame.new(math.random(-2.5,2.5),0,math.random(-2,2))
			Player.Character.Humanoid.WalkSpeed = 16
			Player.Character.Humanoid.JumpPower = 50
			workspace.Chain:SetPrimaryPartCFrame(workspace.chainholetp.CFrame * CFrame.new(0,1,0))
		end
	end)
end
wait(3.8)
Message('Chain','Ugh! It looks like we\'re still in Death Dollie\'s world.. we need to get out!')
cameraInterpolateEvent:FireAllClients(workspace.holecamera.CFrame,workspace.holefocus.CFrame,3)
Message('Chain','I see 2 holes, maybe one of them leads back to the real world!')
Message('Chain','Choose wisely!')
cameraToPlayerEvent:FireAllClients()
game.Workspace.holeinwall:Destroy()
Objective('Choose a hole and jump in!')
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.BeforeObby
Countdown(15)
Objective('None')
workspace.Audio.twoholes:Stop()
workspace.Audio.intense12:Play()
game.ServerStorage.twoholelava.Parent = game.Workspace
Message('Chain','Of course there is another obby! This has to lead us back to our world!')
cameraInterpolateEvent:FireAllClients(workspace.obbycam2.CFrame,workspace.obbyfocus2.CFrame,6)
Message('Random','This better bring us back, Death Dollie could be hacking someone right now!')
cameraToPlayerEvent:FireAllClients()
Objective('Cross the Underworld\'s obby!')
game.Workspace.ObbyBlocker:Destroy()
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.AfterObby
Countdown(30)
Objective('None')
game.ServerStorage.underworldlava.Parent = game.Workspace
Message('Random','I think we finally made it, we are about to fight Death Dollie...')
Message('Chain','Are you kids ready to become heroes? Let\'s do this!')
Transition()
wait(1.5)
workspace.Audio.intense12:Stop()
workspace.Audio.Action:Play()
game.Lighting.Brightness = 1
game.Lighting.Ambient = Color3.fromRGB(100,100,100)
game.Lighting.EnvironmentDiffuseScale = 1
game.Lighting.EnvironmentSpecularScale = 1
game.Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
game.Lighting.TimeOfDay = '14:30:00'
for _, Player in ipairs(game.Players:GetPlayers()) do
	if Player.Character and Player.Character.Humanoid.Health > 0 then
		Player.Character:SetPrimaryPartCFrame(workspace.RoofTeleport.CFrame * CFrame.new(math.random(-10,10),0,math.random(10,10)))
	end
end
game.ReplicatedStorage.RespawnPoint.Value = workspace.RespawnPoints.BossBattle
game:GetService('RunService').Heartbeat:Wait()
--workspace.Hazel:SetPrimaryPartCFrame(workspace.HazelRoofTeleport.CFrame)
wait(8)
game.ReplicatedStorage.Remotes.UpShake:FireAllClients()
wait(2)
--cameraInterpolateEvent:FireAllClients(
--	workspace.HazelBoss.Head.CFrame * CFrame.new(0,0,-10),
--	workspace.HazelBoss.Head.CFrame,
--	5
--)
game.ReplicatedStorage.TweenCamera:FireAllClients(workspace.HazelBoss.Head.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 0, 20))
wait(4.8)
Message('Death Dollie','I told you guys to stay away from my factory!')
Message('Death Dollie','Now you will pay with your LIVES!')
Message('Random','We\'ll see about that you monster!')
wait(.1)
cameraToPlayerEvent:FireAllClients()
workspace.HazelBoss.Humanoid:MoveTo(workspace.HazelBossMove.Position)
Objective('Beat the boss Death Dollie!')
script.Parent.BossFight.Disabled = false
for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		game.ServerStorage.BossHealth:Clone().Parent = Player.PlayerGui
	end)
end

local BossDead = false

workspace.HazelBoss.Humanoid.Died:Connect(function()
	BossDead = true
end)

repeat wait() until BossDead == true

for _, Player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		if Player.PlayerGui:FindFirstChild('BossHealth') then
			Player.PlayerGui.BossHealth:Destroy()
		end
	end)
end

script.Parent.BossFight.Disabled = true
if workspace:FindFirstChild('Lava') then
	workspace.Lava:Destroy()
end
if workspace:FindFirstChild('Target') then
	workspace.Target:Destroy()
end
workspace.BossBattle:Destroy()
workspace.HazelBoss:Destroy()
workspace.DeathDollie:SetPrimaryPartCFrame(workspace.HazelRoofTeleport.CFrame + Vector3.new(0,3,0))
workspace.Audio.Action:Stop()
workspace.Audio.bossdefeat:Play()
Objective('None')
workspace.Platforms:Destroy()
wait(1)
cameraInterpolateEvent:FireAllClients(workspace.bosscam1.CFrame,workspace.DeathDollie.Head.CFrame,4)
wait(3.8)
Message('Death Dollie','I can\'t believe it... you guys defeated the most powerful hacker ever in ROBLOX.. ME!')
Message('Death Dollie','All I wanted was revenge on one person! You guy\'s took that from me!')
Message('Random','It wasn\'t worth it Death Dollie, let it go!')
Message('Death Dollie','I have a deal for you..')
wait(1.5)
Message('Death Dollie','You let me hack one last person, then I\'ll stop forever.. or..')
Message('Death Dollie','You put me in Jail, but I\'ll have my friends attack you in the future!')
cameraToPlayerEvent:FireAllClients()
game.ReplicatedStorage.Remotes.togglePollEvent:FireAllClients(true)
wait(10)
game.ReplicatedStorage.Remotes.togglePollEvent:FireAllClients(false)

local Ending

if game.ReplicatedStorage.Poll.Option1.Value >= game.ReplicatedStorage.Poll.Option2.Value then
	Ending = 'Bad'
elseif game.ReplicatedStorage.Poll.Option1.Value < game.ReplicatedStorage.Poll.Option2.Value then
	Ending = 'Good'
end

print('Ending is:', Ending)

if Ending == 'Bad' then
	workspace.Audio.bossdefeat:Stop()
	workspace.Audio.badone:Play()
	Message('Random','Fine, we will let you hack one last person. But NO MORE AFTER!')
	wait(.5)
	Transition()
	wait(1)
	cameraInterpolateEvent:FireAllClients(workspace.surveycam.CFrame,workspace.surveyfocus.CFrame,1)
	game.Workspace.cameraroom.dolliesurvey:Destroy()
	game.ServerStorage.dolliesurvey2.Parent = game.Workspace
	wait(3.5)
	Message('Death Dollie','Fools, NEVER trust a hacker. Who did I use my last hack on? YOU! ..')
	wait(.5)
	Message('Death Dollie','Now I can take over ROBLOX FOREVER!')
	wait(.2)
	Transition()
	wait(1)
	cameraToPlayerEvent:FireAllClients()
	game.ReplicatedStorage.Remotes.EndingScene:FireAllClients()

	local MPS = game:GetService('MarketplaceService')
	local Amount = 100
	local BS = game:GetService('BadgeService')

	for _, Player in ipairs(game.Players:GetPlayers()) do
		Player.Wins.Value += 1
		pcall(function()
			BS:AwardBadge(Player.UserId,2127389930)
		end)
		if Player:FindFirstChild('Coins') then
			local AmountGiven = 100
			if not MPS:UserOwnsGamePassAsync(Player.UserId,61438086) then
				Player.Coins.Value += Amount
				AmountGiven = Amount
			else
				Player.Coins.Value += Amount * 2
				AmountGiven = Amount * 2
			end
			game.ReplicatedStorage.Notification:FireClient(Player,AmountGiven)
		end
	end
else

	workspace.Audio.bossdefeat:Stop()
	workspace.Audio.goodending:Play()
	Message('Random','Every player is worth protecting! We will risk our own accounts to protect ROBLOXians!')
	wait(1)
	Message('Death Dollie','Please... it will be worth it in the long run.')
	wait()
	wait(.8)
	Message('Random','Nope! The cops are already on their way. Goodbye forever! :)')
	Transition()
	wait(1.5)
	game.ReplicatedStorage.Remotes.EndingScene:FireAllClients()

	local MPS = game:GetService('MarketplaceService')
	local BS = game:GetService('BadgeService')
	local Amount = 100


	for _, Player in ipairs(game.Players:GetPlayers()) do
		Player.Wins.Value += 1
		pcall(function()
			BS:AwardBadge(Player.UserId,2127389926)
		end)
		if Player:FindFirstChild('Coins') then
			local AmountGiven = 100
			if not MPS:UserOwnsGamePassAsync(Player.UserId,61438086) then
				Player.Coins.Value += Amount
				AmountGiven = Amount
			else
				Player.Coins.Value += Amount * 2
				AmountGiven = Amount * 2
			end
			game.ReplicatedStorage.Notification:FireClient(Player,AmountGiven)
		end
	end
end


