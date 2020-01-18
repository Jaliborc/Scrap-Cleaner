--[[
Copyright 2010-2020 João Cardoso
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

local Cleaner = Scrap:NewModule('Cleaner')

function Cleaner:OnEnable()
	self:RegisterEvent('ITEM_UNLOCKED', 'OnEvent')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent')
end

function Cleaner:OnEvent()
	if InCombatLockdown() or UnitIsDead('player') or GetCursorInfo() then
		return
	end

	for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
		local free, type = GetContainerNumFreeSlots(bag)
		if type and free and free > 0 then
			return
		end
	end

	local bestBag, bestSlot
	local bestValue

	for bag, slot, id in Scrap:IterateJunk() do
		local type = select(2, GetContainerNumFreeSlots(bag))
		if type == 0 then
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
	end
end
