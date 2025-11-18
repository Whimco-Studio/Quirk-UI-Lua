local GuiController = require(script.Parent["gui-controller"])
local StarterGui = game:GetService("StarterGui")

local UiManager = {}
UiManager.__index = UiManager

function UiManager.new()
	local self = setmetatable({}, UiManager)
	self._registeredControllers = {}
	self._disabledCoreGuis = {}
	self._initialized = false
	self._started = false
	return self
end

function UiManager:_init()
	if self._initialized then
		return
	end
	self._initialized = true

	for _, controller in pairs(self._registeredControllers) do
		controller:Init()
	end
end

function UiManager:_start()
	if self._started then
		return
	end
	self._started = true

	for _, controller in pairs(self._registeredControllers) do
		controller:Start()
	end
end

function UiManager:_setDisabledCoreGuis(namespace)
	local controller = self._registeredControllers[namespace]
	if not controller then
		error("Controller " .. namespace .. " not found")
	end

	self._disabledCoreGuis = {}
	if controller._settings.DisabledCoreGuis then
		for _, coreGui in ipairs(controller._settings.DisabledCoreGuis) do
			table.insert(self._disabledCoreGuis, coreGui)
		end
	end

	self:_hideCoreGuis()
end

function UiManager:_hideCoreGuis()
	for _, coreGui in ipairs(self._disabledCoreGuis) do
		StarterGui:SetCoreGuiEnabled(coreGui, false)
	end
end

function UiManager:Mount()
	self:_init()
	self:_start()
end

function UiManager:RegisterController(controller)
	self._registeredControllers[controller.namespace] = controller

	if self._initialized then
		controller:Init()
		if self._started then
			controller:Start()
		end
	end
	return controller
end

function UiManager:Show(namespace)
	self:_setDisabledCoreGuis(namespace)

	for _, controller in pairs(self._registeredControllers) do
		if controller.namespace == namespace then
			controller:Show()
		elseif controller.namespace ~= namespace and controller._settings.CanHide then
			controller:Hide()
		end
	end
end

function UiManager:Hide(namespace)
	local controller = self._registeredControllers[namespace]
	if controller then
		controller:Hide()
	end
end

function UiManager:IsVisible(namespace)
	local controller = self._registeredControllers[namespace]
	if controller then
		return controller._state.Visible:get() or false
	end
	return false
end

return UiManager.new()

