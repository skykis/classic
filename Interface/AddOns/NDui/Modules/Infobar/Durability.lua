local _, ns = ...
local B, C, L, DB, F = unpack(ns)
if not C.Infobar.Durability then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Durability", C.Infobar.DurabilityPos)

local format, gsub, sort, floor, modf, select = string.format, string.gsub, table.sort, math.floor, math.modf, select
local GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture = GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture
local GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair = GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair
local C_Timer_After, IsShiftKeyDown, InCombatLockdown, CanMerchantRepair = C_Timer.After, IsShiftKeyDown, InCombatLockdown, CanMerchantRepair

local localSlots = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_CHEST, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {9, INVTYPE_WRIST, 1000},
	[6] = {10, L["Hands"], 1000},
	[7] = {7, INVTYPE_LEGS, 1000},
	[8] = {8, L["Feet"], 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000}
}

local inform = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
inform:SetPoint("BOTTOM", info, "TOP", 0, 23)
inform.Text:SetText(L["Low Durability"])
inform:Hide()

local function sortSlots(a, b)
	if a and b then
		return a[3] < b[3]
	end
end

local function getItemDurability()
	local numSlots = 0
	for i = 1, 10 do
		if GetInventoryItemLink("player", localSlots[i][1]) then
			local current, max = GetInventoryItemDurability(localSlots[i][1])
			if current then
				localSlots[i][3] = current/max
				numSlots = numSlots + 1
			end
		else
			localSlots[i][3] = 1000
		end
	end
	sort(localSlots, sortSlots)

	return numSlots
end

local function isLowDurability()
	for i = 1, 10 do
		if localSlots[i][3] < .25 then
			return true
		end
	end
end

local function gradientColor(perc)
	perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1
	local seg, relperc = modf(perc*2)
	local r1, g1, b1, r2, g2, b2 = select(seg*3+1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0) -- R -> Y -> G
	local r, g, b = r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
	return format("|cff%02x%02x%02x", r*255, g*255, b*255), r, g, b
end

info.eventList = {
	"UPDATE_INVENTORY_DURABILITY", "PLAYER_ENTERING_WORLD",
}

info.onEvent = function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if F then F.ReskinClose(inform.CloseButton) end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
		self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		getItemDurability()
		if isLowDurability() then inform:Show() end
	else
		local numSlots = getItemDurability()
		if numSlots > 0 then
			self.text:SetText(format(gsub("[color]%d|r%%"..L["D"], "%[color%]", (gradientColor(floor(localSlots[1][3]*100)/100))), floor(localSlots[1][3]*100)))
		else
			self.text:SetText(L["D"]..": "..DB.MyColor..NONE)
		end

		if isLowDurability() then inform:Show() else inform:Hide() end
	end
end

inform.CloseButton:HookScript("OnClick", function()
	if InCombatLockdown() then
		info:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		info:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end)

info.onMouseUp = function(self, btn)
	if btn == "MiddleButton" then
		NDuiADB["RepairType"] = mod(NDuiADB["RepairType"] + 1, 3)
		self:onEnter()
	else
		ToggleCharacter("PaperDollFrame")
	end
end

local repairlist = {
	[0] = "|cffff5555"..VIDEO_OPTIONS_DISABLED,
	[1] = "|cff55ff55"..VIDEO_OPTIONS_ENABLED,
	[2] = "|cffffff55"..L["NFG"]
}

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 15)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(DURABILITY, " ", 0,.6,1, 0,.6,1)
	GameTooltip:AddLine(" ")

	for i = 1, 10 do
		if localSlots[i][3] ~= 1000 then
			local green = localSlots[i][3]*2
			local red = 1 - green
			local slotIcon = "|T"..GetInventoryItemTexture("player", localSlots[i][1])..":13:15:0:0:50:50:4:46:4:46|t " or ""
			GameTooltip:AddDoubleLine(slotIcon..localSlots[i][2], floor(localSlots[i][3]*100).."%", 1,1,1, red+1,green,0)
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Player Panel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Auto Repair"]..": "..repairlist[NDuiADB["RepairType"]].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

-- Auto repair
local isShown, isBankEmpty, autoRepair, repairAllCost, canRepair

local function delayFunc()
	if isBankEmpty then
		autoRepair(true)
	else
		print(format(DB.InfoColor.."%s|r%s", L["Guild repair"], module:GetMoneyString(repairAllCost)))
	end
end

function autoRepair(override)
	if isShown and not override then return end
	isShown = true
	isBankEmpty = false

	local myMoney = GetMoney()
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
		if (not override) and NDuiADB["RepairType"] == 1 and not DB.isClassic then
			RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				RepairAllItems()
				print(format(DB.InfoColor.."%s|r%s", L["Repair cost"], module:GetMoneyString(repairAllCost)))
				return
			else
				print(DB.InfoColor..L["Repair error"])
				return
			end
		end

		C_Timer_After(.5, delayFunc)
	end
end

local function checkBankFund(_, msgType)
	if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		isBankEmpty = true
	end
end

local function merchantClose()
	isShown = false
	B:UnregisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	B:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
end

local function merchantShow()
	if IsShiftKeyDown() or NDuiADB["RepairType"] == 0 or not CanMerchantRepair() then return end
	autoRepair()
	B:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	B:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end
B:RegisterEvent("MERCHANT_SHOW", merchantShow)