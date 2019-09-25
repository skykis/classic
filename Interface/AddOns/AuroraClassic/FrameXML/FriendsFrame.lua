local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	for i = 1, 5 do
		local tab = _G["FriendsFrameTab"..i]
		tab.bg = F.ReskinTab(tab)
		local hl = _G["FriendsFrameTab"..i.."HighlightTexture"]
		hl:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
		if i == 1 then
			tab:SetPoint("BOTTOMLEFT", -2, -31)
		end
	end
	FriendsFrameIcon:Hide()
	F.StripTextures(FriendsFrameFriendsScrollFrame)
	F.StripTextures(IgnoreListFrame)

	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
		local ic = bu.gameIcon

		bu.background:Hide()
		bu:SetHighlightTexture(C.media.backdrop)
		bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)
		ic:SetSize(22, 22)
		ic:SetTexCoord(.17, .83, .17, .83)

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetAllPoints(ic)
		F.CreateBDFrame(bu.bg, 0)

		local travelPass = bu.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:SetPushedTexture(nil)
		travelPass:SetDisabledTexture(nil)
		travelPass:SetPoint("TOPRIGHT", -3, -6)
		F.CreateBDFrame(travelPass, 1)
		local nt = travelPass:GetNormalTexture()
		nt:SetTexture("Interface\\FriendsFrame\\PlusManz-PlusManz")
		nt:SetTexCoord(.1, .9, .1, .9)
		local hl = travelPass:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

			if bu.gameIcon:IsShown() then
				bu.bg:Show()
				bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -4, 0)
			else
				bu.bg:Hide()
			end
		end
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

	local header = FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton
	for i = 1, 11 do
		select(i, header:GetRegions()):Hide()
	end
	local headerBg = F.CreateBDFrame(header, .25)
	headerBg:SetPoint("TOPLEFT", 2, -2)
	headerBg:SetPoint("BOTTOMRIGHT", -2, 2)

	local function reskinInvites(self)
		for invite in self:EnumerateActive() do
			if not invite.styled then
				F.Reskin(invite.AcceptButton)
				F.Reskin(invite.DeclineButton)

				invite.styled = true
			end
		end
	end

	hooksecurefunc(FriendsFrameFriendsScrollFrame.invitePool, "Acquire", reskinInvites)
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.buttonType == FRIENDS_BUTTON_TYPE_INVITE then
			reskinInvites(FriendsFrameFriendsScrollFrame.invitePool)
		elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local nt = button.travelPassButton:GetNormalTexture()
			if FriendsFrame_GetInviteRestriction(button.id) == 8 then
				nt:SetVertexColor(1, 1, 1)
			else
				nt:SetVertexColor(.3, .3, .3)
			end
		end
	end)

	FriendsFrameStatusDropDown:ClearAllPoints()
	FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -28)

	for _, button in pairs({FriendsTabHeaderSoRButton, FriendsTabHeaderRecruitAFriendButton}) do
		button:SetPushedTexture("")
		button:GetRegions():SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(button)
	end

	F.CreateBD(FriendsFrameBattlenetFrame.UnavailableInfoFrame)
	FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	F.CreateBD(FriendsFrameBattlenetFrame, .25)

	FriendsFrameBattlenetFrame.Tag:SetParent(FriendsListFrame)
	FriendsFrameBattlenetFrame.Tag:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

	hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
		if BNFeaturesEnabled() then
			local frame = FriendsFrameBattlenetFrame
			frame.BroadcastButton:Hide()

			if BNConnected() then
				frame:Hide()
				FriendsFrameBroadcastInput:Show()
				FriendsFrameBroadcastInput_UpdateDisplay()
			end
		end
	end)

	hooksecurefunc("FriendsFrame_Update", function()
		if FriendsFrame.selectedTab == 1 and FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
			FriendsFrameTitleText:Hide()
		else
			FriendsFrameTitleText:Show()
		end
	end)

	local whoBg = F.CreateBDFrame(WhoFrameEditBox, .25)
	whoBg:SetPoint("TOPLEFT", WhoFrameEditBoxInset)
	whoBg:SetPoint("BOTTOMRIGHT", WhoFrameEditBoxInset, -1, 1)
	F.CreateGradient(whoBg)

	F.ReskinPortraitFrame(FriendsFrame)
	F.Reskin(FriendsFrameAddFriendButton)
	F.Reskin(FriendsFrameSendMessageButton)
	F.Reskin(FriendsFrameIgnorePlayerButton)
	F.Reskin(FriendsFrameUnsquelchButton)
	F.ReskinScroll(FriendsFrameFriendsScrollFrameScrollBar)
	F.ReskinScroll(FriendsFrameIgnoreScrollFrameScrollBar)
	F.ReskinScroll(FriendsFriendsScrollFrameScrollBar)
	F.ReskinScroll(WhoListScrollFrameScrollBar)
	F.ReskinDropDown(FriendsFrameStatusDropDown)
	F.ReskinDropDown(WhoFrameDropDown)
	F.ReskinDropDown(FriendsFriendsFrameDropDown)
	F.Reskin(FriendsListFrameContinueButton)
	F.CreateBD(FriendsFriendsList, .25)
	F.StripTextures(AddFriendNoteFrame)
	F.CreateBD(AddFriendNoteFrame, .25)
	F.ReskinInput(AddFriendNameEditBox)
	F.ReskinInput(FriendsFrameBroadcastInput)
	F.StripTextures(AddFriendFrame)
	F.CreateBD(AddFriendFrame)
	F.CreateSD(AddFriendFrame)
	F.CreateBD(FriendsFriendsFrame)
	F.CreateSD(FriendsFriendsFrame)
	F.Reskin(WhoFrameWhoButton)
	F.Reskin(WhoFrameAddFriendButton)
	F.Reskin(WhoFrameGroupInviteButton)
	F.Reskin(AddFriendEntryFrameAcceptButton)
	F.Reskin(AddFriendEntryFrameCancelButton)
	F.Reskin(FriendsFriendsSendRequestButton)
	F.Reskin(FriendsFriendsCloseButton)
	F.Reskin(AddFriendInfoFrameContinueButton)

	for i = 1, 4 do
		F.StripTextures(_G["WhoFrameColumnHeader"..i])
	end

	WhoFrameListInset:Hide()
	WhoFrameEditBoxInset:Hide()

	for i = 1, 2 do
		F.StripTextures(_G["FriendsTabHeaderTab"..i])
	end

	WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
	WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)
	FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

	-- GuildFrame

	F.StripTextures(GuildFrame)
	F.ReskinArrow(GuildFrameGuildListToggleButton, "right")
	F.Reskin(GuildFrameGuildInformationButton)
	F.Reskin(GuildFrameAddMemberButton)
	F.Reskin(GuildFrameControlButton)
	F.StripTextures(GuildFrameLFGFrame)
	F.ReskinCheck(GuildFrameLFGButton)
	F.ReskinScroll(GuildListScrollFrameScrollBar)
	for i = 1, 4 do
		local bg = F.ReskinTab(_G["GuildFrameColumnHeader"..i])
		bg:SetPoint("TOPLEFT", 5, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 0)
		local bg = F.ReskinTab(_G["GuildFrameGuildStatusColumnHeader"..i])
		bg:SetPoint("TOPLEFT", 5, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 0)
	end

	F.StripTextures(GuildMemberDetailFrame)
	F.SetBD(GuildMemberDetailFrame)
	F.ReskinClose(GuildMemberDetailCloseButton)
	F.CreateBD(GuildMemberNoteBackground, .25)
	F.CreateBD(GuildMemberOfficerNoteBackground, .25)
	F.ReskinArrow(GuildFramePromoteButton, "up")
	F.ReskinArrow(GuildFrameDemoteButton, "down")
	GuildFrameDemoteButton:SetPoint("LEFT", GuildFramePromoteButton, "RIGHT", 4, 0)
	F.Reskin(GuildMemberRemoveButton)
	F.Reskin(GuildMemberGroupInviteButton)

	F.StripTextures(GuildInfoFrame)
	F.SetBD(GuildInfoFrame)
	F.ReskinScroll(GuildInfoFrameScrollFrameScrollBar)
	F.ReskinClose(GuildInfoCloseButton)
	F.StripTextures(GuildInfoTextBackground)
	F.CreateBDFrame(GuildInfoTextBackground, .25)
	F.Reskin(GuildInfoSaveButton)
	F.Reskin(GuildInfoCancelButton)

	F.StripTextures(GuildControlPopupFrame)
	F.SetBD(GuildControlPopupFrame)
	F.ReskinDropDown(GuildControlPopupFrameDropDown)
	F.ReskinArrow(GuildControlPopupFrameAddRankButton, "right")
	F.StripTextures(GuildControlPopupFrameEditBox)
	local bg = F.CreateBDFrame(GuildControlPopupFrameEditBox, .0)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	F.CreateGradient(bg)
	F.Reskin(GuildControlPopupAcceptButton)
	F.Reskin(GuildControlPopupFrameCancelButton)
	for i = 1, 13 do
		F.ReskinCheck(_G["GuildControlPopupFrameCheckbox"..i])
		_G["GuildFrameButton"..i.."Level"]:SetWidth(30)
	end
end)