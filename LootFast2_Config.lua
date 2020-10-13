LootFast2.Config={};

--Start of Configuration Window
function LootFast2.Config.OnLoad(panel)
	panel.name = "LootFast2";
	panel.default = function(self)
		LootFast2.Config.Reset();
	end
	InterfaceOptions_AddCategory(panel);

	LootFastConfigTitle:SetText("LootFast2 v9.0.0.10132020");
	LootFastConfigSubTitle:SetText("|cFFFFFFFFConfiguration|r");
	LootFastConfigMinimapTitle:SetText("Show Minimap Button: ");
	LootFastConfigEnabledTitle:SetText("Enable LootFast: ");
	LootFastConfigCloseTitle:SetText("Close Loot Window Options: ");
	LootFastConfigLootStateTitle:SetText("Loot State: ");
	LootFastConfigQualityTitle:SetText("Quality Settings: ");
	LootFastConfigQualityMoney:SetText("|cFF00ccffMoney|r");
	LootFastConfigQualityPoor:SetText("|cff9d9d9dPoor|r");
	LootFastConfigQualityCommon:SetText("|cffffffffCommon|r");
	LootFastConfigQualityUncommon:SetText("|cff1eff00Uncommon|r");
	LootFastConfigQualityRare:SetText("|cff0070ddRare|r");
	LootFastConfigQualityEpic:SetText("|cffa335eeEpic|r");
	LootFastConfigQualityLegendary:SetText("|cffff8000Legendary|r");

	LootFastConfigSellPriceTitle:SetText("Sell Price Threshold:");
	LootFastConfigSPGold:SetText(GOLD_AMOUNT_TEXTURE:sub(3):format(24,24));
	LootFastConfigSPSilver:SetText(SILVER_AMOUNT_TEXTURE:sub(3):format(24,24));
	LootFastConfigSPCopper:SetText(COPPER_AMOUNT_TEXTURE:sub(3):format(24,24));
	LootFastConfigSPNote:SetText("|cFFFFFFFFIf the item does not meet the sell price,|nits quality is ignored!|r");

	LootFastConfigNameTitle:SetText("Name Settings: ");
	LootFastConfigNameInputTitle:SetText("Item Name: ");
	LootFastConfigNameCommandTitle:SetText("Loot Setting: ");


	LootFastConfigSFHolderNameScrollFrame.update = LootFast2.Config.NameScrollFrameUpdate;
	LootFastConfigSFHolderNameScrollFrame.scrollBar.doNotHide = true;
end

function LootFast2.Config.Open()
	--Initialize UI
	LootFast2.Config.MinimapCBToggle(nil);
	LootFast2.Config.EnabledCBToggle(nil);

	--Open Addon Options
	InterfaceOptionsFrame_OpenToCategory("LootFast2");
	InterfaceOptionsFrame_OpenToCategory("LootFast2");

	--Update Sell Price Status
	if(LF2Settings.PriceThresh == 0)then
		LootFastConfigSellPriceStatus:SetText("All Items");
	else
		LootFastConfigSellPriceStatus:SetText(GetCoinTextureString(LF2Settings.PriceThresh));
	end


	--Start Init
	LootFast2.Config.InitNameList();
end

function LootFast2.Config.InitNameList()
	HybridScrollFrame_CreateButtons(LootFastConfigSFHolderNameScrollFrame,"LFNameBarTemplate",0,0,"TOPLEFT","TOPLEFT",0,-2,"TOP","BOTTOM");

  LootFastConfigSFHolderNameScrollFrameScrollBar:SetValue(0);
  LootFast2.Config.NameScrollFrameUpdate();
end

