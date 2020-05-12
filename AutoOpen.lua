local _, A = ...;
A.loaded = false
A.stopAddon = false
local BL = {}
A.bag = 0


function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(A.addonName .. "- " .. tostringall(...))
end


local E = CreateFrame("Frame")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("BAG_UPDATE_DELAYED")
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
  if not AutoOpenBlackList then AutoOpenBlackList = {} end

  AOBL = AutoOpenBlackList

  SLASH_AUTOOPEN1= "/autoopen";
  SLASH_AUTOOPEN2= "/ao";
  SlashCmdList.AUTOOPEN = function(msg)
    A:SlashCommand(msg)
  end
end

function A:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2)
  command = command:lower()

  if command == "bl" or command == "blacklist" then
    local itemName = GetItemInfo(rest)

    if AOBL[itemName] then
      AOBL[itemName] = nil
      A:Print(itemName .. " removed from blacklist.")
    else
      AOBL[itemName] = true
      A:Print(itemName .. " added to blacklist.")
    end
  end
  
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
function E:BAG_UPDATE_DELAYED()
  if A.stopAddon then return end
  if not A.loaded then return end
  if CastingInfo() then return end


  for B = 0, NUM_BAG_SLOTS do
    for S = 1, GetContainerNumSlots(B) do
      local _, _, locked, _, _, lootable, itemLink = GetContainerItemInfo(B, S)
      local itemName = itemLink and GetItemInfo(itemLink) or nil

      if itemLink and not string.find(itemLink:lower(), "lock") and not string.find(itemLink, "Junkbox") and not AOBL[itemName] then -- make sure its not a lockbox
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
end
