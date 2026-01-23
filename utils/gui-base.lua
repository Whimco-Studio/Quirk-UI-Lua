local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = script.Parent.Parent.Parent
local Dumpster = require(Packages.dumpster)

local GuiBase = {}
GuiBase.__index = GuiBase

function GuiBase.new(options)
	local self = setmetatable({}, GuiBase)
	local Template = options.Template
	local InstanceKeys = options.InstanceKeys or {}
	
	self.InstanceKeys = {}
	self._dumpster = Dumpster.new()
	
	self.Pane = self:_resolveTemplate(Template)
	self:_resolveInstanceKeys(InstanceKeys)
	
	return self
end

function GuiBase:_resolveTemplate(Template)
	local Templates = ReplicatedStorage:FindFirstChild("Templates", true)
	assert(Templates, "Templates folder not found in ReplicatedStorage")

	local template = Templates:FindFirstChild(Template, true)
	assert(template, "Template " .. Template .. " not found")
	assert(
		template:IsA("Frame") or template:IsA("CanvasGroup"),
		"Template " .. Template .. " is not a Frame or CanvasGroup"
	)

	local clone = template:Clone()
	self._dumpster:dump(clone)

	return clone
end

function GuiBase:_resolveInstanceKeys(InstanceKeys)
	for key, value in pairs(InstanceKeys) do
		local instance = self.Pane:FindFirstChild(value, true)
		assert(instance, "Instance " .. value .. " not found in template " .. self.Pane.Name)
		self.InstanceKeys[key] = instance
	end
end

function GuiBase:resolve(key, className)
	local instance = self:get(key)
	if className ~= nil then
		assert(instance:IsA(className), "Instance " .. tostring(key).. `({instance.ClassName})\n` .. " is not a " .. tostring(className))
	end
	return instance
end

function GuiBase:get(key)
	assert(self.InstanceKeys[key] ~= nil, "Instance " .. tostring(key) .. " not found in template " .. self.Pane.Name)
	return self.InstanceKeys[key]
end

function GuiBase:Mount(parent)
	self.Pane.Parent = parent
end

function GuiBase:Destroy()
	self._dumpster:Destroy()
	self.Pane:Destroy()
	for key in pairs(self) do
		self[key] = nil
	end
end

return GuiBase

