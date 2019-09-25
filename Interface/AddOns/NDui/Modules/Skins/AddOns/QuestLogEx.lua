local _, ns = ...
local B, C, L, DB, F, T = unpack(ns)
local S = B:GetModule("Skins")

local gsub, next = gsub, next
local IsModifiedClick, ChatEdit_GetActiveWindow, ChatEdit_InsertLink = IsModifiedClick, ChatEdit_GetActiveWindow, ChatEdit_InsertLink

function S:MoveCodexButtons(frame)
	if not CodexQuest then return end

	local buttonShow = CodexQuest.buttonShow
	buttonShow:SetParent(frame)
	buttonShow:ClearAllPoints()
	buttonShow:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 5, 10)
	buttonShow:SetWidth(55)
	buttonShow:SetText(SHOW)

	local buttonHide = CodexQuest.buttonHide
	buttonHide:SetParent(frame)
	buttonHide:ClearAllPoints()
	buttonHide:SetPoint("LEFT", buttonShow, "RIGHT", 5, 0)
	buttonHide:SetWidth(55)
	buttonHide:SetText(HIDE)

	local buttonReset = CodexQuest.buttonReset
	buttonReset:SetParent(frame)
	buttonReset:ClearAllPoints()
	buttonReset:SetPoint("LEFT", buttonHide, "RIGHT", 5, 0)
	buttonReset:SetWidth(55)
	buttonReset:SetText(RESET)
end

function S:ReskinQuestTemplate(frame)
	F.ReskinPortraitFrame(frame)
	F.StripTextures(frame.count)
	F.CreateBDFrame(frame.count, .25)
	F.StripTextures(frame.emptyLog)
	F.StripTextures(frame.scrollFrame.expandAll)
	F.ReskinExpandOrCollapse(frame.scrollFrame.expandAll)

	local mapButton = frame.mapButton
	mapButton:SetSize(34, 22)
	F.CreateBDFrame(mapButton)
	mapButton:GetNormalTexture():SetTexCoord(.25, .73, .1, .4)
	mapButton:GetPushedTexture():SetTexCoord(.25, .73, .6, .9)
	local hl = mapButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetAllPoints()

	hooksecurefunc("QuestLog_Update", function()
		for _, bu in next, frame.scrollFrame.buttons do
			if bu:IsShown() and not bu.styled then
				F.ReskinExpandOrCollapse(bu)
				bu.styled = true
			end
		end
	end)

	F.ReskinScroll(frame.scrollFrame.scrollBar)
	F.ReskinScroll(frame.detail.ScrollBar)
	local names = {"abandon", "push", "track", "close", "options"}
	for _, name in next, names do
		local bu = frame[name]
		if bu then F.Reskin(bu) end
	end

	-- Move ClassicCodex
	S:MoveCodexButtons(frame.detail)
end

function S:ReskinClassicQuestLog()
	if not IsAddOnLoaded("Classic Quest Log") then return end

	S:ReskinQuestTemplate(ClassicQuestLog)
	ClassicQuestLog.scrollFrame.BG:SetAlpha(0)
	ClassicQuestLog.detail.DetailBG:SetAlpha(0)

	local optionsFrame = ClassicQuestLog.optionsFrame
	F.StripTextures(optionsFrame)
	F.ReskinClose(optionsFrame.CloseButton)
	F.CreateSD(F.CreateBDFrame(optionsFrame))
	optionsFrame:ClearAllPoints()
	optionsFrame:SetPoint("TOPLEFT", ClassicQuestLog, "TOPRIGHT", 5, 0)

	local names = {"UndockWindow", "LockWindow", "ShowResizeGrip", "ShowLevels", "ShowTooltips", "SolidBackground"}
	for _, name in next, names do
		local bu = optionsFrame[name]
		if bu then F.ReskinCheck(bu) end
	end

	-- Copy header to Chatframe
	function ClassicQuestLog:ListEntryOnClick()
		local index = self.index
		if self.index == 0 then
			return -- this is a fake header/war campaign; don't do anything
		elseif self.isHeader then
			ClassicQuestLogCollapsedHeaders[self.questTitle] = not ClassicQuestLogCollapsedHeaders[self.questTitle] or nil
		else
			if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
				ChatEdit_InsertLink(gsub(self:GetText(), " *(.*)", "%1")) -- Interface\FrameXML\QuestLogFrame:480
			elseif IsModifiedClick("QUESTWATCHTOGGLE") then
				ClassicQuestLog:ToggleWatch(index)
			else
				ClassicQuestLog:SelectQuestIndex(index)
			end
		end
		ClassicQuestLog:UpdateLogList()
	end
