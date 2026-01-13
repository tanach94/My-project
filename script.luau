--this script is created by masternamedjoe on DC, and on roblox Jozinn93, i took like hour or two on this. For luau test.
-- some of my knowledge.
local Game_players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Server_random_part_spawning_oop_table = {}
local Server_Signal = {}
Server_Signal.__index = Server_Signal
Server_random_part_spawning_oop_table.__index = Server_random_part_spawning_oop_table
local Can_spawn_part = true
local Can_spawn_part_cooldown_time = .3
local Count_of_killed_people = {}
local function Detect_ground_ray_cast(Main_part:BasePart) -- detects if spawned part is close to ground, if yes destroy
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Part}
	
	local Direction = Main_part.Position + Main_part.CFrame.UpVector * -5
	local RayCast = workspace:Raycast(Main_part.Position, Direction, Params)
	if RayCast then
		local instance:BasePart = RayCast.Instance
		instance.Color = Return_random_color_R_G_B()
		return instance
	end
end
function Server_Signal.New() 
	return setmetatable({_listeners = {}}, Server_Signal)
end
function Server_Signal:Connect(callback: (any) -> ()) -- adds new connection in listeners so i can communicate after i destroy metatable of part
	local connection = {
		_handler = callback,
		_signal = self,
	}
	function connection:Disconnect()
		local listeners = self._signal._listeners
		local index = table.find(listeners, self)
		if index then
			table.remove(listeners, index)
		end
	end
	table.insert(self._listeners, connection)
	return connection
end
function Server_Signal:Fire(...) -- this, after i fire, will call my connection and pass information
	local listeners = self._listeners
	for i = #listeners, 1, -1 do
		local listener = listeners[i]
		if listener then
			task.spawn(listener._handler, ...)
		end
	end
end
function Server_Signal:Destroy() -- and then this, will remove all connections
	for _, listener in ipairs(self._listeners) do
		listener:Disconnect()
	end
	self._listeners = {}
end
local function Part_random_size_effect(Part) -- pretty simple tween size effect for backend
	local Size_X_Random = math.random(1,10)
	local Size_Y_Random = math.random(1,10)
	local Size_Z_Random = math.random(1,10)
	
	local Tween_info = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Tween_goal = {Size = Vector3.new(Size_X_Random, Size_Y_Random, Size_Z_Random)}
	local Tween = TweenService:Create(Part, Tween_info, Tween_goal)
	Tween:Play()	
end
local function Part1_LookAt_Part2_FUNCTION(Part1, Part2) -- make part1 look at target
	Part1.CFrame = CFrame.lookAt(Part1.Position, Part2.Position)
end
local function Rotate_part_effect(Part:BasePart) -- another effect for backend, good rotate
	local Tween_info = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
	local Tween_goal = {Rotation = Vector3.new(0,360,0)}
	local Tween = TweenService:Create(Part, Tween_info, Tween_goal)
    Tween:Play()	
end
local function Random_position_around_object(Object:any) : Vector3 -- this will give you position around ["Object"] basically
	local Object_original_position = Object.Position
	local Multiplier = 10
	local Random_position_X = math.random(-360,360)
	local Random_position_Y = math.random(-360,360)
	local Calculated_sin = math.sin(Random_position_X) * Multiplier
	local Calculated_cos = math.cos(Random_position_Y) * Multiplier
	local Random_Y = math.random(-7,7)
	local Object_around_position = Object_original_position + Vector3.new(Calculated_sin, Random_Y, Calculated_cos)
	return Object_around_position
end
local function Part_rotate_random() : Vector3 -- simple random rotation
	local Random_Y = math.random(-20,20)
	local Random_X = math.random(-20,20)
	local Random_Z = math.random(-20,20)
	local Random_Vector3 = Vector3.new(Random_X, Random_Y, Random_Z)
	return Random_Vector3
end
function Return_random_color_R_G_B() : Color3 -- random color..
	local random_R = math.random(0,255)
	local random_G = math.random(0,255)
	local random_B = math.random(0,255)
	local Random_R_G_B = Color3.fromRGB(random_R, random_G, random_B)
	return Random_R_G_B
