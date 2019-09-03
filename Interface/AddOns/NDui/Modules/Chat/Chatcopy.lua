local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local module = B:GetModule("Chat")

local _G = getfenv(0)
local gsub, format, tconcat, tostring = string.gsub, string.format, table.concat, tostring
local ToggleFrame = ToggleFrame
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel

local lines, menu, frame, editBox = {}

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then return id end
end

local function isMessageProtected(msg)
	return msg and (msg ~= gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function colorReplace(msg, r, g, b)
	local hexRGB = B.HexRGB(r, g, b)
	local hexReplace = format("|r%s", hexRGB)
	msg = gsub(msg, "|r", hexReplace)
	msg = format("%s%s|r", hexRGB, msg)

	return msg
end

function module:GetChatLines()
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = colorReplace(msg, r, g, b)
			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	return index - 1
end

function module:ChatCopy_OnClick(btn)
	if btn == "LeftButton" then
		if not frame:IsShown() then
			local chatframe = _G.SELECTED_DOCK_FRAME
			local _, fontSize = chatframe:GetFont()
			FCF_SetChatWindowFontSize(chatframe, chatframe, .01)
			frame:Show()

			local lineCt = module.GetChatLines(chatframe)
			local text = tconcat(lines, " \n", 1, lineCt)
			FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
			editBox:SetText(text)
		else
			frame:Hide()
		end
	elseif btn == "RightButton" then
		ToggleFrame(menu)
		NDuiDB["Chat"]["ChatMenu"] = menu:IsShown()
	end
end

function module:ChatCopy_CreateMenu()
	menu = CreateFrame("Frame", nil, UIParent)
	menu:SetSize(25, 100)
	menu:SetPoint("TOPRIGHT", _G.ChatFrame1, 22, 0)
	menu:SetShown(NDuiDB["Chat"]["ChatMenu"])

	_G.ChatFrameMenuButton:ClearAllPoints()
	_G.ChatFrameMenuButton:SetPoint("TOP", menu)
	_G.ChatFrameMenuButton:SetParent(menu)
	_G.ChatFrameChannelButton:ClearAllPoints()
	_G.ChatFrameChannelButton:SetPoint("TOP", _G.ChatFrameMenuButton, "BOTTOM", 0, -2)
	_G.ChatFrameChannelButton:SetParent(menu)
	_G.ChatAlertFrame:ClearAllPoints()
	_G.ChatAlertFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1Tab, "TOPLEFT", 5, 25)
end

function module:ChatCopy_Create()
	frame = CreateFrame("Frame", "NDuiChatCopy", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	B.CreateMF(frame)
	B.SetBackground(frame)
	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)

	local scrollArea = CreateFrame("ScrollFrame", "ChatCopyScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 10)

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFont(DB.Font[1], 12)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end
		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for i = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)

	local copy = CreateFrame("Button", nil, UIParent)
	copy:SetPoint("BOTTOMRIGHT", _G.ChatFrame1, 22, 0)
	copy:SetSize(20, 20)
	copy:SetAlpha(.5)
	copy.Icon = copy:CreateTexture(nil, "ARTWORK")
	copy.Icon:SetAllPoints()
	copy.Icon:SetTexture(DB.copyTex)
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", self.ChatCopy_OnClick)
	B.AddTooltip(copy, "ANCHOR_RIGHT", L["Chat Copy"])
	copy:HookScript("OnEnter", function() copy:SetAlpha(1) end)
	copy:HookScript("OnLeave", function() copy:SetAlpha(.5) end)

	-- Aurora Reskin
	if F then
		F.ReskinClose(frame.close)
		F.ReskinScroll(ChatCopyScrollFrameScrollBar)
	end
end

function module:ChatCopy()
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end