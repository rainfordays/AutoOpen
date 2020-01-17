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

function E:BAG_UPDATE()
  if not A.loaded then return end
  if CastingInfo() then return end

  for B = 0, NUM_BAG_SLOTS do
    for S = 1, GetContainerNumSlots(B) do
      local _, _, _, _, _, lootable, itemLink = GetContainerItemInfo(B, S)

      if itemLink and not string.find(itemLink, "Lockbox") and not string.find(itemLink, "Junkbox") then
        if lootable then
          local autolootDefault = GetCVar("autoLootDefault")
          if IsModifiedClick(AUTOLOOTTOGGLE) and autolootDefault then
            SetCVar("autoLootDefault", 0)
            UseContainerItem(B, S)
            SetCVar("autoLootDefault", 1)

          elseif autolootDefault then
            UseContainerItem(B, S)

          else
            SetCVar("autoLootDefault", 1)
            UseContainerItem(B, S)
            SetCVar("autoLootDefault", autolootDefault)

          end
        end
      end
    end
  end
end
