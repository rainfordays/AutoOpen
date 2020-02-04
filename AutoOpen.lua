local _, A = ...;
A.loaded = false


function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


local E = CreateFrame("Frame")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("BAG_UPDATE")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

function E:PLAYER_LOGIN()
  if A.loaded then
    A:Print("AutoOpen loaded.")
  end
end


function E:ADDON_LOADED(name)
  if name ~= "AutoOpen" then return end
  A.loaded = true
end


function E:BAG_UPDATE(B)
  if not A.loaded then return end
  if CastingInfo() then return end


  for S = 1, GetContainerNumSlots(B) do
    local _, _, locked, _, _, lootable, itemLink = GetContainerItemInfo(B, S)

    if itemLink and not string.find(itemLink, "Lockbox") and not string.find(itemLink, "Junkbox") then -- make sure its not a lockbox
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