end

function S:ReskinQuestGuru()
	if not IsAddOnLoaded("QuestGuru") then return end

	S:ReskinQuestTemplate(QuestGuru)

	-- Temp fix
	if not QuestMapFrame_ShowQuestDetails then
		QuestMapFrame_ShowQuestDetails = F.dummy
	end
	-- https://bbs.nga.cn/read.php?tid=18321155&pid=362320732
end

function S:ReskinQuestLogEx()
	if not IsAddOnLoaded("QuestLogEx") then return end

	B.CreateMF(QuestLogExFrame)
	local BG = F.ReskinPortraitFrame(QuestLogExFrame, 10, -5, -30, 0)
	hooksecurefunc(QuestLogEx, "ToggleExtended", function()
		if QuestLogExFrameDescription:IsVisible() then
			BG:SetPoint("BOTTOMRIGHT", QuestLogExFrameDescription, -25, 0)
		else
			BG:SetPoint("BOTTOMRIGHT", QuestLogExFrame, -30, 0)
		end
	end)

	F.StripTextures(EmptyQuestLogExFrame)
	F.StripTextures(QuestLogExFrameDescription)
	F.ReskinClose(QuestLogExDetailCloseButton, "TOPRIGHT", QuestLogExFrameDescription, -30, -10)
	F.ReskinArrow(QuestLogExFrameMaximizeButton, "right")
	QuestLogExFrameMaximizeButton:ClearAllPoints()
	QuestLogExFrameMaximizeButton:SetPoint("RIGHT", QuestLogExFrameCloseButton, "LEFT", -2, 0)
	F.ReskinArrow(QuestLogExDetailMinimizeButton, "left")
	QuestLogExDetailMinimizeButton:ClearAllPoints()
	QuestLogExDetailMinimizeButton:SetPoint("RIGHT", QuestLogExDetailCloseButton, "LEFT", -2, 0)

	F.ReskinScroll(QuestLogExListScrollFrameScrollBar)
	F.ReskinScroll(QuestLogExDetailScrollFrameScrollBar)
	F.Reskin(QuestLogExFrameAbandonButton)
	F.Reskin(QuestLogExFramePushQuestButton)
	F.Reskin(QuestLogExFrameExitButton)
	F.Reskin(QuestLogExDetailExitButton)
	F.ReskinExpandOrCollapse(QuestLogExCollapseAllButton)
	QuestLogExCollapseAllButton:DisableDrawLayer("BACKGROUND")
	for i = 1, 27 do
		local title = _G["QuestLogExTitle"..i]
		F.ReskinExpandOrCollapse(title)
	end

	for i = 1, 10 do
		local icon = _G["QuestLogExItem"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(icon)
		local nameFrame = _G["QuestLogExItem"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = F.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end

	-- Text
	QuestLogExQuestTitle:SetTextColor(1, .8, 0)
	QuestLogExDescriptionTitle:SetTextColor(1, .8, 0)
	for i = 1, 10 do
		local text = _G["QuestLogExObjective"..i]
		text:SetTextColor(1, 1, 1)
		text.SetTextColor = F.dummy
	end
	QuestLogExRewardTitleText:SetTextColor(1, .8, 0)
	QuestLogExRewardTitleText.SetTextColor = F.dummy
	QuestLogExItemChooseText:SetTextColor(1, 1, 1)
	QuestLogExItemChooseText.SetTextColor = F.dummy
	QuestLogExItemReceiveText:SetTextColor(1, 1, 1)
	QuestLogExItemReceiveText.SetTextColor = F.dummy

	-- Move ClassicCodex
	S:MoveCodexButtons(QuestLogExDetailScrollFrame)
end

function S:ExtraQuestSkin()
	if not NDuiDB["Skins"]["QuestLogEx"] then return end
	if not F then return end

	S:ReskinClassicQuestLog()
	S:ReskinQuestGuru()
	S:ReskinQuestLogEx()
end