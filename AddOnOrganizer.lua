--## BY: Arina, 60 Warrior on Deathwing EU English.
--## Use With Caution! ;)

local _G = _G or getfenv(0)
local addonsDisplayed = 22
local addonsLineHeight = 16
local version = GetAddOnMetadata("AddOnOrganizer", "Version")
local selectedProfileIndex
local AddOnList = {}

local GREEN = "|cff00FF00"
local RED = "|cffFF0000"
local WHITE = "|cffFFFFFF"

CS_AddOnOrganizer_Profiles = {}

BINDING_HEADER_CS_ADDONORGANIZER_SEP = "AddOnOrganizer"
BINDING_NAME_CS_ADDONORGANIZER_CONFIG = "Show / Hide"

SLASH_CS_ADDONORGANIZER1 = "/aoo"
SlashCmdList["CS_ADDONORGANIZER"] = function(msg)
    CS_AddOnOrganizer_ListShowHide()
end

function CS_AddOnOrganizer_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    tinsert(UISpecialFrames, self:GetName())
end

function CS_AddOnOrganizer_OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "AddOnOrganizer" then
            DEFAULT_CHAT_FRAME:AddMessage("AddOnOrganizer "..version.." loaded.")
            CS_AddOnOrganizer_List_Title:SetText("AddOnOrganizer v."..version)
            UIDropDownMenu_SetWidth(110, CS_AddOnOrganizer_List_ProfilesDropDown)
            UIDropDownMenu_Initialize(CS_AddOnOrganizer_List_ProfilesDropDown, CS_AddOnOrganizer_InitializeDropDown)
            self:UnregisterEvent(event)
        end
    end
end

function CS_AddOnOrganizer_SaveProfile(profileName)
    if not profileName and selectedProfileIndex then
        profileName = CS_AddOnOrganizer_Profiles[selectedProfileIndex][1]
    end

    if profileName == "" then return end

    local found = false
    local newKey = table.getn(CS_AddOnOrganizer_Profiles) + 1

    for i = 1, table.getn(CS_AddOnOrganizer_Profiles) do
        if (CS_AddOnOrganizer_Profiles[i][1] == profileName) then
            newKey = i
            found = true
        end
    end

    if (not found) then
        tinsert(CS_AddOnOrganizer_Profiles, { profileName })
        DEFAULT_CHAT_FRAME:AddMessage(profileName.." profile has been added.")
        selectedProfileIndex = table.getn(CS_AddOnOrganizer_Profiles)
    else
        DEFAULT_CHAT_FRAME:AddMessage(profileName.." profile has been updated.")
    end

    local j = 2
    for i = 1, GetNumAddOns() do
        if (AddOnList[i] == 1) then
            CS_AddOnOrganizer_Profiles[newKey][j] = GetAddOnInfo(i)
            j = j + 1
        end
    end
    CS_AddOnOrganizer_List_Update()
end

function CS_AddOnOrganizer_DeleteProfile()
    if selectedProfileIndex then
        DEFAULT_CHAT_FRAME:AddMessage(CS_AddOnOrganizer_Profiles[selectedProfileIndex][1].." profile has been deleted.")
        table.remove(CS_AddOnOrganizer_Profiles, selectedProfileIndex)
        UIDropDownMenu_SetText("", CS_AddOnOrganizer_List_ProfilesDropDown)
        selectedProfileIndex = nil
    end
    CS_AddOnOrganizer_List_Update()
end

function CS_AddOnOrganizer_LoadProfile(id)
    selectedProfileIndex = id
    CS_AddOnOrganizer_DisableAll()
    for j = 2, table.getn(CS_AddOnOrganizer_Profiles[id]) do
        local loadname = CS_AddOnOrganizer_Profiles[id][j]
        for i = 1, GetNumAddOns() do
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
            if (name == loadname) then
                AddOnList[i] = 1
            end
        end
    end
    CS_AddOnOrganizer_List_Update()
end

function CS_AddOnOrganizer_ListShowHide()
    if CS_AddOnOrganizer_List:IsShown() then
        HideUIPanel(CS_AddOnOrganizer_List)
    else
        ShowUIPanel(CS_AddOnOrganizer_List)
        for i = 1, GetNumAddOns() do
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
            AddOnList[i] = enabled
        end
        selectedProfileIndex = nil
        CS_AddOnOrganizer_List_Update()
    end
