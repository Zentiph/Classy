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

local Card = Classy:NewClass("Card", function(cls, suit: string, value: number)
	cls.Suit = suit
	cls.Value = value
end)

Classy.Metamethods:SetToStringMethod(Card, function(cls)
	return `Card: {cls.Suit} {cls.Value}`
end)
Classy.Metamethods:SetToNumberMethod(Card, function(cls)
	return cls.Value
end)

local jackOfSpades = Card.new("Spades", 11)
print("Jack of Spades:", jackOfSpades) -- Should print "Jack of Spades: Card: Spades 11"
