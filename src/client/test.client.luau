-- Test classy stuff

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classy = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classy"))

task.wait(3) -- Let game load
print("Testing")

-- Optional type annotations for autocompletion and type checking
type Animal = Classy.ClassInstance & {
	Name: string,
	Speak: (self: Animal) -> (),
}
type Dog = Classy.ClassInstance & Animal & {
	Bite: (self: Dog, human: Humanoid) -> (),
}

local Animal = Classy:NewClass("Animal", function(cls, name: string)
	cls.Name = name
end)

function Animal:Speak()
	print(self.Name .. " says hello!")
end

local Dog = Classy:NewClass("Dog", function(cls, name: string)
	cls:superinit(name)
end, Animal)

function Dog:Speak()
	print(self.Name .. " barks!")
end
function Dog:Bite(human: Humanoid)
	human:TakeDamage(10)
end

local pet: Animal = Animal.new("Generic Animal")
pet:Speak() -- Should print "Generic Animal says hello!"
local dog: Dog = Dog.new("Rex")
dog:Speak() -- Should print "Rex barks!"
dog:Bite(Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or error("No humanoid found!"))

local Vector4 = Classy:NewClass("Vector4", function(cls, x: number, y: number, z: number, w: number)
	cls.X = x
	cls.Y = y
	cls.Z = z
	cls.W = w
end)

Classy:SetAddMethod(Vector4, function(cls, other)
	if Classy:TypeOf(other) ~= "Vector4" then
		error("Cannot add Vector4 with " .. Classy:TypeOf(other))
	end

	local otherVec = Classy:Cast("Vector4", other)
	return Vector4.new(cls.X + otherVec.X, cls.Y + otherVec.Y, cls.Z + otherVec.Z, cls.W + otherVec.W)
end)