end

function CS_AddOnOrganizerList_OnVerticalScroll()
    FauxScrollFrame_OnVerticalScroll(addonsLineHeight, CS_AddOnOrganizer_List_Update);
end

function CS_AddOnOrganizer_List_Update()
    local numaddons = GetNumAddOns()
    -- CS_AddOnOrganizer_List_AddOnCount:SetText("AddOns: "..WHITE..numaddons.."|r")
    -- CS_AddOnOrganizer_List_CountMiddle:SetWidth(CS_AddOnOrganizer_List_AddOnCount:GetWidth())

    local scrollBar = FauxScrollFrame_Update(CS_AddOnOrganizer_List_Scroll, numaddons, addonsDisplayed, addonsLineHeight, nil, nil, nil, nil, 293, 316)

    for i = 1, addonsDisplayed do
        local addonIndex = i + (FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll) or 0)

        if (addonIndex <= numaddons) then
            local addonLogTitle = _G["CS_AddOnOrganizer_List_Title"..i]
            local addonTitleTag = _G["CS_AddOnOrganizer_List_Title"..i.."Tag"]
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)

            addonLogTitle:SetText(title)

            if (AddOnList[addonIndex] == 1) then
                addonTitleTag:SetText("Enabled")
                addonTitleTag:SetTextColor(0, 1.0, 0)
            else
                addonTitleTag:SetText("Disabled")
                addonTitleTag:SetTextColor(1, 0.7, 0)
            end

            if scrollBar then
                addonLogTitle:SetWidth(300)
            else
                addonLogTitle:SetWidth(320)
            end

            addonLogTitle:Show()

            local tagText = addonTitleTag:GetText()
            if tagText == "Enabled" and not (enabled and not loadable) then
                addonLogTitle:SetTextColor(1, 1, 0.5)
            else
                addonLogTitle:SetTextColor(0.7, 0.7, 0.7)
            end
        end
    end
    if selectedProfileIndex then
        UIDropDownMenu_SetText(CS_AddOnOrganizer_Profiles[selectedProfileIndex][1], CS_AddOnOrganizer_List_ProfilesDropDown)
        CS_AddOnOrganizer_List_SaveProfile:Enable()
        CS_AddOnOrganizer_List_DeleteProfile:Enable()
    else
        UIDropDownMenu_SetText("Select Profile", CS_AddOnOrganizer_List_ProfilesDropDown)
        CS_AddOnOrganizer_List_SaveProfile:Disable()
        CS_AddOnOrganizer_List_DeleteProfile:Disable()
    end
end

function CS_AddOnOrganizer_TitleButton_OnClick(self)
    local buttonID = self:GetID()
    local addonIndex = buttonID + FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll)
    local addonTitleTag = _G["CS_AddOnOrganizer_List_Title"..buttonID.."Tag"]
    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)

    if (AddOnList[addonIndex] == 1) then
        addonTitleTag:SetText("Disabled")
        addonTitleTag:SetTextColor(1, 0.7, 0)
        self:SetTextColor(0.7, 0.7, 0.7)
        AddOnList[addonIndex] = 0
    else
        addonTitleTag:SetText("Enabled")
        addonTitleTag:SetTextColor(0, 1.0, 0)
        if (enabled and not loadable) then
            self:SetTextColor(0.7, 0.7, 0.7)
        else
            self:SetTextColor(1, 1, 0.5)
        end
        AddOnList[addonIndex] = 1
    end
end

