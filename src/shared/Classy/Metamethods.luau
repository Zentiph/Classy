-- Metamethods submodule for Classy by zen

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

--- @class Classy.Metamethods
--- Metamethod setters for classes in Classy.
local Metamethods = {}

--[[
Set a method that allows the class to be converted to a string representation.

class - Class to set the method for
method - Function that takes the class instance and returns a string representation of it
]]

--- Add functionality to a class that allows it to be converted to a string using `tostring`.
---
--- @param class Class<T, A...> -- The class to set the method for
--- @param method (cls: T) -> string -- the function that takes the class instance and returns a string representation of it
--- @within Classy.Metamethods
function Metamethods:SetToStringMethod<T, A...>(class: Class<T, A...>, method: (cls: T) -> string)
	if not class.__tostring then
		class.__tostring = method
	else
		error("Class already has a __tostring method")
	end
end

--- Set a method that allows the class to be added to another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetAddMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__add then
		class.__add = method
	else
		error("Class already has an __add method")
	end
end

--- Set a method that allows the class to be subtracted to another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetSubMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__sub then
		class.__sub = method
	else
		error("Class already has a __sub method")
	end
end

--- Set a method that allows the class to be multiplied to another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetMulMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__mul then
		class.__mul = method
	else
		error("Class already has a __mul method")
	end
end

--- Set a method that allows the class to be divided to another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetDivMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__div then
		class.__div = method
	else
		error("Class already has a __div method")
	end
end

--- Set a method that allows the class to use modulus on another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetModMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__mod then
		class.__mod = method
	else
		error("Class already has a __mod method")
	end
end

--- Set a method that allows the class to be raised to the power of another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> Class<T, A...> -- Function that takes the class instance and another value, returning a new class instance or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetPowMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> Class<T, A...>)
	if not class.__pow then
		class.__pow = method
	else
		error("Class already has a __pow method")
	end
end

--- Set a method that allows the class to be concatenated to another class or value.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> string -- Function that takes the class instance and another value, returning a string or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetConcatMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> string)
	if not class.__concat then
		class.__concat = method
	else
		error("Class already has a __concat method")
	end
end

--- Set a method that allows the class to compare itself to another class or value, checking if they are "equal".
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> boolean -- Function that takes the class instance and another value, returning a boolean or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetEqMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__eq then
		class.__eq = method
	else
		error("Class already has a __eq method")
	end
end

--- Set a method that allows the class to compare itself to another class or value, checking if it is "less than".
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> boolean -- Function that takes the class instance and another value, returning a boolean or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetLtMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__lt then
		class.__lt = method
	else
		error("Class already has a __lt method")
	end
end

--- Set a method that allows the class to compare itself to another class or value, checking if it is "less than or equal".
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, other: any) -> boolean -- Function that takes the class instance and another value, returning a boolean or erroring if the operation is not valid
--- @within Classy.Metamethods
function Metamethods:SetLeMethod<T, A...>(class: Class<T, A...>, method: (cls: T, other: any) -> boolean)
	if not class.__le then
		class.__le = method
	else
		error("Class already has a __le method")
	end
end

--- Set a method that allows the class to be called.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T, ...any) -> ...any -- Function that is called when the class is called, receiving the class instance and any additional arguments
--- @within Classy.Metamethods
function Metamethods:SetCallMethod<T, A...>(class: Class<T, A...>, method: (cls: T, ...any) -> ...any)
	if not class.__call then
		class.__call = method
	else
		error("Class already has a __call method")
	end
end

--- Set a method that allows the class to be sized.
---
--- @param class Class<T, A...> -- Class to set the method for
--- @param method (cls: T) -> number -- Function that returns the "size" of the class instance
--- @within Classy.Metamethods
function Metamethods:SetLenMethod<T, A...>(class: Class<T, A...>, method: (cls: T) -> number)
	if not class.__len then
		class.__len = method
	else
		error("Class already has a __len method")
	end
end

return Metamethods
