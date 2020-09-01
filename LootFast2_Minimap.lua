
LootFast2.Minimap={};

--[[ Call this in initialization to move the minimap button to its saved position (also used in its movement)
** do not call from the mod's OnLoad, VARIABLES_LOADED or later is fine. **]]
function LootFast2.Minimap.Reposition()
	LootFast2_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(LF2Settings.MinimapPos)),(80*sin(LF2Settings.MinimapPos))-52)
end
function LootFast2.Minimap.OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	LF2Settings.MinimapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	LootFast2.Minimap.Reposition() -- move the button
end
function LootFast2.Minimap.OnClick(_, button)
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(button).." was clicked."); --DEBUG
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(self:GetName())); --DEBUG
	
	if button == "RightButton" then
		LootFast2.Config.Open();
	elseif button == "LeftButton" then
		--Toggle LF Enabled.
		LootFast2.Config.Toggle();
	end
end