function CS_AddOnOrganizer_TitleButton_OnEnter(self)
    local addonIndex = self:GetID() + FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll)
    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
    local dependencies = GetAddOnDependencies(addonIndex) and WHITE..GetAddOnDependencies(addonIndex) or WHITE.."No Dependencies"
    local loadondemand = IsAddOnLoadOnDemand(addonIndex) and GREEN.."True|r" or RED.."False|r"
    title = title or "No Title"
    notes = notes or "No Notes"

    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    if (loadable) then
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: "..GREEN.."True")
        GameTooltip:AddLine("LoadOnDemand: "..loadondemand)
        GameTooltip:AddLine("Dependencies: "..dependencies)
    elseif (reason == "DISABLED") then
        reason = _G["ADDON_"..reason]
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: "..RED.."False")
        GameTooltip:AddLine("Reason: "..RED..reason)
        GameTooltip:AddLine("You might still enable this addon.")
        GameTooltip:AddLine("LoadOnDemand: "..loadondemand)
        GameTooltip:AddLine("Dependencies: "..dependencies)
    else
        reason = _G["ADDON_"..reason]
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: "..RED.."False")
        GameTooltip:AddLine("Reason: "..RED..reason)
        GameTooltip:AddLine("LoadOnDemand: "..loadondemand)
        GameTooltip:AddLine("Dependencies: "..dependencies)
    end
    GameTooltip:Show()
    self:SetBackdropColor(1, 1, 1, 0.4)
end

function CS_AddOnOrganizer_TitleButton_OnLeave(self)
    self:SetBackdropColor(1, 1, 1, 0.1)
    GameTooltip:Hide()
end

function CS_AddOnOrganizer_AcceptButton_OnClick()
    local isChanges = false
    for i = 1, GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
        if (AddOnList[i] ~= enabled) then
            if (AddOnList[i] == 1) then
                EnableAddOn(i)
            else
                DisableAddOn(i)
            end
            isChanges = true
        end
    end
    CS_AddOnOrganizer_ListShowHide()
    if (isChanges) then
        ReloadUI()
    end
end

function CS_AddOnOrganizer_ReloadUIButton()
    ReloadUI()
end

function CS_AddOnOrganizer_EnableAll()
    for i = 1, GetNumAddOns() do
        AddOnList[i] = 1
        if (i <= addonsDisplayed) then
            local addonTitleTag = _G["CS_AddOnOrganizer_List_Title"..i.."Tag"]
            local addonTitle = _G["CS_AddOnOrganizer_List_Title"..i]
            addonTitleTag:SetText("Enabled")
            addonTitleTag:SetTextColor(0, 1, 0)
            addonTitle:SetTextColor(1, 1, 0.5)
        end
    end
end

function CS_AddOnOrganizer_DisableAll()
    for i = 1, GetNumAddOns() do
        AddOnList[i] = 0
        if (i <= addonsDisplayed) then
            local addonTitleTag = _G["CS_AddOnOrganizer_List_Title"..i.."Tag"]
            local addonTitle = _G["CS_AddOnOrganizer_List_Title"..i]
            addonTitleTag:SetText("Disabled")
            addonTitleTag:SetTextColor(1, 0.7, 0)
            addonTitle:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

local info = {}
function CS_AddOnOrganizer_InitializeDropDown()
    local numProfiles = table.getn(CS_AddOnOrganizer_Profiles)
    if numProfiles < UIDROPDOWNMENU_MAXBUTTONS then
        info.text = GREEN.."+ New Profile|r"
        -- info.notCheckable = true
        info.func = StaticPopup_Show
        info.arg1 = "ADDON_ORGANIZER_NEW_PROFILE"
        info.checked = nil
        UIDropDownMenu_AddButton(info)
    end
    for i = 1, numProfiles do
        info.text = CS_AddOnOrganizer_Profiles[i][1]
        info.func = CS_AddOnOrganizer_LoadProfile
        -- info.notCheckable = nil
        info.arg1 = i
        info.checked = selectedProfileIndex and i == selectedProfileIndex
        UIDropDownMenu_AddButton(info)
    end
end

StaticPopupDialogs["ADDON_ORGANIZER_NEW_PROFILE"] = {
	text = "Enter profile name:",
	button1 = OKAY,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function()
        CS_AddOnOrganizer_SaveProfile(_G[this:GetParent():GetName().."EditBox"]:GetText())
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus()
	end,
	OnHide = function()
		_G[this:GetName().."EditBox"]:SetText("")
	end,
	EditBoxOnEnterPressed = function()
		CS_AddOnOrganizer_SaveProfile(this:GetText())
		this:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide()
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}
