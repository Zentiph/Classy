-- Test classy stuff

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classy = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classy"))

task.wait(3) -- Let game load
print("Testing")

local Animal = Classy:NewClass("Animal", function(self: any, name: string)
	self.Name = name
end)