function LootFast2.Config.NameScrollFrameUpdate()
	local scrollFrame = LootFastConfigSFHolderNameScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
  local buttons = scrollFrame.buttons;
  local height = 22; -- height of a row

  for i=1, #buttons do
    local idx = offset + i;
    local button = buttons[i];
    local itemName = _G["LootFastConfigSFHolderNameScrollFrameButton"..i.."ItemName"];
    local itemNameValue = _G["LootFastConfigSFHolderNameScrollFrameButton"..i.."ItemNameValue"];
    local btnRemove = _G["LootFastConfigSFHolderNameScrollFrameButton"..i.."RemoveBtn"];

    if idx <= #LF2Settings.LootNameKeys then
			itemName:SetText(LF2Settings.LootNameKeys[idx]);
			itemNameValue:SetText(LootFast2.Config.GetNameValueText(LF2Settings.LootName[LF2Settings.LootNameKeys[idx]]));
    	button.index = idx;
    	btnRemove.index = idx;
      button:Show();
    else
    	button.index = nil;
    	btnRemove.index = nil;
      itemName:SetText("");
      itemNameValue:SetText("");
    	button:Hide();
    end
  end
  HybridScrollFrame_Update(scrollFrame, height*#LF2Settings.LootNameKeys, scrollFrame:GetHeight());
end
function LootFast2.Config.InitConfigDropDowns()
	--Auto Close
	CloseOptsDD = CreateFrame("Frame", "CloseOptsDD", LootFastConfig, "UIDropDownMenuTemplate");
	CloseOptsDD:SetPoint("LEFT","LootFastConfigCloseTitle","RIGHT",0,-2);
	UIDropDownMenu_SetWidth(CloseOptsDD, 150);
	UIDropDownMenu_Initialize(CloseOptsDD, LootFast2.Config.InitCloseDropDown);
	UIDropDownMenu_SetSelectedValue(CloseOptsDD, LF2Settings.closeLoot);
	--Loot State
	LootStateDD = CreateFrame("Frame", "LootStateDD", LootFastConfig, "UIDropDownMenuTemplate");
	LootStateDD:SetPoint("LEFT","LootFastConfigLootStateTitle","RIGHT",0,-2);
	UIDropDownMenu_SetWidth(LootStateDD, 475);
	UIDropDownMenu_Initialize(LootStateDD, LootFast2.Config.InitLootStateDropDown);
	UIDropDownMenu_SetSelectedValue(LootStateDD, LF2Settings.AllBut);
	--Quality
	--Money
	QLMoneyDD = CreateFrame("Frame", "QLMoneyDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLMoneyDD:SetPoint("LEFT","LootFastConfigQualityMoney","RIGHT",15,-4);
	UIDropDownMenu_SetWidth(QLMoneyDD, 125);
	UIDropDownMenu_Initialize(QLMoneyDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLMoneyDD, LF2Settings.LootQual[-1]);
	--Poor
	QLPoorDD = CreateFrame("Frame", "QLPoorDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLPoorDD:SetPoint("TOP","QLMoneyDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLPoorDD, 125);
	UIDropDownMenu_Initialize(QLPoorDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLPoorDD, LF2Settings.LootQual[0]);
	--Common
	QLCommonDD = CreateFrame("Frame", "QLCommonDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLCommonDD:SetPoint("TOP","QLPoorDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLCommonDD, 125);
	UIDropDownMenu_Initialize(QLCommonDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLCommonDD, LF2Settings.LootQual[1]);
	--Uncommon
	QLUncommonDD = CreateFrame("Frame", "QLUncommonDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLUncommonDD:SetPoint("TOP","QLCommonDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLUncommonDD, 125);
	UIDropDownMenu_Initialize(QLUncommonDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLUncommonDD, LF2Settings.LootQual[2]);
	--Rare
	QLRareDD = CreateFrame("Frame", "QLRareDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLRareDD:SetPoint("TOP","QLUncommonDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLRareDD, 125);
	UIDropDownMenu_Initialize(QLRareDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLRareDD, LF2Settings.LootQual[3]);
	--Epic
	QLEpicDD = CreateFrame("Frame", "QLEpicDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLEpicDD:SetPoint("TOP","QLRareDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLEpicDD, 125);
	UIDropDownMenu_Initialize(QLEpicDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLEpicDD, LF2Settings.LootQual[4]);
	--Legendary
	QLLegendaryDD = CreateFrame("Frame", "QLLegendaryDD", LootFastConfig, "UIDropDownMenuTemplate");
	QLLegendaryDD:SetPoint("TOP","QLEpicDD","BOTTOM",0,6);
	UIDropDownMenu_SetWidth(QLLegendaryDD, 125);
	UIDropDownMenu_Initialize(QLLegendaryDD, LootFast2.Config.InitQualityDropDown);
	UIDropDownMenu_SetSelectedValue(QLLegendaryDD, LF2Settings.LootQual[5]);
	--Name
	NameDD = CreateFrame("Frame", "NameDD", LootFastConfig, "UIDropDownMenuTemplate");
	NameDD:SetPoint("LEFT","LootFastConfigNameCommandTitle","RIGHT",0,-4);
	UIDropDownMenu_SetWidth(NameDD, 125);
	UIDropDownMenu_Initialize(NameDD, LootFast2.Config.InitNameDropDown);
	UIDropDownMenu_SetSelectedValue(NameDD, 1);

	--Set Backdrops for text fields/areas
	LootFastConfig_SPGoldEB:SetBackdrop(BACKDROP_TEXT_PANEL_0_16);
	-- LootFastConfig_SPGoldEB:SetBackdrop(
	-- 	{
	-- 		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	-- 		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	-- 		tile = true,
	-- 		tileEdge = true,
	-- 		tileSize = 16,
	-- 		edgeSize = 16,
	-- 		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	-- 	});
	LootFastConfig_SPSilverEB:SetBackdrop(BACKDROP_TEXT_PANEL_0_16);
	LootFastConfig_SPCopperEB:SetBackdrop(BACKDROP_TEXT_PANEL_0_16);
	LootFastConfig_NameEB:SetBackdrop(BACKDROP_TEXT_PANEL_0_16);
	LootFastConfigSFHolder:SetBackdrop(BACKDROP_DIALOG_32_32);
end
function LootFast2.Config.CloseDropDownClick(self,arg1)
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..arg1);
	LootFast2.Config.SetCloseOption(arg1);
	UIDropDownMenu_SetSelectedValue(self, arg1);
end
function LootFast2.Config.InitCloseDropDown(self)
	local info = UIDropDownMenu_CreateInfo();
	info.text = "No Auto Close";
  info.value = -1;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.CloseDropDownClick(self,-1) end;
  UIDropDownMenu_AddButton(info, 1);

  --local info2 = UIDropDownMenu_CreateInfo();
	info.text = "Close Immediately";
  info.value = 0;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.CloseDropDownClick(self,0) end;
  UIDropDownMenu_AddButton(info, 1);

  local i = 1;
  while i < 11 do
	  --local info = UIDropDownMenu_CreateInfo();
	  local k = i;
	  --DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..i);
	  if i == 1 then
			info.text = "Close After "..i.." second";
		else
			info.text = "Close After "..i.." seconds";
		end
	  info.value = i;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.CloseDropDownClick(self,k) end;
	  UIDropDownMenu_AddButton(info, 1);
	  i = i+1;
	end
