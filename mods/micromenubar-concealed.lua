local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Concealable Micromenu"],
  description = T["Hold Ctrl & Shift to move from left/right edge, press arrow to conceal. Only works when when Shagu's Reduced actionbar module is enabled"],
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  maintainer = "@Amon_RA (GitHub)",
  category = "Micromenu Bar",
  enabled = false,
})

module.enable = function(self)

  local frames = {
    CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton,
    SocialsMicroButton, WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
  }

  -- ======================================================
  -- HARD disable ShaguTweaks "Show Micro Menu"
  -- ======================================================
  local function disableShaguTweaksMicroMenu()
    -- Disable the module itself
    if ShaguTweaks.modules then
      for _, mod in pairs(ShaguTweaks.modules) do
        if mod.title == T["Show Micro Menu"] and mod.enabled then
          if mod.disable then
            mod:disable()
          end
        end
      end
    end

    -- Kill the already-created frame if it exists
    if _G.ShaguTweaksReducedActionBarMicroMenu then
      local f = _G.ShaguTweaksReducedActionBarMicroMenu
      f:Hide()
      f:SetScript("OnUpdate", nil)
      f:SetScript("OnEvent", nil)
      f:UnregisterAllEvents()
    end
  end

  ShaguTweaks_config = ShaguTweaks_config or {}
  ShaguTweaks_config["ReducedActionbarBags"] =
    ShaguTweaks_config["ReducedActionbarBags"] or {}
  local movedb = ShaguTweaks_config["ReducedActionbarBags"]

  local holder = CreateFrame("Frame", "microholder", UIParent)
  local toggle = CreateFrame("Button", "microholder_toggle", UIParent)
  local name = holder:GetName()

  local width  = 210
  local height = 44
  local toggleWidth = 12

  -- ======================================================
  -- Holder
  -- ======================================================
  local function setupHolder()
    holder:SetWidth(width)
    holder:SetHeight(height)
    holder:SetFrameStrata("MEDIUM")
    holder:SetFrameLevel(64)
    holder:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 8,
      edgeSize = 16,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    holder:SetBackdropBorderColor(.9,.8,.5,1)
    holder:SetBackdropColor(.4,.4,.4,1)
    holder:SetMovable(true)
    holder:SetClampedToScreen(true)
  end

  -- ======================================================
  -- Toggle visuals
  -- ======================================================
  local arrow

  local function updateArrow()
    if holder:IsShown() then
      arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    else
      arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    end
  end

  local function toggleEnter()
    GameTooltip:SetOwner(toggle, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggle Micro Menu")
    GameTooltip:Show()
    toggle:SetBackdropColor(.2, .2, .2, 0.8)
  end

  local function toggleLeave()
    GameTooltip:Hide()
    toggle:SetBackdropColor(0, 0, 0, 0)
  end

  local function setupToggle()
    toggle:SetWidth(toggleWidth)
    toggle:SetHeight(height)
    toggle:SetFrameStrata("MEDIUM")
    toggle:SetFrameLevel(holder:GetFrameLevel() + 10)
    toggle:EnableMouse(true)

    toggle:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    toggle:SetBackdropColor(0, 0, 0, 0)

    arrow = toggle:CreateTexture(nil, "ARTWORK")
    arrow:SetWidth(14)
    arrow:SetHeight(14)
    arrow:SetPoint("CENTER", toggle, "CENTER")
    arrow:SetAlpha(0.9)

    updateArrow()

    toggle:SetScript("OnClick", function()
      if holder:IsShown() then
        holder:Hide()
      else
        holder:Show()
      end
      updateArrow()
    end)

    toggle:SetScript("OnEnter", toggleEnter)
    toggle:SetScript("OnLeave", toggleLeave)
  end

  -- ======================================================
  -- RIGHT handle
  -- ======================================================
  local function setupRightHandle()
    local handle = CreateFrame("Button", nil, toggle)
    handle:SetAllPoints(toggle)
    handle:SetFrameStrata(toggle:GetFrameStrata())
    handle:SetFrameLevel(toggle:GetFrameLevel() + 1)
    handle:EnableMouse(true)

    handle:RegisterForDrag("LeftButton")
    handle:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    handle:SetScript("OnEnter", toggleEnter)
    handle:SetScript("OnLeave", toggleLeave)

    handle:SetScript("OnDragStart", function()
      if IsShiftKeyDown() and IsControlKeyDown() then
        holder:StartMoving()
      end
    end)

    handle:SetScript("OnDragStop", function()
      holder:StopMovingOrSizing()
      movedb[name] = { holder:GetLeft(), holder:GetTop() }
      position()
    end)

    handle:SetScript("OnClick", function()
      if arg1 == "RightButton"
        and IsShiftKeyDown()
        and IsControlKeyDown() then
        defaultPosition()
        position()
        return
      end

      if arg1 == "LeftButton"
        and not IsShiftKeyDown()
        and not IsControlKeyDown() then
        toggle:GetScript("OnClick")(toggle)
      end
    end)
  end

  -- ======================================================
  -- LEFT handle
  -- ======================================================
  local function setupLeftHandle()
    local handle = CreateFrame("Button", nil, holder)
    handle:SetWidth(toggleWidth)
    handle:SetHeight(height)
    handle:SetPoint("LEFT", holder, "LEFT", -toggleWidth / 2, 0)
    handle:SetFrameLevel(holder:GetFrameLevel() + 1)
    handle:EnableMouse(true)

    handle:RegisterForDrag("LeftButton")
    handle:RegisterForClicks("RightButtonDown")

    handle:SetScript("OnDragStart", function()
      if IsShiftKeyDown() and IsControlKeyDown() then
        holder:StartMoving()
      end
    end)

    handle:SetScript("OnDragStop", function()
      holder:StopMovingOrSizing()
      movedb[name] = { holder:GetLeft(), holder:GetTop() }
      position()
    end)

    handle:SetScript("OnClick", function()
      if arg1 == "RightButton"
        and IsShiftKeyDown()
        and IsControlKeyDown() then
        defaultPosition()
        position()
      end
    end)
  end

  -- ======================================================
  -- Positioning
  -- ======================================================
  function defaultPosition()
    holder:ClearAllPoints()
    holder:SetPoint("LEFT", ActionButton12, "RIGHT", 100, 0)
  end

  function position()
    holder:ClearAllPoints()
    if movedb[name] then
      holder:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", movedb[name][1], movedb[name][2])
    else
      defaultPosition()
    end

    toggle:ClearAllPoints()
    toggle:SetPoint("LEFT", holder, "RIGHT", 0, 0)
  end

  -- ======================================================
  -- Restore micro buttons
  -- ======================================================
  local function restore()
    CharacterMicroButton:SetPoint("LEFT", holder, "LEFT", 3, 11)
    SpellbookMicroButton:SetPoint("LEFT", CharacterMicroButton, "RIGHT", -4, 0)
    TalentMicroButton:SetPoint("LEFT", SpellbookMicroButton, "RIGHT", -4, 0)
    QuestLogMicroButton:SetPoint("LEFT", TalentMicroButton, "RIGHT", -4, 0)
    SocialsMicroButton:SetPoint("LEFT", QuestLogMicroButton, "RIGHT", -4, 0)
    WorldMapMicroButton:SetPoint("LEFT", SocialsMicroButton, "RIGHT", -4, 0)
    MainMenuMicroButton:SetPoint("LEFT", WorldMapMicroButton, "RIGHT", -4, 0)
    HelpMicroButton:SetPoint("LEFT", MainMenuMicroButton, "RIGHT", -4, 0)

    for _, frame in pairs(frames) do
      frame:SetParent(holder)
      frame.Show = frame:Show()
      frame:Show()
    end
  end

  -- ======================================================
  -- Init
  -- ======================================================
  local events = CreateFrame("Frame")
  events:RegisterEvent("PLAYER_ENTERING_WORLD")
  events:SetScript("OnEvent", function()
    if this.loaded then return end
    this.loaded = true
    if MainMenuExpBar:GetWidth() > 512 then return end

    disableShaguTweaksMicroMenu()

    setupHolder()
    setupToggle()
    setupRightHandle()
    setupLeftHandle()
    restore()
    position()

    holder:Show()
    toggle:Show()
    updateArrow()
  end)
end
