local F, C = unpack(select(2, ...))

C.themes["Blizzard_Communities"] = function()
	local r, g, b = C.r, C.g, C.b
	local CommunitiesFrame = CommunitiesFrame

	F.ReskinPortraitFrame(CommunitiesFrame)
	CommunitiesFrame.PortraitOverlay:SetAlpha(0)
	F.ReskinDropDown(CommunitiesFrame.StreamDropDownMenu)
	F.StripTextures(CommunitiesFrame.MaximizeMinimizeFrame)
	F.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
	F.ReskinArrow(CommunitiesFrame.AddToChatButton, "down")
	F.ReskinDropDown(CommunitiesFrame.CommunitiesListDropDownMenu)

	for i = 1, 5 do
		F.ReskinTab(_G["CommunitiesFrameTab"..i])
	end

	for _, name in next, {"InvitationFrame", "TicketFrame"} do
		local frame = CommunitiesFrame[name]
		F.StripTextures(frame)
		F.CreateBD(frame, .25)
		frame.InsetFrame:Hide()
		if frame.CircleMask then
			frame.CircleMask:Hide()
			F.ReskinIcon(frame.Icon)
		end
		if frame.FindAGuildButton then F.Reskin(frame.FindAGuildButton) end
		if frame.AcceptButton then F.Reskin(frame.AcceptButton) end
		if frame.DeclineButton then F.Reskin(frame.DeclineButton) end

		local optionsList = frame.OptionsList
		if optionsList then
			F.ReskinDropDown(optionsList.ClubFocusDropdown)
			optionsList.ClubFocusDropdown.GuildFocusDropdownLabel:SetWidth(150)
			F.ReskinDropDown(optionsList.ClubSizeDropdown)
			F.ReskinRole(optionsList.TankRoleFrame, "TANK")
			F.ReskinRole(optionsList.HealerRoleFrame, "HEALER")
			F.ReskinRole(optionsList.DpsRoleFrame, "DPS")
			F.ReskinInput(optionsList.SearchBox)
			optionsList.SearchBox:SetSize(118, 22)
			F.Reskin(optionsList.Search)
			optionsList.Search:ClearAllPoints()
			optionsList.Search:SetPoint("TOPRIGHT", optionsList.SearchBox, "BOTTOMRIGHT", 0, -2)
			F.Reskin(frame.PendingClubs)
		end
	end

	F.StripTextures(CommunitiesFrameCommunitiesList)
	CommunitiesFrameCommunitiesList.InsetFrame:Hide()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	F.ReskinScroll(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar.Background:Hide()

	hooksecurefunc(CommunitiesFrameCommunitiesList, "Update", function(self)
		local buttons = self.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				button:GetRegions():Hide()
				button.Selection:SetAlpha(0)
				button:SetHighlightTexture("")
				button.bg = F.CreateBDFrame(button, 0)
				button.bg:SetPoint("TOPLEFT", 5, -5)
				button.bg:SetPoint("BOTTOMRIGHT", -10, 5)
				F.CreateGradient(button.bg)
			end

			if button.Selection:IsShown() then
				button.bg:SetBackdropColor(r, g, b, .25)
			else
				button.bg:SetBackdropColor(0, 0, 0, 0)
			end
		end
	end)

	for _, name in next, {"ChatTab", "RosterTab"} do
		local tab = CommunitiesFrame[name]
		tab:GetRegions():Hide()
		F.ReskinIcon(tab.Icon)
		tab:SetCheckedTexture(C.media.checked)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(tab.Icon)
	end

	-- ChatTab
	F.Reskin(CommunitiesFrame.InviteButton)
	F.StripTextures(CommunitiesFrame.Chat)
	F.ReskinScroll(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	CommunitiesFrame.ChatEditBox:DisableDrawLayer("BACKGROUND")
	local bg1 = F.CreateBDFrame(CommunitiesFrame.Chat.InsetFrame, .25)
	bg1:SetPoint("TOPLEFT", 1, -3)
	bg1:SetPoint("BOTTOMRIGHT", -3, 22)
	local bg2 = F.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0)
	F.CreateGradient(bg2)
	bg2:SetPoint("TOPLEFT", -5, -5)
	bg2:SetPoint("BOTTOMRIGHT", 4, 5)

	do
		local dialog = CommunitiesFrame.NotificationSettingsDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		F.ReskinDropDown(dialog.CommunitiesListDropDownMenu)
		F.Reskin(dialog.OkayButton)
		F.Reskin(dialog.CancelButton)
		F.ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
		dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
		F.Reskin(dialog.ScrollFrame.Child.AllButton)
		F.Reskin(dialog.ScrollFrame.Child.NoneButton)
		F.ReskinScroll(dialog.ScrollFrame.ScrollBar)

		hooksecurefunc(dialog, "Refresh", function(self)
			local frame = self.ScrollFrame.Child
			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child.StreamName and not child.styled then
					F.ReskinRadio(child.ShowNotificationsButton)
					F.ReskinRadio(child.HideNotificationsButton)

					child.styled = true
				end
			end
		end)
	end

	do
		local dialog = CommunitiesFrame.EditStreamDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		dialog.NameEdit:DisableDrawLayer("BACKGROUND")
		local bg = F.CreateBDFrame(dialog.NameEdit, .25)
		bg:SetPoint("TOPLEFT", -3, -3)
		bg:SetPoint("BOTTOMRIGHT", -4, 3)
		F.StripTextures(dialog.Description)
		F.CreateBDFrame(dialog.Description, .25)
		F.ReskinCheck(dialog.TypeCheckBox)
		F.Reskin(dialog.Accept)
		F.Reskin(dialog.Delete)
		F.Reskin(dialog.Cancel)
	end

	do
		local dialog = CommunitiesTicketManagerDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		dialog.Background:Hide()
		F.Reskin(dialog.LinkToChat)
		F.Reskin(dialog.Copy)
		F.Reskin(dialog.Close)
		F.ReskinArrow(dialog.MaximizeButton, "down")
		F.ReskinDropDown(dialog.ExpiresDropDownMenu)
		F.ReskinDropDown(dialog.UsesDropDownMenu)
		F.Reskin(dialog.GenerateLinkButton)

		dialog.InviteManager.ArtOverlay:Hide()
		F.StripTextures(dialog.InviteManager.ColumnDisplay)
		dialog.InviteManager.ListScrollFrame.Background:Hide()
		F.ReskinScroll(dialog.InviteManager.ListScrollFrame.scrollBar)
		dialog.InviteManager.ListScrollFrame.scrollBar.Background:Hide()

		hooksecurefunc(dialog, "Update", function(self)
			local column = self.InviteManager.ColumnDisplay
			for i = 1, column:GetNumChildren() do
				local child = select(i, column:GetChildren())
				if not child.styled then
					F.StripTextures(child)
					F.CreateBDFrame(child, .25)

					child.styled = true
				end
			end

			local buttons = self.InviteManager.ListScrollFrame.buttons
			for i = 1, #buttons do
				local button = buttons[i]
				if not button.styled then
					F.Reskin(button.CopyLinkButton)
					button.CopyLinkButton.Background:Hide()
					F.Reskin(button.RevokeButton)
					button.RevokeButton:SetSize(18, 18)

					button.styled = true
				end
			end
		end)
	end

	-- Roster
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	F.CreateBDFrame(CommunitiesFrame.MemberList.ListScrollFrame, .25)
	F.StripTextures(CommunitiesFrame.MemberList.ColumnDisplay)
	--F.ReskinDropDown(CommunitiesFrame.GuildMemberListDropDownMenu)
	F.ReskinScroll(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:Hide()
	F.ReskinCheck(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
	--F.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	--F.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	F.Reskin(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)

	do
		local dialog = CommunitiesSettingsDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		F.Reskin(dialog.ChangeAvatarButton)
		F.Reskin(dialog.Accept)
		F.Reskin(dialog.Delete)
		F.Reskin(dialog.Cancel)
		F.ReskinInput(dialog.NameEdit)
		F.ReskinInput(dialog.ShortNameEdit)
		F.StripTextures(dialog.Description)
		F.CreateBDFrame(dialog.Description, .25)
		F.StripTextures(dialog.MessageOfTheDay)
		F.CreateBDFrame(dialog.MessageOfTheDay, .25)
	end

	do
		local dialog = CommunitiesAvatarPickerDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		select(9, dialog:GetRegions()):Hide()
		CommunitiesAvatarPickerDialogTop:Hide()
		CommunitiesAvatarPickerDialogMiddle:Hide()
		CommunitiesAvatarPickerDialogBottom:Hide()
		F.ReskinScroll(CommunitiesAvatarPickerDialogScrollBar)
		F.Reskin(dialog.OkayButton)
		F.Reskin(dialog.CancelButton)

		hooksecurefunc(CommunitiesAvatarPickerDialog.ScrollFrame, "Refresh", function(self)
			for i = 1, 5 do
				for j = 1, 6 do
					local avatarButton = self.avatarButtons[i][j]
					if avatarButton:IsShown() and not avatarButton.bg then
						avatarButton.bg = F.ReskinIcon(avatarButton.Icon)
						avatarButton.Selected:SetTexture("")
						avatarButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					end

					if avatarButton.Selected:IsShown() then
						avatarButton.bg:SetVertexColor(r, g, b)
					else
						avatarButton.bg:SetVertexColor(0, 0, 0)
					end
				end
			end
		end)
	end

	local function updateNameFrame(self)
		if not self.expanded then return end
		if not self.bg then
			self.bg = F.CreateBDFrame(self.Class)
		end
		local memberInfo = self:GetMemberInfo()
		if memberInfo and memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
			if classInfo then
				local tcoords = CLASS_ICON_TCOORDS[classInfo.classFile]
				self.Class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
			end
		end
	end

	hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
		for i = 1, self.ColumnDisplay:GetNumChildren() do
			local child = select(i, self.ColumnDisplay:GetChildren())
			if not child.styled then
				F.StripTextures(child)
				F.CreateBDFrame(child, .25)

				child.styled = true
			end
		end

		for _, button in ipairs(self.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, "RefreshExpandedColumns", updateNameFrame)
				if button.ProfessionHeader then
					local header = button.ProfessionHeader
					for i = 1, 3 do
						select(i, header:GetRegions()):Hide()
					end
					F.CreateBDFrame(header, .45)
					header:SetHighlightTexture(C.media.backdrop)
					header:GetHighlightTexture():SetVertexColor(r, g, b, .25)
					F.CreateBDFrame(header.Icon)
				end

				button.hooked = true
			end
			if button and button.bg then
				button.bg:SetShown(button.Class:IsShown())
			end
		end
	end)
end