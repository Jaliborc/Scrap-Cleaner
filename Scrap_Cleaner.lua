--[[
Copyright 2010-2017 João Cardoso
Scrap Cleaner is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this addon do not give permission to
redistribute and/or modify it.

This addon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the addon. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.

This file is part of Scrap Cleaner.
--]]

local TimerFrame = CreateFrame('Frame')
local NextTime = 0

local function CleanTrash()
	local time = GetTime()
	
	if NextTime < time then
		if MainMenuBarBackpackButton.freeSlots == 0 then
			local bestValue, bestBag, bestSlot
		
			for bag, slot, id in Scrap:IterateJunk() do
				local bagType = select(2, GetContainerNumFreeSlots(bag))
				if not bagType then
					return
				end
				
				if bagType == 0 then
					local maxStack = select(8, GetItemInfo(id))
					local stack = select(2, GetContainerItemInfo(bag, slot))
					if not stack or not maxStack then
						return
					end
					
					local value = select(11, GetItemInfo(id)) * (stack + maxStack) * .5 -- Lets bet 50% on not full stacks
					if not bestValue or value < bestValue then
						bestBag, bestSlot = bag, slot
						bestValue = value
					end
				end
			end
			
			if bestBag and bestSlot then
				PickupContainerItem(bestBag, bestSlot)
				DeleteCursorItem()
				
				NextTime = time + select(3, GetNetStats())
				TimerFrame:SetScript('OnUpdate', nil)
			end
		end
	else
		TimerFrame:SetScript('OnUpdate', CleanTrash)
	end
end

hooksecurefunc('MainMenuBarBackpackButton_UpdateFreeSlots', CleanTrash)