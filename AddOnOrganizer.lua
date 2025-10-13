--## BY: Arina, 60 Warrior on Deathwing EU English.
--## Use With Caution! ;)

local addonsDisplayed = 22
local addonsLineHeight = 16
local version = GetAddOnMetadata("AddOnOrganizer", "Version")
local profileID
local AddOnList = {}

local GREEN = "|cff00FF00"
local RED = "|cffFF0000"
local WHITE = "|cffFFFFFF"

CS_AddOnOrganizer_Profiles = {}

BINDING_HEADER_CS_ADDONORGANIZER_SEP = "AddOnOrganizer"
BINDING_NAME_CS_ADDONORGANIZER_CONFIG = "Show / Hide"

function CS_AddOnOrganizer_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED")
    tinsert(UISpecialFrames, "CS_AddOnOrganizer_List")
    CS_AddOnOrganizer_List:SetFrameStrata("DIALOG")
    CS_AddOnOrganizer_List:SetClampedToScreen(true)
    CS_AddOnOrganizer_List_Profiles:SetFrameStrata("DIALOG")
    SLASH_CS_ADDONORGANIZER1 = "/aoo"
    SlashCmdList["CS_ADDONORGANIZER"] = function(msg)
        CS_AddOnOrganizer_ListShowHide()
    end
end

function CS_AddOnOrganizer_SaveProfile()
    local profileName = SaveProfileEditBox:GetText()
    local newKey
    local found = false

    if (profileName ~= "") then
        newKey = table.getn(CS_AddOnOrganizer_Profiles) + 1

        for i = 1, table.getn(CS_AddOnOrganizer_Profiles) do
            if (CS_AddOnOrganizer_Profiles[i][1] == profileName) then
                newKey = i
                found = true
            end
        end

        if (not found) then
            tinsert(CS_AddOnOrganizer_Profiles, { SaveProfileEditBox:GetText() })
            DEFAULT_CHAT_FRAME:AddMessage(GREEN .. "CS_AddOnOrganizer|r - " ..
                SaveProfileEditBox:GetText() .. " has been " .. GREEN .. "ADDED|r to profiles list!")
        else
            DEFAULT_CHAT_FRAME:AddMessage(GREEN .. "CS_AddOnOrganizer|r - " ..
                SaveProfileEditBox:GetText() .. " has been " .. GREEN .. "MODIFIED|r in the profiles list!")
        end

        local j = 2
        for i = 1, GetNumAddOns() do
            if (AddOnList[i] == 1) then
                CS_AddOnOrganizer_Profiles[newKey][j] = GetAddOnInfo(i)
                j = j + 1
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(GREEN .. "CS_AddOnOrganizer|r - " .. RED .. "You have to write a name for the profile!|r")
    end
end

function CS_AddOnOrganizer_DeleteProfile()
    if profileID then
        DEFAULT_CHAT_FRAME:AddMessage(GREEN .. "CS_AddOnOrganizer|r - " ..
            CS_AddOnOrganizer_Profiles[profileID][1] .. " has been " .. RED .. "DELETED|r from profiles list!")
        SaveProfileEditBox:SetText("")
        table.remove(CS_AddOnOrganizer_Profiles, profileID)
        UIDropDownMenu_SetText("", ProfilesDropDown)
        profileID = nil
    end
end

function CS_AddOnOrganizer_LoadProfile()
    UIDropDownMenu_SetSelectedID(ProfilesDropDown, this:GetID())
    CS_AddOnOrganizer_DisableAll()
    profileID = this:GetID()
    for j = 2, table.getn(CS_AddOnOrganizer_Profiles[this:GetID()]) do
        local loadname = CS_AddOnOrganizer_Profiles[this:GetID()][j]
        for i = 1, GetNumAddOns() do
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
            if (name == loadname) then
                AddOnList[i] = 1
            end
        end
    end
    CS_AddOnOrganizer_List_Update()
    SaveProfileEditBox:SetText(CS_AddOnOrganizer_Profiles[this:GetID()][1])
end

function CS_AddOnOrganizer_OnEvent()
    if (event == "VARIABLES_LOADED") then
        DEFAULT_CHAT_FRAME:AddMessage("AddOnOrganizer " .. GREEN .. "Loaded|r")
        CS_AddOnOrganizer_ProfilesDropDown_OnLoad()
    end
end

function CS_AddOnOrganizer_ListShowHide()
    if (CS_AddOnOrganizer_List:IsVisible()) then
        HideUIPanel(CS_AddOnOrganizer_List_Profiles)
        HideUIPanel(CS_AddOnOrganizer_List)
    else
        CS_AddOnOrganizer_List_Title:SetText("AddOnOrganizer v." .. version)
        ShowUIPanel(CS_AddOnOrganizer_List)
        CS_AddOnOrganizer_GetList()
        CS_AddOnOrganizer_List_Update()
    end
end

function CS_AddOnOrganizer_GetList()
    for i = 1, GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
        AddOnList[i] = enabled
    end
end

function CS_AddOnOrganizerList_OnVerticalScroll()
    FauxScrollFrame_OnVerticalScroll(addonsLineHeight, CS_AddOnOrganizer_List_Update);
end

