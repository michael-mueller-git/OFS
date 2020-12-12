-- ============================
-- == DO NOT EDIT THIS FILE ==
-- ============================

Action = {at = 0, pos = 0}

function Action:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.__tostring = function(self) return string.format("at:%d pos:%d", self.at, self.pos) end
   self.at = at or 0
   self.pos = pos or 0
   return o
end


Funscript = { actions = {}}

function ScriptToString(self)
	local result = "actions: "
	for i,v in ipairs(self.actions) do
		result = result..tostring(v)
		result = result..";\n"
	end
	return result
end

function Funscript:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.__tostring = ScriptToString
   
   self.actions = {}
   return o
end

function Funscript:Clear()
	self.actions = {}
end

function Funscript:AddAction(at, pos)
	local newAction = Action:new()
	newAction.at = at
	newAction.pos = pos
	table.insert(self.actions, newAction)
end


CurrentScript = Funscript:new()