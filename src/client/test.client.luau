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