end
function LootFast2.Config.InitLootStateDropDown(self)
	local info = UIDropDownMenu_CreateInfo();
	info.text = "Only items specified by name or quality";
  info.value = 0;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.LootStateDropDownClick(self,0) end;
  UIDropDownMenu_AddButton(info, 1);

  info.text = "All items but those specified by name or quality";
  info.value = 1;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.LootStateDropDownClick(self,1) end;
  UIDropDownMenu_AddButton(info, 1);

  info.text = "All items but those specified by name or quality (Automatic Greed Roll)";
  info.value = 2;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.LootStateDropDownClick(self,2) end;
  UIDropDownMenu_AddButton(info, 1);

  info.text = "All items but those specified by name or quality (Automatic Greed Roll, Include BoP)";
  info.value = 3;
  info.checked = nil;
  info.owner = self:GetParent();
	info.icon = nil;
  info.func = function() LootFast2.Config.LootStateDropDownClick(self,3) end;
  UIDropDownMenu_AddButton(info, 1);
end
function LootFast2.Config.LootStateDropDownClick(self,arg1)
	LootFast2.Config.SetLootState(arg1);
	UIDropDownMenu_SetSelectedValue(self, arg1);
end
function LootFast2.Config.InitQualityDropDown(self)
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..self:GetName());
	if(self)then
		--Determine Quality
		local quality = nil;
		if(string.find(self:GetName(),"Money"))then
			quality = -1;
		elseif(string.find(self:GetName(),"Poor"))then
			quality = 0;
		elseif(string.find(self:GetName(),"Common"))then
			quality = 1;
		elseif(string.find(self:GetName(),"Uncommon"))then
			quality = 2;
		elseif(string.find(self:GetName(),"Rare"))then
			quality = 3;
		elseif(string.find(self:GetName(),"Epic"))then
			quality = 4;
		elseif(string.find(self:GetName(),"Legendary"))then
			quality = 5;
		end

		--Init
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Do NOT Autoloot";
	  info.value = 0;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.QualityDropDownClick(self,0,quality) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Autoloot";
	  info.value = 1;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.QualityDropDownClick(self,1,quality) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Autoloot and Greed Roll ";
	  info.value = 2;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.QualityDropDownClick(self,2,quality) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Do NOT Autoloot even BoP";
	  info.value = 3;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.QualityDropDownClick(self,3,quality) end;
	  UIDropDownMenu_AddButton(info, 1);
	end
