local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("AurasTable")
local pairs, next, format, wipe = pairs, next, string.format, wipe

-- AuraWatch
local AuraWatchList = {}
local groups = {
	-- groups name = direction, interval, mode, iconsize, position, barwidth
	["Player Aura"] = {"LEFT", 5, "ICON", 22, C.Auras.PlayerAuraPos},
	["Target Aura"] = {"RIGHT", 5, "ICON", 36, C.Auras.TargetAuraPos},
	["Special Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.SpecialPos},
	["Focus Aura"] = {"RIGHT", 5, "ICON", 35, C.Auras.FocusPos},
	["Spell Cooldown"] = {"UP", 5, "BAR", 18, C.Auras.CDPos, 150},
	["Enchant Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.EnchantPos},
	["Raid Buff"] = {"LEFT", 5, "ICON", 42, C.Auras.RaidBuffPos},
	["Raid Debuff"] = {"RIGHT", 5, "ICON", 42, C.Auras.RaidDebuffPos},
	["Warning"] = {"RIGHT", 5, "ICON", 42, C.Auras.WarningPos},
	["InternalCD"] = {"UP", 5, "BAR", 18, C.Auras.InternalPos, 150},
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					wipe(v)
					if DB.isDeveloper then
						print(format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= DB.MyClass then return end
	if not AuraWatchList[class] then AuraWatchList[class] = {} end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		tinsert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v)
		})
	end
end

function module:AddDeprecatedGroup()
	if not NDuiDB["AuraWatch"]["DeprecatedAuras"] then return end

	for name, value in pairs(C.DeprecatedAuras) do
		for _, list in pairs(AuraWatchList["ALL"]) do
			if list.Name == name then
				local newTable = newAuraFormat(value)
				for spellID, v in pairs(newTable) do
					list.List[spellID] = v
				end
			end
		end
	end
	wipe(C.DeprecatedAuras)
end

-- RaidFrame spells
local RaidBuffs = {}
function module:AddClassSpells(list)
	for class, value in pairs(list) do
		if class == "ALL" or class == "WARNING" or class == DB.MyClass then
			RaidBuffs[class] = value
		end
	end
end

-- RaidFrame debuffs
local RaidDebuffs = {}
function module:RegisterDebuff(_, instID, _, spellID, level)
	--local instName = EJ_GetInstanceInfo(instID)
	local instName = instID
	if not instName then print("Invalid instance ID: "..instID) return end

	if not RaidDebuffs[instName] then RaidDebuffs[instName] = {} end
	if level then
		if level > 6 then level = 6 end
	else
		level = 2
	end

	RaidDebuffs[instName][spellID] = level
end

function module:OnLogin()
	for instName, value in pairs(RaidDebuffs) do
		for spell, priority in pairs(value) do
			if NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spell] and NDuiADB["RaidDebuffs"][instName][spell] == priority then
				NDuiADB["RaidDebuffs"][instName][spell] = nil
			end
		end
	end
	for instName, value in pairs(NDuiADB["RaidDebuffs"]) do
		if not next(value) then
			NDuiADB["RaidDebuffs"][instName] = nil
		end
	end

	self:AddDeprecatedGroup()
	C.AuraWatchList = AuraWatchList
	C.RaidBuffs = RaidBuffs
	C.RaidDebuffs = RaidDebuffs

	if not NDuiADB["CornerBuffs"][DB.MyClass] then NDuiADB["CornerBuffs"][DB.MyClass] = {} end
	if not next(NDuiADB["CornerBuffs"][DB.MyClass]) then
		B.CopyTable(C.CornerBuffs[DB.MyClass], NDuiADB["CornerBuffs"][DB.MyClass])
	end

	-- Filter bloodlust for healers
	local bloodlustList = {57723, 57724, 80354, 264689}
	local function filterBloodlust()
		for _, spellID in pairs(bloodlustList) do
			NDuiADB["CornerBuffs"][DB.MyClass][spellID] = DB.Role ~= "Healer" and {"BOTTOMLEFT", {1, .8, 0}, true} or nil
			C.RaidBuffs["WARNING"][spellID] = (DB.Role ~= "Healer")
		end
	end
	filterBloodlust()
	B:RegisterEvent("CHARACTER_POINTS_CHANGED", filterBloodlust)
end