local _, core = ...;

core.loaded = false
--[[

  AutoOpenTooltip = CreateFrame("GAMETOOLTIP", "AutoOpenTooltip",nil,"GameTooltipTemplate")
  AutoOpenTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
]]


function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("BAG_UPDATE")
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

function events:PLAYER_LOGIN()
  core.loaded = true
  core:Print("AutoOpen loaded.")
end


function events:ADDON_LOADED(name)
  if name ~= "AutoOpen" then return end
end

function events:BAG_UPDATE()
  if not core.loaded then return end

  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      local _, _, _, _, _, lootable, itemLink = GetContainerItemInfo(bag, slot)

      if itemLink and not string.find(itemLink, "Lockbox") and not string.find(itemLink, "Junkbox") then
        if lootable then
          local autolootDefault = GetCVar("autoLootDefault")
          if IsModifiedClick(AUTOLOOTTOGGLE) and autolootDefault then
            SetCVar("autoLootDefault", 0)
            UseContainerItem(bag, slot)
            SetCVar("autoLootDefault", 1)

          elseif autolootDefault then
              UseContainerItem(bag, slot)

          else
            SetCVar("autoLootDefault", 1)
            UseContainerItem(bag, slot)
            SetCVar("autoLootDefault", autolootDefault)

          end
        end
      end
    end
  end
end