end
local function Create_part() : Part -- creates part.._
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = .5
	Part.Color = Return_random_color_R_G_B()
	return Part
end
function Server_random_part_spawning_oop_table.Random_part_spawning_new(Target) -- creates metatable set informations etc etc and then returns itself so i can do whatever i want with this metatable
	local self = setmetatable({}, Server_random_part_spawning_oop_table)
	self.Target = Target
	self.Target_humanoid_root_part = self.Target.HumanoidRootPart
	self.Target_humanoid = self.Target.Humanoid 
	self.Part = Create_part()
	self.Rotation = Part_rotate_random()
	self.Position = Random_position_around_object(self.Target_humanoid_root_part)
	self.Connections = {}
	self.Looking_position = 1
	local function While_function()
		while task.wait(1) do 
			Part1_LookAt_Part2_FUNCTION(self.Part, self.Target_humanoid_root_part)
			Rotate_part_effect(self.Part)
			Part_random_size_effect(self.Part)
		end
	end
	self.Connections.Coroutine = coroutine.create(While_function)
	coroutine.resume(self.Connections.Coroutine)
	self.Connections.Task_deleting = task.delay(5, function()
		self:Delete_itself()
	end)
	self.OnDeleted = Server_Signal.New()
	self.OnDeleted:Connect(function() -- checks whatever i deleted this metatable, then take damage to my humanoid and adds my hum kill count
		local function Add_count_of_deaths_local_hum()
			if not Count_of_killed_people[self.Target_humanoid] then
				Count_of_killed_people[self.Target_humanoid] = 0
			end
			Count_of_killed_people[self.Target_humanoid] += 1
		end
		
		self.Target_humanoid:TakeDamage(5)
		if self.Target_humanoid.Health <= 0 then
			Add_count_of_deaths_local_hum()
		end
	end)
	local Ground_detected_close_to_part = Detect_ground_ray_cast(self.Part) -- delete itself after part is too close to ground
	if Ground_detected_close_to_part then
		self:Delete_itself()
	end
	return self 
end
function Server_random_part_spawning_oop_table:Set_properties() -- the informations in metatable what are in part properties will set to part, simple way
	for Property, Value in pairs(self) do 
		local success, message = pcall(function()
			self.Part[Property] = Value
		end)
		if not success then
			warn(`{Property} is not valid member of properties of {self.Part}`)
		end
	end
end
function Server_random_part_spawning_oop_table:Delete_itself() -- metatable delete itself, and all connections so no memory break:)
	self.OnDeleted:Fire()
	self.OnDeleted:Destroy()
	self.Part:Destroy()
	local function Remove_connections()
		for index, connection:RBXScriptConnection in pairs(self.Connections) do 
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			end
			if typeof(connection) == "thread" then
				coroutine.yield(connection)
				coroutine.close(connection)
			end
		end
	end
	Remove_connections()
	setmetatable(self, nil)
end
local function Specific_player_targeting(Player:Player) -- basically, make spawn part around this player
	local Player_character = Player.Character
	local New_Class_Random_Part_spawning = Server_random_part_spawning_oop_table.Random_part_spawning_new(Player_character)
	New_Class_Random_Part_spawning:Set_properties()
end
local function Character_humanoid_root_part_loaded_detection(Character:Model) : boolean
	if not Character then return end 
	local Possible_humanoid_root_part = Character:FindFirstChild("HumanoidRootPart")
	if not Possible_humanoid_root_part then return end 
	return true
end
local function Players_targeting_function() -- spawning part around these all players
	for Index, Player in pairs(Game_players:GetPlayers()) do 
		if Character_humanoid_root_part_loaded_detection(Player.Character) then
			Specific_player_targeting(Player)
		end
	end
end
RunService.Stepped:Connect(function()
	if Can_spawn_part then
		Can_spawn_part = false
		task.delay(Can_spawn_part_cooldown_time, function()
			Can_spawn_part = true
		end)
		Players_targeting_function()
	end
end)
