local _G = ShaguTweaks.GetGlobalEnv()
local T  = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Smart Timers"],
  description = T["Pads hours/minutes, hides zero units, shows seconds under 1 minute, flashes under 10s, and adds color gradients."],
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  maintainer = "@Amon_RA (GitHub)",
  category = T["Buffs & Debuffs"],
  enabled = nil,
})

module.enable = function(self)

  --------------------------------------------------
  -- Time formatter
  --------------------------------------------------
  local function FormatTimeSmart(seconds)
    if not seconds or seconds < 0 then
      return ""
    end

    seconds = _G.floor(seconds)

    local h = _G.floor(seconds / 3600)
    local m = _G.floor(_G.mod(seconds, 3600) / 60)
    local s = _G.mod(seconds, 60)

    if seconds < 60 then
      return string.format("%ds", s)
    end

    if h > 0 then
      return string.format("%dh%dm", h, m)
    else
      return string.format("%dm", m)
    end
  end

  --------------------------------------------------
  -- Color gradient
  --------------------------------------------------
  local function GetTimeColor(seconds)
    local warning = _G.BUFF_DURATION_WARNING_TIME or 60

    if seconds >= warning then
      return 0, 1, 0
    end

    local pct = seconds / warning

    if pct > 0.5 then
      local t = (pct - 0.5) * 2
      return 1 - t, 1, 0
    else
      local t = pct * 2
      return 1, t, 0
    end
  end

  --------------------------------------------------
  -- Override duration updater (safe)
  --------------------------------------------------
  local old_Update = _G.BuffFrame_UpdateDuration
  _G.BuffFrame_UpdateDuration = function(buffButton, timeLeft)

    local duration = _G.getglobal(buffButton:GetName().."Duration")

    if _G.SHOW_BUFF_DURATIONS ~= "1" or not timeLeft then
      duration:Hide()
      return
    end

    duration:SetText(FormatTimeSmart(timeLeft))

    local r, g, b = GetTimeColor(timeLeft)
    duration:SetVertexColor(r, g, b)

    if timeLeft < 10 then
      local flash = _G.mod(_G.GetTime(), 0.5) < 0.25
      duration:SetAlpha(flash and 0.3 or 1.0)
    else
      duration:SetAlpha(1)
    end

    duration:Show()
  end

  --------------------------------------------------
  -- Manual hook for BuffButton_OnLoad (Vanilla-safe)
  --------------------------------------------------
  local old_OnLoad = _G.BuffButton_OnLoad
  _G.BuffButton_OnLoad = function()
    old_OnLoad()

    local duration = _G.getglobal(this:GetName().."Duration")
    if duration then
      duration:SetWidth(70)
    end
  end

end
