local _, A = ...;
A.loaded = false
A.stopAddon = false
local BL = {}


function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


local E = CreateFrame("Frame")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("BAG_UPDATE")
E:RegisterEvent("MERCHANT_SHOW")
E:RegisterEvent("MERCHANT_CLOSED")
E:RegisterEvent("BANKFRAME_OPENED")
E:RegisterEvent("BANKFRAME_CLOSED")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

--[[
  ADDON LOADING
]]
function E:PLAYER_LOGIN()
  if A.loaded then
    A:Print("AutoOpen loaded.")
  end
end

function E:ADDON_LOADED(name)
  if name ~= "AutoOpen" then return end
  A.loaded = true
  BL = AutoOpenBlackList
  if not BL then BL = {} end

  SLASH_AUTOOPEN1= "/autoopen";
  SLASH_AUTOOPEN2= "/ao";
  SlashCmdList.AUTOOPEN = function(msg)
    A:SlashCommand(msg)
  end
end

function core:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2)
  command = command:lower()

  if command == "bl" then
    local itemName = GetItemInfo(rest)
    if itemName then
      BL[itemName] = true
    end
  end
  A:Print(itemName .. " added to blacklist.")
end

--[[
  MERCHANT
]]
function E:MERCHANT_SHOW()
  A.stopAddon = true
end

function E:MERCHANT_CLOSED()
  A.stopAddon = false
end

--[[
  BANK
]]
function E:BANKFRAME_OPENED()
  A.stopAddon = true
end

function E:BANKFRAME_CLOSED()
  A.stopAddon = false
end

--[[
  BAG UPDATE & CORE FUNCTIONALITY
]]
function E:BAG_UPDATE(B)
  if A.stopAddon then return end
  if not A.loaded then return end
  if CastingInfo() then return end


  for S = 1, GetContainerNumSlots(B) do
    local _, _, locked, _, _, lootable, itemLink = GetContainerItemInfo(B, S)
    local itemName = GetItemInfo(itemLink)

    if itemLink and not string.find(itemLink, "Lockbox") and not string.find(itemLink, "Junkbox") and not BL[itemName] then -- make sure its not a lockbox
      if lootable and not locked then -- item is lootable and not locked by server
        local autolootDefault = GetCVar("autoLootDefault")

        if autolootDefault then -- autolooting
          if IsModifiedClick(AUTOLOOTTOGGLE) then -- currently holding autoloot mod key
            SetCVar("autoLootDefault", 0) -- swap the autoloot behaviour so it autoloots even with mod key held
            UseContainerItem(B, S)
            SetCVar("autoLootDefault", 1) -- swap back
          else -- not holding autoloot mod key
            UseContainerItem(B, S)
          end
        else -- not autolooting
          SetCVar("autoLootDefault", 1)
          UseContainerItem(B, S)
          SetCVar("autoLootDefault", 0)
        end
        return
      end
    end
  end
end
