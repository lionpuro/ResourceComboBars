local RCB = CreateFrame("Frame", "ResourceComboBars", UIParent)

RCB.Settings = {
	locked = false,
	showPowerValue = true,
	showPowerPercent = true,
	x = 0,
	y = 0,
	width = 215,
	height = 44,
	offsetX = 0,
	offsetY = -157,
	borderWidth = 1,
	comboPointColor = {0.75, 0.5, 0.95, 1}
}

local MaxComboPoints = 5
local GetComboPoints = function() return 0 end
function RCB:SetPointGetter(fn)
	GetComboPoints = fn
end

-- Helpers
local function FindAura(unit, spellID, filter)
	for i=1, 100 do
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura(unit, i, filter)
		if not name then return nil end
		if spellID == auraSpellID then
			return name,
				icon,
				count,
				debuffType,
				duration,
				expirationTime,
				unitCaster,
				canStealOrPurge,
				nameplateShowPersonal,
				auraSpellID
		end
	end
end

local GetAuraStack = function(scanID, filter, unit, casterCheck)
	filter = filter or "HELPFUL"
	unit = unit or "player"
	return function()
		local
			name,
			icon,
			count,
			debuffType,
			duration,
			expirationTime,
			caster
		= FindAura(unit, scanID, filter)
		if casterCheck and caster ~= casterCheck then
			count = nil
		end
		if count then
			return count
		else
			return 0,0,0
		end
	end
end

local function getPowerColor(powerType)
	local powerColors = {
		[0] = {0.25, 0.45, 1, 1}, -- Mana
		[1] = {1, 0, 0, 1},       -- Rage
		[2] = {1, 1, 0, 1},       -- Focus
		[3] = {1, 1, 0, 1},       -- Energy
		[6] = {1, 0.5, 1, 1},     -- Runic Power
		[12] = {1, 1, 0, 1},      -- Energy
	}
	local color = powerColors[powerType] or {0, 0.1, 0.87, 1}
	return color
end

RCB:SetSize(RCB.Settings.width, RCB.Settings.height)
RCB:SetPoint("CENTER", UIParent, "CENTER", RCB.Settings.offsetX, RCB.Settings.offsetY)
RCB:SetScale(1.0)

RCB.bg = RCB:CreateTexture(nil, "BACKGROUND")
RCB.bg:SetAllPoints(RCB)
RCB.bg:SetColorTexture(0, 0, 0, 0.5)

-- Combo bar
RCB.comboBG = RCB:CreateTexture(nil, "BACKGROUND", nil, 1)
RCB.comboBG:SetPoint("TOPLEFT", RCB, "TOPLEFT", 0, 0)
RCB.comboBG:SetPoint("TOPRIGHT", RCB, "TOPRIGHT", 0, 0)
RCB.comboBG:SetHeight(RCB.Settings.height/2)
RCB.comboBG:SetColorTexture(0.05, 0.05, 0.05, 0)

RCB.comboValueText = RCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
RCB.comboValueText:SetPoint("RIGHT", RCB.comboBG, "RIGHT", -4, 0)
RCB.comboValueText:SetTextColor(1, 1, 1, 0)
RCB.comboValueText:SetFont(RCB.comboValueText:GetFont(), 12, "OUTLINE")

RCB.comboBar = RCB:CreateTexture(nil, "ARTWORK")
RCB.comboBar:SetPoint("TOPLEFT", RCB.comboBG, "TOPLEFT", 0, 0)
RCB.comboBar:SetPoint("BOTTOMLEFT", RCB.comboBG, "BOTTOMLEFT", 0, 0)
RCB.comboBar:SetWidth(0)
local comboColor = RCB.Settings.comboPointColor or {1, 1, 1, 1}
RCB.comboBar:SetColorTexture(unpack(comboColor))

RCB.splitter = RCB:CreateTexture(nil, "OVERLAY")
RCB.splitter:SetSize(RCB.Settings.width, RCB.Settings.borderWidth)
RCB.splitter:SetPoint("BOTTOMLEFT", RCB.comboBG, "BOTTOMLEFT", 0, -RCB.Settings.borderWidth)
RCB.splitter:SetColorTexture(0, 0, 0, 1)

-- Combo bar splitters
for i = 1, (MaxComboPoints-1) do
	local line = RCB:CreateTexture(nil, "OVERLAY")
	line:SetSize(RCB.Settings.borderWidth, RCB.Settings.height/2)
	local pos = (RCB.Settings.width - RCB.Settings.borderWidth * 2) * (i / MaxComboPoints)
	line:SetPoint("TOPLEFT", RCB.comboBG, "TOPLEFT", pos, 0)
	line:SetColorTexture(0, 0, 0, 1)
end

-- Power bar
RCB.powerBG = RCB:CreateTexture(nil, "BACKGROUND", nil, 1)
RCB.powerBG:SetPoint("BOTTOMLEFT", RCB, "BOTTOMLEFT", 0, 0)
RCB.powerBG:SetPoint("BOTTOMRIGHT", RCB, "BOTTOMRIGHT", 0, 0)
RCB.powerBG:SetHeight(RCB.Settings.height/2)
RCB.powerBG:SetColorTexture(0, 0, 0, 0.0)

