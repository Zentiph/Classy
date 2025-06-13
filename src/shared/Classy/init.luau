-- Classy module by zentiph
-- Enjoy!!!

--- @type Class<T,A...> {__index: Class<T, A...>,, __name: string,, __base: Class<T, A...>?,, new: (A...) -> T,, init: ((self: T, A...) -> ())?,, super: (self: T, methodName: string, ...any) -> any,, superinit: (self: T, ...any) -> (),, IsA: (self: T, className: string) -> boolean,, __tostring: ((self: T) -> string)?,, __tonumber: ((self: T) -> number)?,, __add: ((self: T, other: any) -> Class<T, A...>)?,, __sub: ((self: T, other: any) -> Class<T, A...>)?,, __mul: ((self: T, other: any) -> Class<T, A...>)?,, __div: ((self: T, other: any) -> Class<T, A...>)?,, __mod: ((self: T, other: any) -> Class<T, A...>)?,, __pow: ((self: T, other: any) -> Class<T, A...>)?,, __concat: ((self: T, other: any) -> string)?,, __eq: ((self: T, other: any) -> boolean)?,, __lt: ((self: T, other: any) -> boolean)?,, __le: ((self: T, other: any) -> boolean)?,, __call: ((self: T, ...any) -> ...any)?,, __len: ((self: T) -> number)?}
--- A type representing a class in Classy, with type parameters for the class instance and constructor arguments.
--- @within Classy
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

-- TODO: more docstrings
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

-- TODO: ADD EXAMPLES FOR ALL METHODS

local privateData = setmetatable({}, { __mode = "k" })

--- @class Classy
--- A module that aims to make Object-Oriented Programming in Luau more straightforward.
---
--- Classy implements many behaviors expected of generic OOP systems, like:
--- * Easy class creation
--- * Inheritance
--- * Constructors
--- * Private state / encapsulation
--- * Type safety support
--- * Meta-method support (__tostring, __add, etc) for extra functionality
--- * Signal / event patterns
local Classy = {}

--- @prop Metamethods Classy.Metamethods
--- @within Classy
--- A submodule that provides methods for setting metamethods on classes in Classy.
Classy.Metamethods = require(script:WaitForChild("Metamethods"))

--- Generate a new class with Classy.
---
--- @param className string -- Name of the class
--- @param initFunc (cls: T, A...) -> () -- Function that initializes the class instance and receives the class as the first argument
--- @param baseClass Class<any, any>? -- Optional superclass to inherit from
--- @return Class<T, A...> -- The new class
---
--- New classes come with:
--- * A default `.new()` method matching the init signature
--- * A `:super()` method for calling superclass methods
--- * A `:superinit()` method for calling superclass constructors (shorthand for :super("init", ...))
--- * An `:IsA()` method for checking class inheritance
--- * A private data store for encapsulation
function Classy:NewClass<T, A...>(className: string, initFunc: (cls: T, A...) -> (), baseClass: Class<any, any>?): Class<T, A...>
	local class = {} :: any
	class.__name = className
	class.__index = class

	class.init = initFunc

	if baseClass then
		setmetatable(class, {
			__index = baseClass,

			__tostring = class.__tostring,
			__tonumber = class.__tonumber,

			__add = class.__add,
			__sub = class.__sub,
			__mul = class.__mul,
			__div = class.__div,
			__mod = class.__mod,
			__pow = class.__pow,

			__eq = class.__eq,
			__lt = class.__lt,
			__le = class.__le,

			__concat = class.__concat,

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

--- Get a table that holds private data for the class.
---
--- @param class T -- Class to access the private data store for
--- @return { [string]: any } -- Table containing private data for the class
function Classy:GetPrivateDataStore<T>(class: T): { [string]: any }
	local data = privateData[class]

	if not data then
		data = {}
		privateData[self] = data
	end

	return data
end

--- Get the type of a class or instance, working with Classy classes as well as standard Luau types.
---
--- @param class any -- Class or instance to check the type of
--- @return string -- The type of the class or instance
function Classy:TypeOf(class: any): string
	if typeof(class) == "table" and class.__name then
		return class.__name
	else
		return typeof(class)
	end
end

--- Attempt to cast a value to a specific class type.
---
--- @param className string -- Name of the class to cast to
--- @param value any -- Value to cast
--- @return T? -- The value cast to the class type, or nil if it does not match
function Classy:Cast<T>(className: string, value: any): T?
	if typeof(value) == "table" and typeof(value.IsA) == "function" and value:IsA(className) then
		return value :: T
	end
	return nil
end

--- Create a new signal that can be connected to, fired, and destroyed within a class.
---
--- @return Signal<T...> -- The new signal instance
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
