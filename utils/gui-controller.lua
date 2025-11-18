local Make = require(script.Parent["make"])
local GuiBase = require(script.Parent["gui-base"])
local Players = game:GetService("Players")
local charm = require(Packages.charm)
local atom = charm.atom

local DefaultSettings = {
	CanHide = true,
	IgnoreGuiInset = false,
	PopUp = false,
	DisabledCoreGuis = {},
}

local GuiController = {}
GuiController.__index = GuiController

function GuiController.new(Namespace, Gui, CustomSettings)
	local self = setmetatable({}, GuiController)
	self.namespace = Namespace
	self._gui = Gui
	self._settings = {}
	
	-- Merge default settings with custom settings
	for key, value in pairs(DefaultSettings) do
		self._settings[key] = value
	end
	if CustomSettings then
		for key, value in pairs(CustomSettings) do
			self._settings[key] = value
		end
	end
	
	self._state = {
		Visible = atom(false),
	}
	
	return self
end

function GuiController:Init()
	self._screenGui = Make("ScreenGui", {
		Name = self.namespace,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		IgnoreGuiInset = self._settings.IgnoreGuiInset,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = self._settings.DisplayOrder,
	})

	if self._settings.CanHide ~= false then
		self._screenGui.Enabled = false
	end
end

function GuiController:Start()
	self._gui:Mount(self._screenGui)
end

function GuiController:Show()
	if self._screenGui then
		self._screenGui.Enabled = true
	end
end

function GuiController:Hide()
	if self._screenGui then
		self._screenGui.Enabled = false
	end
end

function GuiController:Destroy()
	-- Implementation for cleanup if needed
end

return GuiController

