local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF or oUF
local UF = B:GetModule("UnitFrames")
local format, tostring = string.format, tostring

-- Units
local function CreatePlayerStyle(self)
	self.mystyle = "player"
	self:SetSize(245, 24*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAddPower(self)

	if NDuiDB["UFs"]["Castbars"] then
		UF:ReskinMirrorBars()
		UF:ReskinTimerTrakcer(self)
	end
	if NDuiDB["UFs"]["ClassPower"] and not NDuiDB["Nameplate"]["ShowPlayerPlate"] then
		UF:CreateClassPower(self)
		UF:StaggerBar(self)
	end
	if not NDuiDB["Misc"]["ExpRep"] then UF:CreateExpRepBar(self) end
	if NDuiDB["UFs"]["PlayerDebuff"] then UF:CreateDebuffs(self) end
	if NDuiDB["UFs"]["SwingBar"] then UF:CreateSwing(self) end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	self:SetSize(245, 24*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAuras(self)
end

local function CreateFocusStyle(self)
	self.mystyle = "focus"
	self:SetSize(200, 22*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
end

local function CreateToTStyle(self)
	self.mystyle = "tot"
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)

	if NDuiDB["UFs"]["ToTAuras"] then UF:CreateAuras(self) end
end

local function CreateFocusTargetStyle(self)
	self.mystyle = "focustarget"
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreateBossStyle(self)
	self.mystyle = "boss"
	self:SetSize(150, 22*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
end

local function CreateArenaStyle(self)
	self.mystyle = "arena"
	self:SetSize(150, 22*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreateTargetBorder(self)
	UF:CreateRaidIcons(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	--UF:CreateRaidDebuffs(self)
	UF:CreateThreatBorder(self)
	UF:CreateAuras(self)
	UF:CreateBuffIndicator(self)
end

local function CreatePartyStyle(self)
	self.isPartyFrame = true
	CreateRaidStyle(self)
	UF:InterruptIndicator(self)
end

-- Spawns
function UF:OnLogin()
	local horizonRaid = NDuiDB["UFs"]["HorizonRaid"]
	local horizonParty = NDuiDB["UFs"]["HorizonParty"]
	local numGroups = NDuiDB["UFs"]["NumGroups"]
	local scale = NDuiDB["UFs"]["RaidScale"]
	local raidWidth, raidHeight = NDuiDB["UFs"]["RaidWidth"], NDuiDB["UFs"]["RaidHeight"]
	local reverse = NDuiDB["UFs"]["ReverseRaid"]
	local showPartyFrame = NDuiDB["UFs"]["PartyFrame"]
	local partyWidth, partyHeight = NDuiDB["UFs"]["PartyWidth"], NDuiDB["UFs"]["PartyHeight"]

	if NDuiDB["Nameplate"]["Enable"] then
		self:SetupCVars()
		self:BlockAddons()
		self:CreateUnitTable()
		self:CreatePowerUnitTable()
		self:AddInterruptInfo()
		--self:UpdateGroupRoles()
		self:QuestIconCheck()

		oUF:RegisterStyle("Nameplates", UF.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", UF.PostUpdatePlates)
	end

	if NDuiDB["Nameplate"]["ShowPlayerPlate"] then
		oUF:RegisterStyle("PlayerPlate", UF.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		B.Mover(plate, L["PlayerNP"], "PlayerPlate", C.UFs.PlayerPlate, plate:GetWidth(), 20)
	end

	-- Default Clicksets for RaidFrame
	self:DefaultClickSets()

	if NDuiDB["UFs"]["Enable"] then
		-- Register
		oUF:RegisterStyle("Player", CreatePlayerStyle)
		oUF:RegisterStyle("Target", CreateTargetStyle)
		oUF:RegisterStyle("ToT", CreateToTStyle)
		oUF:RegisterStyle("Focus", CreateFocusStyle)
		oUF:RegisterStyle("FocusTarget", CreateFocusTargetStyle)
		oUF:RegisterStyle("Pet", CreatePetStyle)

		-- Loader
		oUF:SetActiveStyle("Player")
		local player = oUF:Spawn("player", "oUF_Player")
		B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos, 245, 30)

		oUF:SetActiveStyle("Target")
		local target = oUF:Spawn("target", "oUF_Target")
		B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos, 245, 30)

		oUF:SetActiveStyle("ToT")
		local targettarget = oUF:Spawn("targettarget", "oUF_ToT")
		B.Mover(targettarget, L["TotUF"], "TotUF", C.UFs.ToTPos, 120, 30)

		oUF:SetActiveStyle("Pet")
		local pet = oUF:Spawn("pet", "oUF_Pet")
		B.Mover(pet, L["PetUF"], "PetUF", C.UFs.PetPos, 120, 30)

		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos, 200, 30)

		oUF:SetActiveStyle("FocusTarget")
		local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		B.Mover(focustarget, L["FotUF"], "FotUF", C.UFs.FoTPos, 120, 30)

		oUF:RegisterStyle("Boss", CreateBossStyle)
		oUF:SetActiveStyle("Boss")
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
			local moverWidth, moverHeight = boss[i]:GetWidth(), boss[i]:GetHeight()+8
			if i == 1 then
				boss[i].mover = B.Mover(boss[i], L["BossFrame"]..i, "Boss1", {"RIGHT", UIParent, "RIGHT", -350, -90}, moverWidth, moverHeight)
			else
				boss[i].mover = B.Mover(boss[i], L["BossFrame"]..i, "Boss"..i, {"BOTTOM", boss[i-1], "TOP", 0, 50}, moverWidth, moverHeight)
			end
		end

		if NDuiDB["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				arena[i]:SetPoint("TOPLEFT", boss[i].mover)
			end
		end
	end

	if NDuiDB["UFs"]["RaidFrame"] then
		UF:AddClickSetsListener()

		-- Hide Default RaidFrame
		local function HideRaid()
			if InCombatLockdown() then return end
			B.HideObject(CompactRaidFrameManager)
			local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
			if compact_raid and compact_raid ~= "0" then
				CompactRaidFrameManager_SetSetting("IsShown", "0")
			end
		end
		CompactRaidFrameManager:HookScript("OnShow", HideRaid)
		if CompactRaidFrameManager_UpdateShown then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
		end
		CompactRaidFrameContainer:UnregisterAllEvents()

		-- Group Styles
		if showPartyFrame then
			oUF:RegisterStyle("Party", CreatePartyStyle)
			oUF:SetActiveStyle("Party")

			local xOffset, yOffset = 5, 10
			local moverWidth = horizonParty and (partyWidth*5+xOffset*4) or partyWidth
			local moverHeight = horizonParty and partyHeight or (partyHeight*5+yOffset*4)
			local groupingOrder = horizonParty and "TANK,HEALER,DAMAGER,NONE" or "NONE,DAMAGER,HEALER,TANK"

			local party = oUF:SpawnHeader("oUF_Party", nil, "solo,party",
			"showPlayer", true,
			"showSolo", false,
			"showParty", true,
			"showRaid", false,
			"xoffset", xOffset,
			"yOffset", yOffset,
			"groupFilter", "1",
			"groupingOrder", groupingOrder,
			"groupBy", "ASSIGNEDROLE",
			"sortMethod", "NAME",
			"point", horizonParty and "LEFT" or "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			]]):format(partyWidth, partyHeight))

			local partyMover = B.Mover(party, L["PartyFrame"], "PartyFrame", {"LEFT", UIParent, 350, 0}, moverWidth, moverHeight)
			party:ClearAllPoints()
			party:SetPoint("BOTTOMLEFT", partyMover)
		end

		oUF:RegisterStyle("Raid", CreateRaidStyle)
		oUF:SetActiveStyle("Raid")

		local raidMover
		if NDuiDB["UFs"]["SimpleMode"] then
			local groupingOrder, groupBy, sortMethod = "1,2,3,4,5,6,7,8", "GROUP", "INDEX"
			if NDuiDB["UFs"]["SimpleModeSortByRole"] then
				groupingOrder, groupBy, sortMethod = "TANK,HEALER,DAMAGER,NONE", "ASSIGNEDROLE", "NAME"
			end

			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
				"showPlayer", true,
				"showSolo", false,
				"showParty", not showPartyFrame,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -10,
				"groupFilter", tostring(i),
				"groupingOrder", groupingOrder,
				"groupBy", groupBy,
				"sortMethod", sortMethod,
				"maxColumns", 2,
				"unitsPerColumn", 20,
				"columnSpacing", 5,
				"point", "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(100*scale, 20*scale))
				return group
			end

			local groupFilter
			if numGroups == 4 then
				groupFilter = "1,2,3,4"
			elseif numGroups == 5 then
				groupFilter = "1,2,3,4,5"
			elseif numGroups == 6 then
				groupFilter = "1,2,3,4,5,6"
			elseif numGroups == 7 then
				groupFilter = "1,2,3,4,5,6,7"
			elseif numGroups == 8 then
				groupFilter = "1,2,3,4,5,6,7,8"
			end

			local group = CreateGroup("oUF_Raid", groupFilter)
			local moverWidth = numGroups > 4 and (100*scale*2 + 5) or 100
			local moverHeight = 20*scale*20 + 10*19
			raidMover = B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, moverWidth, moverHeight)
		else
			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
				"showPlayer", true,
				"showSolo", false,
				"showParty", not showPartyFrame,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -10,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizonRaid and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(raidWidth, raidHeight))
				return group
			end

			local groups = {}
			for i = 1, numGroups do
				groups[i] = CreateGroup("oUF_Raid"..i, i)
				if i == 1 then
					if horizonRaid then
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, (raidWidth+5)*5, (raidHeight+(NDuiDB["UFs"]["ShowTeamIndex"] and 25 or 15))*numGroups)
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("BOTTOMLEFT", raidMover)
						end
					else
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, (raidWidth+5)*numGroups, (raidHeight+10)*5)
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("TOPRIGHT", raidMover)
						end
					end
				else
					if horizonRaid then
						if reverse then
							groups[i]:SetPoint("BOTTOMLEFT", groups[i-1], "TOPLEFT", 0, NDuiDB["UFs"]["ShowTeamIndex"] and 25 or 15)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, NDuiDB["UFs"]["ShowTeamIndex"] and -25 or -15)
						end
					else
						if reverse then
							groups[i]:SetPoint("TOPRIGHT", groups[i-1], "TOPLEFT", -5, 0)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0)
						end
					end
				end

				if NDuiDB["UFs"]["ShowTeamIndex"] then
					local parent = _G["oUF_Raid"..i.."UnitButton1"]
					local teamIndex = B.CreateFS(parent, 12, format(GROUP_NUMBER, i))
					teamIndex:ClearAllPoints()
					teamIndex:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 5)
					teamIndex:SetTextColor(.6, .8, 1)
				end
			end
		end

		if raidMover then
			if DB.isClassic then return end
			if not NDuiDB["UFs"]["SpecRaidPos"] then return end

			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "PLAYER_ENTERING_WORLD" then
					if not GetSpecialization() then return end
					local specIndex = GetSpecialization()
					if not NDuiDB["Mover"]["RaidPos"..specIndex] then
						NDuiDB["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 35, -50}
					end
					raidMover:ClearAllPoints()
					raidMover:SetPoint(unpack(NDuiDB["Mover"]["RaidPos"..specIndex]))
				end
			end
			B:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateSpecPos)
			B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			raidMover:HookScript("OnDragStop", function()
				if not GetSpecialization() then return end
				local specIndex = GetSpecialization()
				NDuiDB["Mover"]["RaidPos"..specIndex] = NDuiDB["Mover"]["RaidFrame"]
			end)
		end
	end
end