function CS_AddOnOrganizer_List_Update()
    local numaddons = GetNumAddOns()
    CS_AddOnOrganizer_List_AddOnCount:SetText("AddOns: " .. WHITE .. numaddons .. "|r")
    CS_AddOnOrganizer_List_CountMiddle:SetWidth(CS_AddOnOrganizer_List_AddOnCount:GetWidth())

    FauxScrollFrame_Update(CS_AddOnOrganizer_List_Scroll, numaddons, addonsDisplayed, addonsLineHeight, nil, nil, nil,
        CS_AddOnOrganizer_List_HighlightFrame, 293, 316)

    local scrollBar = CS_AddOnOrganizer_List_ScrollScrollBar:IsVisible()

    for i = 1, addonsDisplayed do
        local addonIndex = i + (FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll) or 0)

        if (addonIndex <= numaddons) then
            local addonLogTitle = getglobal("CS_AddOnOrganizer_List_Title" .. i)
            local addonTitleTag = getglobal("CS_AddOnOrganizer_List_Title" .. i .. "Tag")
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)

            addonLogTitle:SetText(title)
            addonLogTitle:SetNormalTexture("")

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
end

function CS_AddOnOrganizer_TitleButton_OnClick()
    local addonIndex = this:GetID() + FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll)
    local buttonID = this:GetID()
    local addonTitleTag = getglobal("CS_AddOnOrganizer_List_Title" .. buttonID .. "Tag")
    local addonTitle = getglobal("CS_AddOnOrganizer_List_Title" .. buttonID)
    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)

    if (AddOnList[addonIndex] == 1) then
        addonTitleTag:SetText("Disabled")
        addonTitleTag:SetTextColor(1, 0.7, 0)
        addonTitle:SetTextColor(0.7, 0.7, 0.7)
        AddOnList[addonIndex] = 0
    else
        addonTitleTag:SetText("Enabled")
        addonTitleTag:SetTextColor(0, 1.0, 0)
        if (enabled and not loadable) then
            addonTitle:SetTextColor(0.7, 0.7, 0.7)
        else
            addonTitle:SetTextColor(1, 1, 0.5)
        end
        AddOnList[addonIndex] = 1
    end
end

function CS_AddOnOrganizer_TitleButton_OnEnter()
    local addonIndex = this:GetID() + FauxScrollFrame_GetOffset(CS_AddOnOrganizer_List_Scroll)
    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
    local dependencies = GetAddOnDependencies(addonIndex) and WHITE .. GetAddOnDependencies(addonIndex) or WHITE .. "No Dependencies"
    local loadondemand = IsAddOnLoadOnDemand(addonIndex) and GREEN .. "True|r" or RED .. "False|r"
    title = title or "No Title"
    notes = notes or "No Notes"

    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    if (loadable) then
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: " .. GREEN .. "True")
        GameTooltip:AddLine("LoadOnDemand: " .. loadondemand)
        GameTooltip:AddLine("Dependencies: " .. dependencies)
    elseif (reason == "DISABLED") then
        reason = getglobal("ADDON_"..reason)
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: " .. RED .. "False")
        GameTooltip:AddLine("Reason: " .. RED .. reason)
        GameTooltip:AddLine("You might still enable this addon.")
        GameTooltip:AddLine("LoadOnDemand: " .. loadondemand)
        GameTooltip:AddLine("Dependencies: " .. dependencies)
    else
        reason = getglobal("ADDON_"..reason)
        GameTooltip:AddLine(name, 1, 1, 1, 1, false)
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(notes, 1, 0.82, 0, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Addon is Active: " .. RED .. "False")
        GameTooltip:AddLine("Reason: " .. RED .. reason)
        GameTooltip:AddLine("LoadOnDemand: " .. loadondemand)
        GameTooltip:AddLine("Dependencies: " .. dependencies)
    end
    GameTooltip:Show()
    getglobal("CS_AddOnOrganizer_List_Title" .. this:GetID()):SetBackdropColor(1, 1, 1, 0.4)
end

function CS_AddOnOrganizer_TitleButton_OnLeave()
    getglobal("CS_AddOnOrganizer_List_Title" .. this:GetID()):SetBackdropColor(1, 1, 1, 0.1)
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
            local addonTitleTag = getglobal("CS_AddOnOrganizer_List_Title" .. i .. "Tag")
            local addonTitle = getglobal("CS_AddOnOrganizer_List_Title" .. i)
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
            local addonTitleTag = getglobal("CS_AddOnOrganizer_List_Title" .. i .. "Tag")
            local addonTitle = getglobal("CS_AddOnOrganizer_List_Title" .. i)
            addonTitleTag:SetText("Disabled")
            addonTitleTag:SetTextColor(1, 0.7, 0)
            addonTitle:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

function CS_AddOnOrganizer_ProfilesShowHide()
    if (CS_AddOnOrganizer_List_Profiles:IsVisible()) then
        HideUIPanel(CS_AddOnOrganizer_List_Profiles)
    else
        ShowUIPanel(CS_AddOnOrganizer_List_Profiles)
    end
end

function CS_AddOnOrganizer_ProfilesDropDown_OnLoad()
    UIDropDownMenu_SetWidth(220, ProfilesDropDown)
    UIDropDownMenu_Initialize(ProfilesDropDown, CS_AddOnOrganizer_InitializeDropDown)
end

local info = {}
function CS_AddOnOrganizer_InitializeDropDown()
    for i = 1, table.getn(CS_AddOnOrganizer_Profiles) do
        info.text = CS_AddOnOrganizer_Profiles[i][1]
        info.func = CS_AddOnOrganizer_LoadProfile
        info.checked = profileID and CS_AddOnOrganizer_Profiles[profileID][1] == info.text
        UIDropDownMenu_AddButton(info)
    end
end
