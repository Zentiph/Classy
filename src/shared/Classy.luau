-- Classy module by zentiph
-- Enjoy!!!

--[[
A module that aims to make Object-Oriented Programming in Luau more straightforward.

Classy implements many behaviors expected of generic OOP systems, like:
* Easy class creation
* Inheritance
* Constructors
* Private state / encapsulation
* Type safety support
* Meta-method support (__tostring, __add, etc) for extra functionality
* Signal / event patterns
]]
local Classy = {}

local privateData = setmetatable({}, { __mode = "k" })

export type Class<T, A...> = {
	__index: Class<T, A...>,
	__name: string,
	__base: Class<T, A...>?,

	new: (A...) -> T,
	init: ((self: T, A...) -> ())?,
	super: (self: T, methodName: string, ...any) -> any,
	superinit: (self: T, ...any) -> (),
	IsA: (self: T, className: string) -> boolean,
}

export type ClassInstance = {
	super: (self: any, methodName: string, ...any) -> any,
	superinit: (self: any, ...any) -> (),
	IsA: (self: any, className: string) -> boolean,
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> RBXScriptConnection,
	Fire: (self: Signal<T...>, T...) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

--[[
Generate a new class with Classy.
className - Name of the class
initFunc - Function that initializes the class instance and receives the class as the first argument
baseClass - Optional superclass to inherit from

New classes come with:
* A default .new() method
* A :super() method for calling superclass methods
* A :superinit() method for calling superclass constructors (shorthand for :super("init", ...))
* An :IsA() method for checking class inheritance
* A private data store for encapsulation

See the external documentation for more in-depth examples.

```
local Animal = Classy:NewClass("Animal", function(cls, name: string)
	cls.Name = name
end)

local Dog = Classy:NewClass("Dog", function(cls, name: string)
	cls:superinit(name) -- Calls Animal's constructor
end, Animal)
function Dog:Bark()
	print(self.Name .. " barks!")
end

local fido = Dog.new("Fido")
fido:Bark() --> "Fido barks!"
```
]]
function Classy:NewClass<T, A...>(className: string, initFunc: (cls: T, A...) -> (), baseClass: Class<any, any>?): Class<T, A...>
	local class = {} :: any
	class.__name = className
	class.__index = class

	class.init = initFunc

	if baseClass then
		setmetatable(class, { __index = baseClass })
		class.__base = baseClass
	end

	-- Constructor
	function class.new(...: A...): T
		local instance = setmetatable({}, class)

		-- Call a superclass's method
		function instance:super(methodName: string, ...: any): any
			local base = class.__base

			while base do
				local method = (base :: any)[methodName]
				if typeof(method) == "function" then
					return method(self, ...)
				end
				base = base.__base
			end

			error(`Superclass method '{methodName}' not found in '{class.__name}'`)
		end

		-- Shorthand for calling the superclass's init method
		function instance:superinit(...: any): any
			local base = class.__base

			while base do
				local method = (base :: any)["init"]
				if typeof(method) == "function" then
					return method(self, ...)
				end
				base = base.__base
			end

			error(`Superclass method 'init' not found in '{class.__name}'`)
		end

		function instance:IsA(className: string): boolean
			local current = class

			while current do
				if current.__name == className then
					return true
				end
				current = current.__base
			end

			return false
		end

		initFunc(instance, ...)

		return instance :: T
	end

	return class :: Class<T, A...>
end

--[[
Get a table that holds private data for the class.

class - Class to access the private data store for

```
local ImmutableClass = Classy:NewClass("ImmutableClass", function(cls, value: any)
	local privateData = Classy:GetPrivateDataStore(cls)
	privateData.value = value
end)

function ImmutableClass:GetValue()
	local privateData = Classy:GetPrivateDataStore(self)
	return privateData.value
end
```
]]
function Classy:GetPrivateDataStore<T>(class: T): { [string]: any }
	local data = privateData[class]

	if not data then
		data = {}
		privateData[self] = data
	end

	return data
end

--[[
Create a new signal that can be connected to, fired, and destroyed within a class.

```
local Enemy = Classy:NewClass("Enemy", function(cls, name: string)
	cls.Name = name
	cls.OnDeath = Classy.NewSignal()
end)

function Enemy:Die()
	print(self.Name .. " has died!")
	self.OnDeath:Fire(self)
end
```
]]
function Classy.NewSignal<T...>(): Signal<T...>
	local connections = {} :: { (T...) -> () }

	local signal = {
		Connect = function(self, fn: (T...) -> ())
			table.insert(connections, fn)
			return {
				Disconnect = function()
					table.remove(connections, table.find(connections, fn))
				end,
			}
		end,
		Fire = function(self, ...: T...)
			for _, fn in connections do
				fn(...)
			end
		end,
		Destroy = function(self)
			table.clear(connections)
		end,
	}

	return signal :: Signal<T...>
end

return Classy
