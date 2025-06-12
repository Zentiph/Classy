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

See the external documentation for more in-depth examples.
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

	-- Optional metamethods
	__tostring: ((self: T) -> string)?,
	__tonumber: ((self: T) -> number)?,
	__add: ((self: T, other: any) -> Class<T, A...>)?,
	__sub: ((self: T, other: any) -> Class<T, A...>)?,
	__mul: ((self: T, other: any) -> Class<T, A...>)?,
	__div: ((self: T, other: any) -> Class<T, A...>)?,
	__mod: ((self: T, other: any) -> Class<T, A...>)?,
	__pow: ((self: T, other: any) -> Class<T, A...>)?,
	__concat: ((self: T, other: any) -> string)?,
	__eq: ((self: T, other: any) -> boolean)?,
	__lt: ((self: T, other: any) -> boolean)?,
	__le: ((self: T, other: any) -> boolean)?,
	__call: ((self: T, ...any) -> ...any)?,
	__len: ((self: T) -> number)?,
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
		setmetatable(class, {
			__index = baseClass,
			__tostring = class.__tostring,
			__add = class.__add,
			__sub = class.__sub,
			__mul = class.__mul,
			__div = class.__div,
			__mod = class.__mod,
			__pow = class.__pow,
			__concat = class.__concat,
			__eq = class.__eq,
			__lt = class.__lt,
			__le = class.__le,
			__call = class.__call,
			__len = class.__len,
		})
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

See the external documentation for more in-depth examples.
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
Set a method that allows the class to be added to another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetAddMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__add then
		class.__add = method
	else
		error("Class already has an __add method")
	end
end

--[[
Set a method that allows the class to be subtracted to another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetSubMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__sub then
		class.__sub = method
	else
		error("Class already has a __sub method")
	end
end

--[[
Set a method that allows the class to be multiplied to another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetMulMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__mul then
		class.__mul = method
	else
		error("Class already has a __mul method")
	end
end

--[[
Set a method that allows the class to be divided to another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetDivMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__div then
		class.__div = method
	else
		error("Class already has a __div method")
	end
end

--[[
Set a method that allows the class to use modulus on another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetModMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__mod then
		class.__mod = method
	else
		error("Class already has a __mod method")
	end
end

--[[
Set a method that allows the class to be raised to the power of another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetPowMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__pow then
		class.__pow = method
	else
		error("Class already has a __pow method")
	end
end

--[[
Set a method that allows the class to be concatenated to another class or value.

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetConcatMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> string)
	if not class.__concat then
		class.__concat = method
	else
		error("Class already has a __concat method")
	end
end

--[[
Set a method that allows the class to compare itself to another class or value, checking if they are "equal".

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetEqMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__eq then
		class.__eq = method
	else
		error("Class already has a __eq method")
	end
end

--[[
Set a method that allows the class to compare itself to another class or value, checking if it is "less than".

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetLtMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__lt then
		class.__lt = method
	else
		error("Class already has a __lt method")
	end
end

--[[
Set a method that allows the class to compare itself to another class or value, checking if it is "less than or equal".

class - Class to set the method for
method - Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
]]
function Classy:SetLeMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__le then
		class.__le = method
	else
		error("Class already has a __le method")
	end
end

--[[
Set a method that allows the class to be called.

class - Class to set the method for
method - Function that is called when the class is called, receiving the class instance and any additional arguments
]]
function Classy:SetCallMethod<T, A...>(class: Class<T, A...>, method: (cls: T, ...any) -> ...any)
	if not class.__call then
		class.__call = method
	else
		error("Class already has a __call method")
	end
end

--[[
Set a method that allows the class to be sized.

class - Class to set the method for
method - Function that returns the "size" of the class instance
]]
function Classy:SetLenMethod<T, A...>(class: Class<T, A...>, method: (cls: T) -> number)
	if not class.__len then
		class.__len = method
	else
		error("Class already has a __len method")
	end
end

--[[
Get the type of a class or instance, working with Classy classes as well as standard Luau types.

class - Class or instance to check the type of
]]
function Classy:TypeOf(class: any): string
	if typeof(class) == "table" and class.__name then
		return class.__name
	else
		return typeof(class)
	end
end

--[[
Attempt to cast a value to a specific class type.

className - Name of the class to cast to
value - Value to cast
]]
function Classy:Cast<T>(className: string, value: any): T?
	if typeof(value) == "table" and typeof(value.IsA) == "function" and value:IsA(className) then
		return value :: T
	end
	return nil
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

See the external documentation for more in-depth examples.
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