end
function LootFast2.Config.QualityDropDownClick(self,arg1,arg2)
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..arg1.." "..arg2);--DEBUG
	LootFast2.Config.SetQuality(arg2,arg1);
	UIDropDownMenu_SetSelectedValue(self, arg1);
end
function LootFast2.Config.InitNameDropDown(self)
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..self:GetName());
	if(self)then
		--Init
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Do NOT Autoloot";
	  info.value = 0;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.NameDropDownClick(self,0) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Autoloot";
	  info.value = 1;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.NameDropDownClick(self,1) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Autoloot and Greed Roll ";
	  info.value = 2;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.NameDropDownClick(self,2) end;
	  UIDropDownMenu_AddButton(info, 1);

	  info.text = "Do NOT Autoloot even BoP";
	  info.value = 3;
	  info.checked = nil;
	  info.owner = self:GetParent();
		info.icon = nil;
	  info.func = function() LootFast2.Config.NameDropDownClick(self,3) end;
	  UIDropDownMenu_AddButton(info, 1);
	end
end
function LootFast2.Config.NameDropDownClick(self,arg1)
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..arg1.." "..arg2);--DEBUG
	--LootFast2.Config.SetQuality(arg2,arg1);
	UIDropDownMenu_SetSelectedValue(self, arg1);
end
function LootFast2.Config.NameSaveClick()
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: NameSaveClick");--DEBUG
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..LootFastConfig_NameEB:GetText());--DEBUG
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..UIDropDownMenu_GetSelectedValue(NameDD));--DEBUG
	LootFast2.Config.SetNameFilter(LootFastConfig_NameEB:GetText(), UIDropDownMenu_GetSelectedValue(NameDD))
end
function LootFast2.Config.NameClearClick()
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast: NameClearClick");--DEBUG
	LF2Settings.LootName = {};
	LF2Settings.LootNameKeys = {};
	LootFast2.Config.NameScrollFrameUpdate();
	DEFAULT_CHAT_FRAME:AddMessage("LootFast: Name Filters Cleared!");
end
function LootFast2.Config.Reset()
	--RESET Settings
	LF2Settings.LootName = {};
	LF2Settings.allBut = 0;
	LF2Settings.enabled = 1;
	LF2Settings.closeLoot = 0;
	LF2Settings.LootQual = {1, 1, 1, 1, 1, 1}; --Index 6 Artifact, Always Loot!
	LF2Settings.LootQual[0] = 1;
	LF2Settings.LootQual[-1] = 1;
	LF2Settings.db = {profile={minimap={hide=false}}};
	LF2Settings.PriceThresh = 0;

	--Refresh UI Componenets
	LootFast2.Config.InitConfigDropDowns();
	if LootFast2.icon then
		LootFast2.icon:Show("LootFast2");
	else
		LootFast2_MinimapButton:Show();
	end

	DEFAULT_CHAT_FRAME:AddMessage("All LootFast settings reset!");
