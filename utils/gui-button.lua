local Packages = script.Parent.Parent.Parent
local Dumpster = require(script.Parent.dumpster)
local ripple = require(Packages.ripple)
local createMotion = ripple.createMotion

local GuiButton = {}
GuiButton.__index = GuiButton

function GuiButton.new(button, dumpster, customMotionOptions, config)
	local self = setmetatable({}, GuiButton)
	
	self.config = config
	self._button = button
	self._buttonClone = (config and config.useBaseButton) and button or button:Clone()
	self._uiscale = Instance.new("UIScale")
	self._uiscale.Parent = self._buttonClone
	self._dumpster = dumpster

	self._motionOptions = {
		velocity = 0.001,
		damping = 0.5,
		mass = 0.1,
		friction = 10,
	}
	
	if customMotionOptions then
		for key, value in pairs(customMotionOptions) do
			self._motionOptions[key] = value
		end
	end

	self._motion = createMotion(1, {
		start = true,
	})

	if not (config and config.useBaseButton) then
		self:_deleteOriginalChildren()
	end
	self:_init()
	
	return self
end

function GuiButton:_deleteOriginalChildren()
	for _, element in pairs(self._button:GetChildren()) do
		if element:IsA("GuiBase2d") then
			element:Destroy()
		end
	end
end

function GuiButton:_init()
	if not (self.config and self.config.useBaseButton) then
		self._buttonClone.Parent = self._button

		if self._button:IsA("ImageButton") then
			self._button.ImageTransparency = 1
		elseif self._button:IsA("TextButton") then
			self._button.TextTransparency = 1
		end
		self._button.BackgroundTransparency = 1

		self._buttonClone.AnchorPoint = Vector2.new(0.5, 0.5)
		self._buttonClone.Position = UDim2.new(0.5, 0, 0.5, 0)
		self._buttonClone.Size = UDim2.new(1, 0, 1, 0)
	end

	self._dumpster:dump(
		self._buttonClone.MouseEnter:Connect(function()
			local max = (self.config and self.config.bounds and self.config.bounds.max) or 1.25
			self._motion:spring(max, self._motionOptions)
		end)
	)

	self._dumpster:dump(
		self._buttonClone.MouseLeave:Connect(function()
			local min = (self.config and self.config.bounds and self.config.bounds.min) or 1
			self._motion:spring(min, self._motionOptions)
		end)
	)

	self._dumpster:dump(
		self._buttonClone.Activated:Connect(function()
			local impulseAmount = (self.config and self.config.impulse and self.config.impulse.amount) or 0.01
			local direction = (self.config and self.config.impulse and self.config.impulse.direction) or "down"
			self._motion:impulse((direction == "up") and impulseAmount or -impulseAmount)
			if self.config and self.config.onActivated then
				self.config.onActivated()
			end
		end)
	)

	self._dumpster:dump(
		self._motion:onStep(function(value, deltaTime)
			self._uiscale.Scale = value
		end)
	)
end

function GuiButton:GetVisualButton()
	return self._buttonClone
end

return GuiButton

