﻿local _, ns = ...
local B, C, L, DB, F = unpack(ns)

local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags
local ipairs, strmatch, unpack = ipairs, string.match, unpack
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE, LE_ITEM_QUALITY_ARTIFACT, LE_ITEM_QUALITY_HEIRLOOM = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE, LE_ITEM_QUALITY_ARTIFACT, LE_ITEM_QUALITY_HEIRLOOM
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC
local GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem = GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem
local C_NewItems_IsNewItem, C_Timer_After = C_NewItems.IsNewItem, C_Timer.After
local IsControlKeyDown, IsAltKeyDown, DeleteCursorItem = IsControlKeyDown, IsAltKeyDown, DeleteCursorItem

function module:UpdateAnchors(parent, bags)
	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end
		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 5)
			anchor = bag
		end
	end
end

function module:DisableAuroraClassic()
	if F then
		AuroraOptionsbags:SetAlpha(0)
		AuroraOptionsbags:Disable()
		AuroraConfig.bags = false
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

function module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(220, 32)
	B.CreateFS(infoFrame, 14, SEARCH, true, "LEFT", -5, 0)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBG(search)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	B.CreateBD(bg, .3)
	if F then F.CreateGradient(bg) end

	local tag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("RIGHT", -5, 0)
end

function module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 5, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	B.SetBackground(bagBar)
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function module:CreateCloseButton()
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	bu:SetScript("OnClick", CloseAllBags)
	B.AddTooltip(bu, "ANCHOR_TOP", CLOSE)

	return bu
end