end
function LootFast2.Config.SetCloseOption(arg)
	LF2Settings.closeLoot = arg;

	if(LF2Settings.closeLoot >= 0) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will now close the loot window after " .. LF2Settings.closeLoot .. " Seconds.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will not close the loot window.");
	end
end
function LootFast2.Config.Toggle()
	LF2Settings.Enabled = 1 - LF2Settings.Enabled;
	if(LF2Settings.Enabled == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast is now on");
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootFast is now off");
	end
	LootFast2.Config.EnabledCBToggle(nil);
end
function LootFast2.Config.MinimapToggle()
	LF2Settings.db.profile.minimap.hide = not LF2Settings.db.profile.minimap.hide;
	if not LF2Settings.db.profile.minimap.hide then
		if LootFast2.icon then
			LootFast2.icon:Show("LootFast2");
		else
			LootFast2_MinimapButton:Show();
		end
		DEFAULT_CHAT_FRAME:AddMessage("LootFast Minimap Button is now shown");
	else
		if LootFast2.icon then
			LootFast2.icon:Hide("LootFast2");
		else
			LootFast2_MinimapButton:Hide();
		end
		DEFAULT_CHAT_FRAME:AddMessage("LootFast Minimap Button is now hidden");
	end
end
function LootFast2.Config.MinimapCBToggle(self)
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(self)); --DEBUG
	if(self) then
		--DEFAULT_CHAT_FRAME:AddMessage(tostring(self:GetName())); --DEBUG
		LootFast2.Config.MinimapToggle();
	end

	if LF2Settings.db.profile.minimap.hide then
		LootFastConfig_MinimapCB:SetChecked(nil);
	else
		LootFastConfig_MinimapCB:SetChecked(1);
	end
end
function LootFast2.Config.EnabledCBToggle(self)
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(self:GetName())); --DEBUG
	if(self) then
		LootFast2.Config.Toggle();
	end

	if(LF2Settings.Enabled == 1) then
		LootFastConfig_EnabledCB:SetChecked(1);
	else
		LootFastConfig_EnabledCB:SetChecked(nil);
	end
