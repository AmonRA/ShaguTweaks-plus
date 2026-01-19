local _G = ShaguTweaks.GetGlobalEnv()
local T  = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Micro Menu: Everlook Broadcasting"],
  description = T["Left-click the Game Menu button to open Everlook Broadcasting Co. Right-click opens the original Game Menu. Auto-closes after 10 seconds."],
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  maintainer = "@Amon_RA (GitHub)",
  category = "Micromenu Bar",
  enabled = false,
})

module.enable = function(self)

  local AUTO_CLOSE_DELAY = 10
  local closeAt = nil

  local function PositionEverlookDropdown()
    if not _G.EBCMinimapDropdown then return end
    if not _G.MainMenuMicroButton then return end

    _G.EBCMinimapDropdown:ClearAllPoints()
    _G.EBCMinimapDropdown:SetPoint(
      "BOTTOMRIGHT",
      _G.MainMenuMicroButton,
      "TOPRIGHT",
      0,
      4
    )
  end

  local function AutoClose()
    if not closeAt then return end
    if not _G.EBCMinimapDropdown then return end

    if _G.GetTime() >= closeAt then
     _G.EBCMinimapDropdown:Hide()
     closeAt = nil
     _G.MainMenuMicroButton:SetScript("OnUpdate", nil)
    end
  end

  if not _G.MainMenuMicroButton then return end

  _G.MainMenuMicroButton:RegisterForClicks(
    "LeftButtonUp",
    "RightButtonUp"
  )

  _G.MainMenuMicroButton:SetScript("OnEnter", function()
    _G.GameTooltip:SetOwner(
      _G.MainMenuMicroButton,
      "ANCHOR_RIGHT"
    )
    _G.GameTooltip:SetText(
      T["Micro Menu: Everlook Broadcasting"]
      .. "\n|cffaaaaaaRight-click: Game Menu|r"
    )
  end)

  _G.MainMenuMicroButton:SetScript(
    "OnLeave",
    _G.GameTooltip_Hide
  )

  _G.MainMenuMicroButton:SetScript("OnClick", function()
    if _G.arg1 == "RightButton" then
      _G.ToggleGameMenu()
      return
    end

    if _G.ShowEBCMinimapDropdown and _G.EBCMinimapDropdown then
      _G.ShowEBCMinimapDropdown()
      PositionEverlookDropdown()

      closeAt = _G.GetTime() + AUTO_CLOSE_DELAY
      _G.MainMenuMicroButton:SetScript("OnUpdate", AutoClose)
    end
  end)

  _G.MainMenuMicroButton.tooltipText =
    T["Micro Menu: Everlook Broadcasting"]
end