RCB.border = CreateFrame("Frame", nil, RCB, "BackdropTemplate")
RCB.border:SetAllPoints(RCB)
RCB.border:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
RCB.border:SetBackdropBorderColor(0, 0, 0, 1)

RCB.powerBorder = CreateFrame("Frame", nil, RCB, "BackdropTemplate")
RCB.powerBorder:SetAllPoints(RCB.powerBG)
RCB.powerBorder:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
RCB.powerBorder:SetBackdropBorderColor(0, 0, 0, 1)

RCB.powerBar = RCB:CreateTexture(nil, "ARTWORK")
RCB.powerBar:SetPoint("TOPLEFT", RCB.powerBG, "TOPLEFT", 1, -1)
RCB.powerBar:SetPoint("BOTTOMLEFT", RCB.powerBG, "BOTTOMLEFT", 1, 1)
RCB.powerBar:SetWidth(1)
RCB.powerBar:SetColorTexture(0.1, 0.2, 0.85, 1)

RCB.powerValueText = RCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
RCB.powerValueText:SetPoint("CENTER", RCB.powerBG, "CENTER")
RCB.powerValueText:SetTextColor(1, 1, 1, 1)
RCB.powerValueText:SetFont(RCB.powerValueText:GetFont(), 12, "OUTLINE")

RCB.powerPercentText = RCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
RCB.powerPercentText:SetPoint("RIGHT", RCB.powerBG, "RIGHT", -4, 0)
RCB.powerPercentText:SetTextColor(1, 1, 1, 1)
RCB.powerPercentText:SetFont(RCB.powerPercentText:GetFont(), 12, "OUTLINE")

-- Drag
function OnDragStart(self)
	if not RCB.Settings.locked then
		self:StartMoving()
	end
end
function OnDragStop(self)
	if not RCB.Settings.locked then
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		RCB.x = xOfs
		RCB.y = yOfs
	end
end
RCB:EnableMouse(true)
RCB:SetMovable(true)
RCB:RegisterForDrag("LeftButton")
RCB:SetScript("OnDragStart", OnDragStart)
RCB:SetScript("OnDragStop", OnDragStop)

-- Events
function EventHandler(self, e, ...)
	if e == "ADDON_LOADED" then
		local addonName = ...
		if not addonName == "ResourceComboBars" then
			return
		end
		RCB:SetPointGetter(GetAuraStack(53817, "HELPFUL"))
		RCB()
		local h = RCB.Settings.height/2
		RCB.comboBG:SetHeight(h)
		RCB.powerBG:SetHeight(h)
	elseif
		e == "UNIT_POWER_UPDATE" or
		e == "UNIT_POWER_FREQUENT" or
		e == "UNIT_MAXPOWER"
	then
		local unit = ...
		if unit == "player" then
			RCB_Update()
		end
	elseif e == "PLAYER_ENTERING_WORLD" or e == "PLAYER_TARGET_CHANGED" then
		RCB_Update()
	elseif e == "UNIT_AURA" then
		local points = GetComboPoints()
		RCB.comboValueText:SetText(points)
		local width = (RCB.Settings.width - RCB.Settings.borderWidth) * (points / MaxComboPoints)
		RCB.comboBar:SetWidth(width)
		local unit = ...
		if not unit == "player" then return end
	end
end
RCB:SetScript("OnEvent", EventHandler)
RCB:RegisterEvent("ADDON_LOADED")
RCB:RegisterEvent("UNIT_POWER_UPDATE")
RCB:RegisterEvent("UNIT_POWER_FREQUENT")
RCB:RegisterEvent("UNIT_MAXPOWER")
RCB:RegisterEvent("PLAYER_ENTERING_WORLD")
RCB:RegisterEvent("PLAYER_TARGET_CHANGED")
RCB:RegisterEvent("UNIT_AURA")

function RCB_Update()
	local power = UnitPower("player")
	local powerMax = UnitPowerMax("player")
	local powerType = UnitPowerType("player")

	local powerPercent = powerMax > 0 and (power / powerMax) or 0
	RCB.powerBar:SetWidth((RCB.Settings.width - RCB.Settings.borderWidth * 2) * powerPercent)
	local color = getPowerColor(powerType)
	RCB.powerBar:SetColorTexture(unpack(color))
	local powerValueText = ""
	local powerPercentText = ""
	if RCB.Settings.showPowerValues and powerMax > 0 then
		local powerStr = power >= 1000 and (math.floor(power/100)/10) .. "k" or tostring(power)
		if RCB.Settings.showMaxValues then
			local powerMaxStr = powerMax >= 1000 and (math.floor(powerMax/100)/10) .. "k" or tostring(powerMax)
			powerValueText = powerStr .. " / " .. powerMaxStr
		else
			powerValueText = powerStr
		end
	end
	if RCB.Settings.showPowerPercent and powerMax > 0 then
		powerPercentText = math.floor(powerPercent * 100) .. "%"
	end
	RCB.powerValueText:SetText(powerValueText)
	RCB.powerPercentText:SetText(powerPercentText)

	RCB.comboValueText:SetText(GetComboPoints())
end