end
function LootFast2.Config.SetLootState(val)
	LF2Settings.AllBut = val;

	if(LF2Settings.AllBut > 3) then
		LF2Settings.AllBut = 0;
	end
	if(LF2Settings.AllBut == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot only those items specified by name or quality");
	end
	if(LF2Settings.AllBut == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot all items but those specified by name or quality");
	end
	if(LF2Settings.AllBut == 2) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot and automatically greed roll all items but those specified by name or quality");
	end
	if(LF2Settings.AllBut == 3) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot and greed roll all items but those specified by name or quality, even BoP items");
	end
end
function LootFast2.Config.SetQuality(qual,num)
	LF2Settings.LootQual[qual] = num;

	local nam = "Unknown";
	if(qual == -1) then
		nam = "|cFF00ccffMoney|r";
	end
	if(qual == 0) then
		nam = "|cff9d9d9dPoors|r";
	end
	if(qual == 1) then
		nam = "|cffffffffCommons|r";
	end
	if(qual == 2) then
		nam = "|cff1eff00Uncommons|r";
	end
	if(qual == 3) then
		nam = "|cff0070ddRares|r";
	end
	if(qual == 4) then
		nam = "|cffa335eeEpics|r";
	end
	if(qual == 5) then
		nam = "|cffff8000Legendaries|r";
	end
	if(num == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will not autoloot " .. nam);
	end
	if(num == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will autoloot " .. nam);
	end
	if(num == 2) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will autoloot and greed roll " .. nam);
	end
	if(num == 3) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will not autoloot " .. nam .. " even if they are BoP");
	end
end
function LootFast2.Config.SetNameFilter(itemName,num)
	local n = tonumber(num);

	if LF2Settings.LootName[itemName] == nil then
		table.insert(LF2Settings.LootNameKeys, itemName);
	end
	LF2Settings.LootName[itemName] = n;

	if(n == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will not autoloot [" .. itemName .. "]");
	end
	if(n == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will autoloot [" .. itemName .. "]");
	end
	if(n == 2) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will autoloot and greed roll [" .. itemName .. "]");
	end
	if(n == 3) then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will not autoloot [" .. itemName .. "] even if it is BoP");
	end

	HybridScrollFrame_CreateButtons(LootFastConfigSFHolderNameScrollFrame,"LFNameBarTemplate",0,0,"TOPLEFT","TOPLEFT",0,-2,"TOP","BOTTOM");
	LootFast2.Config.NameScrollFrameUpdate();
end
function LootFast2.Config.GetNameValueText(lootSetting)
		if(lootSetting == 0)then
			return "Do NOT Autoloot";
		elseif(lootSetting == 1)then
			return "Autoloot";
		elseif(lootSetting == 2)then
			return "Autoloot and Greed Roll ";
		elseif(lootSetting == 3)then
			return "Do NOT Autoloot even BoP";
		else
			return "Unknown";
		end
end
function LootFast2.Config.NameListItemClick(self,button)
	--DEFAULT_CHAT_FRAME:AddMessage("NameListItemClick");
	--DEFAULT_CHAT_FRAME:AddMessage("NameListItemClick index: "..self.index);
	--DEFAULT_CHAT_FRAME:AddMessage("NameListItemClick: "..LF2Settings.LootName[LF2Settings.LootNameKeys[self.index]]);
	LootFastConfig_NameEB:SetText(LF2Settings.LootNameKeys[self.index]);
	UIDropDownMenu_SetSelectedValue(NameDD,LF2Settings.LootName[LF2Settings.LootNameKeys[self.index]]);
end
function LootFast2.Config.NameListItemDeleteClick(self,button)
	--DEFAULT_CHAT_FRAME:AddMessage("NameListItemDeleteClick");
	--DEFAULT_CHAT_FRAME:AddMessage("NameListItemDeleteClick index:"..self.index);
	--table.remove(LF2Settings.LootName,LF2Settings.LootNameKeys[self.index]);
	LF2Settings.LootName[LF2Settings.LootNameKeys[self.index]] = nil;
	table.remove(LF2Settings.LootNameKeys,self.index);
	LootFast2.Config.NameScrollFrameUpdate();
end
function LootFast2.Config.SetPriceThreshold(copper)
	copper = tonumber(copper);
	LF2Settings.PriceThresh = copper;
	if(copper == 0)then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot all items regardless of sell price.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootFast will loot items with sell price >= "..GetCoinTextureString(copper));
	end
end
function LootFast2.Config.SetPriceThresholdButtonClick()
	--DEFAULT_CHAT_FRAME:AddMessage("LootFast DEBUG: SetPriceThresholdButtonClick");
	local g = tonumber(LootFastConfig_SPGoldEB:GetText())
	local s = tonumber(LootFastConfig_SPSilverEB:GetText())
	local c = tonumber(LootFastConfig_SPCopperEB:GetText())

	if(g == nil)then
		g = 0;
	else
		g = g * 10000;
	end

	if(s == nil)then
		s = 0;
	else
		s = s * 100;
	end

	if(c == nil)then
		c = 0;
	end

	local m = g + s + c;

	--DEFAULT_CHAT_FRAME:AddMessage("LootFast DEBUG: "..GetCoinTextureString(m));
	LootFast2.Config.SetPriceThreshold(m);

	if(LF2Settings.PriceThresh == 0)then
		LootFastConfigSellPriceStatus:SetText("All Items");
	else
		LootFastConfigSellPriceStatus:SetText(GetCoinTextureString(LF2Settings.PriceThresh));
	end

	LootFastConfig_SPGoldEB:SetText("");
	LootFastConfig_SPSilverEB:SetText("");
	LootFastConfig_SPCopperEB:SetText("");
end
