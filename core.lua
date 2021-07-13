local addon, name = ...
local ldb = nil
local initialPos = {}

local next = next
local text = nil

local function getInitialPos()
  initialPos.y, initialPos.x = UnitPosition('Player')
end

local function resetPos()
  initialPos = {}
  text:SetText('0')
end

local function calcDistance()
  local y1, x1 = initialPos.y, initialPos.x
  local y2, x2 = UnitPosition('player')
  text:SetText(string.format('%.3f', ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5))
end

local frame = CreateFrame('frame', 'snwDistance', UIParent)

local timeElapsed = 0
frame:HookScript("OnUpdate", function(self, elapsed)
	timeElapsed = timeElapsed + elapsed
	if timeElapsed > 0.5 then
		timeElapsed = 0
		if next(initialPos) ~= nil then
      calcDistance()
    end
	end
end)

frame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = {left = 1, right = 1, top = 1, bottom = 1}
})

frame:RegisterEvent('ADDON_LOADED')

frame:SetSize(300, 150)
frame:SetPoint('CENTER', UIParent, 'CENTER')
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:SetFrameStrata("DIALOG")

local tex = frame:CreateTexture(nil, 'DIALOG')
tex:SetAllPoints(frame)
tex:SetColorTexture(0, 0, 0, 0.5)

local pos1 = CreateFrame("button", nil, frame, "UIPanelButtonTemplate")
pos1:SetHeight(24)
pos1:SetWidth(120)
pos1:SetPoint("BOTTOM", frame, "BOTTOMLEFT", 70, 40)
pos1:SetText("Set Pos")
pos1:SetScript("OnClick", getInitialPos)

local clear = CreateFrame("button", nil, frame, "UIPanelButtonTemplate")
clear:SetHeight(24)
clear:SetWidth(120)
clear:SetPoint("BOTTOM", frame, "BOTTOMLEFT", 70, 10)
clear:SetText("Clear")
clear:SetScript("OnClick", resetPos)

local close = CreateFrame("button", nil, frame, "UIPanelButtonTemplate")
close:SetHeight(24)
close:SetWidth(120)
close:SetPoint("BOTTOM", frame, "BOTTOMRIGHT", -70, 10)
close:SetText("Close")
close:SetScript("OnClick", function(self) self:GetParent():Hide() end)

text = frame:CreateFontString(frame, "OVERLAY", "GameFontNormalWTF2Outline")
text:SetPoint("TOP", 0, -30)
text:SetText('0')

local function toggleFrame()
  if frame:IsShown() then
    frame:Hide()
  else
    frame:Show()
  end
end

-- LDB ---------------------------------------------------------------------- --
do
	local libLdb = LibStub("LibDataBroker-1.1")
	if libLdb then
		ldb = libLdb:NewDataObject("snwDistance", {
			type = "launcher",
			label = "snwDistance",
			icon = "Interface\\AddOns\\snwDistance\\media\\icon",
		})

		function ldb.OnClick(self, button)
			toggleFrame()
		end
  end
end

frame:SetScript('OnEvent', function(self, e, ...)
  if e == 'ADDON_LOADED' then
    local args = ...
    if args ~= 'snwDistance' then return end
    local icon = LibStub("LibDBIcon-1.0")
    if icon and ldb then
      icon:Register("snwDistance", ldb, {})
    end
  end
end)