function module:CreateRestoreButton(f)
	local bu = B.CreateButton(self, 24, 24, true, "Atlas:transmog-icon-revert")
	bu:SetScript("OnClick", function()
		NDuiDB["TempAnchor"][f.main:GetName()] = nil
		NDuiDB["TempAnchor"][f.bank:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", RESET)

	return bu
end

function module:CreateBagToggle()
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Buttons\\Button-Backpack-Up")
	bu:SetScript("OnClick", function()
		ToggleFrame(self.BagBar)
		if self.BagBar:IsShown() then
			bu:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bu:SetBackdropBorderColor(0, 0, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", BACKPACK_TOOLTIP)

	return bu
end

function module:CreateSortButton(name)
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Icons\\ABILITY_SEAL")
	bu:SetScript("OnClick", function()
		if name == "Bank" then
			-- BANK SORT
		else
			-- BAG SORT
			-- NDuiDB["Bags"]["ReverseSort"]
		end
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", L["Sort"])

	return bu
end

local deleteEnable
function module:CreateDeleteButton()
	local disabledText = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t"..L["ItemDeleteMode"]
	local enabledText = disabledText.."\n\n"..DB.InfoColor..L["DeleteMode Enabled"]

	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	bu:SetScript("OnClick", function(self)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			self:SetBackdropBorderColor(0, 0, 0)
			self.text = disabledText
		end
		self:GetScript("OnEnter")(self)
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", disabledText)

	return bu
end

local function deleteButtonOnClick(self)
	if not deleteEnable then return end
	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE or quality == LE_ITEM_QUALITY_HEIRLOOM) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

function module:OnLogin()
	if not NDuiDB["Bags"]["Enable"] then return end

	-- Settings
	local bagsScale = NDuiDB["Bags"]["BagsScale"]
	local bagsWidth = NDuiDB["Bags"]["BagsWidth"]
	local bankWidth = NDuiDB["Bags"]["BankWidth"]
	local iconSize = NDuiDB["Bags"]["IconSize"]
	local artifaceMark = NDuiDB["Bags"]["Artifact"]
	local showItemLevel = NDuiDB["Bags"]["BagsiLvl"]
	local deleteButton = NDuiDB["Bags"]["DeleteButton"]
	local itemSetFilter = NDuiDB["Bags"]["ItemSetFilter"]

	-- Init
	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(bagsScale)
	Backpack:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
	Backpack:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

	local f = {}
	local onlyBags, bagAzeriteItem, bagEquipment, bagConsumble, bagsJunk, onlyBank, bankAzeriteItem, bankLegendary, bankEquipment, bankConsumble, onlyReagent, bagMountPet, bankMountPet = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)

		f.junk = MyContainer:New("Junk", {Columns = bagsWidth, Parent = f.main})
		f.junk:SetFilter(bagsJunk, true)

		f.equipment = MyContainer:New("Equipment", {Columns = bagsWidth, Parent = f.main})
		f.equipment:SetFilter(bagEquipment, true)

		f.consumble = MyContainer:New("Consumble", {Columns = bagsWidth, Parent = f.main})
		f.consumble:SetFilter(bagConsumble, true)

		f.bagCompanion = MyContainer:New("BagCompanion", {Columns = bagsWidth, Parent = f.main})
		f.bagCompanion:SetFilter(bagMountPet, true)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.bank:Hide()

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = bankWidth, Parent = f.bank})
		f.bankLegendary:SetFilter(bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = bankWidth, Parent = f.bank})
		f.bankEquipment:SetFilter(bankEquipment, true)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = bankWidth, Parent = f.bank})
		f.bankConsumble:SetFilter(bankConsumble, true)

		f.bankCompanion = MyContainer:New("BankCompanion", {Columns = bankWidth, Parent = f.bank})
		f.bankCompanion:SetFilter(bankMountPet, true)
	end

	function Backpack:OnBankOpened()
		self:GetContainer("Bank"):Show()
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetHighlightTexture(DB.bdTex)
		self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFont(unpack(DB.Font))

		self.BG = B.CreateBG(self)
		B.CreateBD(self.BG, .3)

		self.junkIcon = self:CreateTexture(nil, "ARTWORK")
		self.junkIcon:SetAtlas("bags-junkcoin")
		self.junkIcon:SetSize(20, 20)
		self.junkIcon:SetPoint("TOPRIGHT", 1, 0)

		--self.Quest = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)

		if artifaceMark then
			self.Artifact = self:CreateTexture(nil, "ARTWORK")
			self.Artifact:SetAtlas("collections-icon-favorites")
			self.Artifact:SetSize(35, 35)
			self.Artifact:SetPoint("TOPLEFT", -12, 10)
		end

		if showItemLevel then
			self.iLvl = B.CreateFS(self, 12, "", false, "BOTTOMLEFT", 1, 1)
		end

		self.glowFrame = B.CreateBG(self, 4)
		self.glowFrame:SetSize(iconSize+8, iconSize+8)

		if deleteButton then
			self:HookScript("OnClick", deleteButtonOnClick)
		end
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame then B.HideOverlayGlow(self.glowFrame) end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.junkIcon:SetAlpha(1)
		else
			self.junkIcon:SetAlpha(0)
		end

		if artifaceMark then
			if item.rarity == LE_ITEM_QUALITY_ARTIFACT or item.id == 138019 then
				self.Artifact:SetAlpha(1)
			else
				self.Artifact:SetAlpha(0)
			end
		end

		if showItemLevel then
			if item.link and item.level and item.rarity > 1 and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR) then
				local level = B.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
				local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				self.iLvl:SetText("")
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				B.ShowOverlayGlow(self.glowFrame)
			else
				B.HideOverlayGlow(self.glowFrame)
			end
		end
	end

	function MyButton:OnUpdateQuest(item)
		--[[if item.questID and not item.questActive then
			self.Quest:SetAlpha(1)
		else
			self.Quest:SetAlpha(0)
		end]]

		if item.isQuestItem then
			self.BG:SetBackdropBorderColor(.8, .8, 0)
		elseif item.rarity and item.rarity > -1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self.BG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.BG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local MyContainer = Backpack:GetContainerClass()
	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local offset = 38
		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 5, 5, -offset + 5)
		self:SetSize(width + 10, height + offset)

		module:UpdateAnchors(f.main, {f.equipment, f.bagCompanion, f.consumble, f.junk})
		module:UpdateAnchors(f.bank, {f.bankEquipment, f.bankLegendary, f.bankCompanion, f.bankConsumble})
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		B.SetBackground(self)
		B.CreateMF(self, settings.Parent, true)

		local label
		if strmatch(name, "AzeriteItem$") then
			label = L["Azerite Armor"]
		elseif strmatch(name, "Equipment$") then
			if itemSetFilter then
				label = L["Equipement Set"]
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif strmatch(name, "Companion") then
			label = MOUNTS_AND_PETS
		end
		if label then B.CreateFS(self, 14, label, true, "TOPLEFT", 5, -8) return end

		module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = module.CreateCloseButton(self)
		if name == "Main" then
			module.CreateBagBar(self, settings, 4)
			buttons[2] = module.CreateRestoreButton(self, f)
			buttons[3] = module.CreateBagToggle(self)
			if deleteButton then buttons[4] = module.CreateDeleteButton(self) end
		elseif name == "Bank" then
			module.CreateBagBar(self, settings, 7)
			buttons[2] = module.CreateBagToggle(self)
		end

		for i = 1, 4 do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -5, -3)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -3, 0)
			end
		end

		self:HookScript("OnShow", B.RestoreMF)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetHighlightTexture(DB.bdTex)
		self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)

		self:SetSize(iconSize, iconSize)
		self.BG = B.CreateBG(self)
		B.CreateBD(self.BG, 0)
		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		local quality = id and select(3, GetItemInfo(id)) or 0
		if quality == 1 then quality = 0 end
		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if not self.hidden and not self.notBought then
			self.BG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.BG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	-- Fixes
	ToggleAllBags()
	ToggleAllBags()
	BankFrame.GetRight = function() return f.bank:GetRight() end
	BankFrameItemButton_Update = B.Dummy

	SetInsertItemsLeftToRight(false)
	module:DisableAuroraClassic()
end