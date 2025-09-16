local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
    title = T["Block TWoW Guild Spam"],
    description = T["Blocks guild joining & leaving messages for Turtle WoW starter guilds."],
    expansions = { ["vanilla"] = true, ["tbc"] = false },
    category = T["Social & Chat"],
    enabled = nil,
})
  
module.enable = function(self)
    local turtle = (TargetHPText or TargetHPPercText)
    local guildName = GetGuildInfo("player")    
    if not turtle then return end
    if not (guildName == "Newcomers" or guildName == "Still Alive") then return end

    local msg

    local events = {
      ["CHAT_MSG_SYSTEM"] = true,
    }
    
    local blocks = {
      { "left", "guild" },
      { "joined", "guild"},
    }
    
    local prepare = function(msg)
      msg = string.gsub(msg, "[^A-Za-z0-9]", "")
      return msg
    end
    
    local _ChatFrame_OnEvent = ChatFrame_OnEvent
    function ChatFrame_OnEvent(event)
      if events[event] and arg1 then
    
        msg = prepare(arg1)
        for _, data in pairs(blocks) do
          local matched = true
    
          for _, str in pairs(data) do
            if not strfind(string.lower(msg), string.lower(str)) then
              matched = false
            end
          end
    
          if matched == true then
            -- DEFAULT_CHAT_FRAME:AddMessage("blocked msg "..arg1)
            return true
          end
        end
      end
    
      _ChatFrame_OnEvent(event)
    end
end