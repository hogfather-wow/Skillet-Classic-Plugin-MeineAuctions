local addonName,addonTable = ...
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local DA
if isRetail then
	DA = _G[addonName] -- for DebugAids.lua
else
	DA = LibStub("AceAddon-3.0"):GetAddon("Skillet") -- for DebugAids.lua
end
--[[
Skillet: A tradeskill window replacement.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

Skillet.MASPlugin = {}

local plugin = Skillet.MASPlugin
local L = Skillet.L

plugin.options =
{
	type = 'group',
	name = "MeineAuctions",
	order = 1,
	args = {
		enabled = {
			type = "toggle",
			name = L["Enabled"],
			get = function()
				return Skillet.db.profile.plugins.MAS.enabled
			end,
			set = function(self,value)
				Skillet.db.profile.plugins.MAS.enabled = value
				Skillet:UpdateTradeSkillWindow()
			end,
			width = "double",
			order = 1
		},
	},
}

--
-- Until we can figure out how to get defaults into the "range" variables above
--
local buyFactorDef = 4
local markupDef = 1.05

function plugin.OnInitialize()
	if not Skillet.db.profile.plugins.MAS then
		Skillet.db.profile.plugins.MAS = {}
		Skillet.db.profile.plugins.MAS.enabled = true
		Skillet.db.profile.plugins.MAS.buyFactor = buyFactorDef
		Skillet.db.profile.plugins.MAS.markup = markupDef
	end
	if Skillet.db.profile.plugins.MAS.showProfitValue == nil then
		Skillet.db.profile.plugins.MAS.showProfitValue = true
	end
	Skillet:AddPluginOptions(plugin.options)
end

function plugin.RecipeNamePrefix(skill, recipe)
	local prefix
	
	if not MeineAuctions then return end
	if not recipe then return end
	
	local itemID = recipe.itemID

	if Skillet.db.profile.plugins.MAS.enabled and itemID then
		prefix = "AH: "..MeineAuctions:GetItemCount(itemID).." :"
	end
	return prefix
end

function plugin.GetExtraText(skill, recipe)
	local label
	local extra_text

	if not MeineAuctions then return end
	if not recipe then return end
	
	local itemID = recipe.itemID

	if Skillet.db.profile.plugins.MAS.enabled and itemID then
		label = L["MeineAuctions"]
		extra_text = MeineAuctions:GetItemAuctionCount(itemID)
	end
	return label, extra_text
end

Skillet:RegisterRecipeNamePlugin("MASPlugin")		-- we have a RecipeNamePrefix or a RecipeNameSuffix function

Skillet:RegisterDisplayDetailPlugin("MASPlugin")	-- we have a GetExtraText function