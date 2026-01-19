local _G = ShaguTweaks.GetGlobalEnv()
local T  = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Everlook Broadcasting"],
  description = T["Right-click the Game Menu button to open Everlook Broadcasting Co."],
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  maintainer = "@Amon_RA (GitHub)",
  category = "Micromenu Bar",
  enabled = false,
})

module.enable = function(self)

  local AUTO_CLOSE_DELAY = 10
  local closeAt = nil

  if not _G.MainMenuMicroButton then return end

  local function PositionEverlookDropdown()
    if not _G.EBCMinimapDropdown then return end

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
    if not closeAt or not _G.EBCMinimapDropdown then return end

    if _G.GetTime() >= closeAt then
      _G.EBCMinimapDropdown:Hide()
      closeAt = nil
      _G.MainMenuMicroButton:SetScript("OnUpdate", nil)
    end
  end

  -- Allow right-click without breaking Blizzard behavior
  _G.MainMenuMicroButton:RegisterForClicks(
    "LeftButtonUp",
    "RightButtonUp"
  )

  -- Preserve original Blizzard click handler
  local BlizzardOnClick = _G.MainMenuMicroButton:GetScript("OnClick")

  _G.MainMenuMicroButton:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      if _G.ShowEBCMinimapDropdown and _G.EBCMinimapDropdown then
        _G.ShowEBCMinimapDropdown()
        PositionEverlookDropdown()

        closeAt = _G.GetTime() + AUTO_CLOSE_DELAY
        _G.MainMenuMicroButton:SetScript("OnUpdate", AutoClose)
      end
      return
    end

    -- Left-click: original Blizzard behavior
    if BlizzardOnClick then
      BlizzardOnClick()
    end
  end)
end
