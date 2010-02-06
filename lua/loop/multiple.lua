--------------------------------------------------------------------------------
-- Project: LOOP - Lua Object-Oriented Programming                            --
-- Title  : Multiple Inheritance Class Model                                  --
-- Author : Renato Maia <maia@inf.puc-rio.br>                                 --
--------------------------------------------------------------------------------

local _G = require "_G"
local ipairs = _G.ipairs
local select = _G.select
local setmetatable = _G.setmetatable

local table = require "table"
local unpack = table.unpack

local loop_table = require "loop.table"
local copy = loop_table.copy

local proto = require "loop.proto"
local clone = proto.clone

local simple = require "loop.simple"
local simple_class = simple.class
local simple_isclass = simple.isclass
local simple_superclass = simple.superclass

module "loop.multiple"

clone(simple, _M)

local MultipleClass = {
	__call = new,
	__index = function (self, field)
		self = classof(self)
		for _, super in ipairs(self) do
			local value = super[field]
			if value ~= nil then return value end
		end
	end,
}

function class(class, ...)
	if select("#", ...) > 1
		then return setmetatable(initclass(class), copy(MultipleClass, {...}))
		else return simple_class(class, ...)
	end
end

function isclass(class)
	local metaclass = classof(class)
	if metaclass then
		return metaclass.__index == MultipleClass.__index or
		       simple_isclass(class)
	end
end

function superclass(class)
	local metaclass = classof(class)
	if metaclass then
		local indexer = metaclass.__index
		if (indexer == MultipleClass.__index)
			then return unpack(metaclass)
			else return metaclass.__index
		end
	end
end

local function isingle(single, index)
	if single and not index then
		return 1, single
	end
end
function supers(class)
	local metaclass = classof(class)
	if metaclass then
		local indexer = metaclass.__index
		if indexer == MultipleClass.__index
			then return ipairs(metaclass)
			else return isingle, simple_superclass(class)
		end
	end
	return isingle
end

function subclassof(class, super)
	if class == super then return true end
	for _, superclass in supers(class) do
		if subclassof(superclass, super) then
			return true
		end
	end
	return false
end

function instanceof(object, class)
	return subclassof(classof(object), class)
end
