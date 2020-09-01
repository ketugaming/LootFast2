
local timeStart = -1;

LootFast2={};

if LibStub then
	LootFast2.icon = LibStub("LibDBIcon-1.0");
end

function LootFast2.Load(self)
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("START_LOOT_ROLL");
	self:RegisterEvent("ITEM_PUSH");
	self:RegisterEvent('ADDON_LOADED');
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
end
function LootFast2.Update()
	if(timeStart >= 0) then
		if(GetTime() - timeStart >= LF2Settings.closeLoot) then
			CloseLoot();
			timeStart = -1;
		end
	end
end
function LootFast2.List(var)
	if(var == "Tog" or var == "tog") then
		--Toggle Enable
		LootFast2.Config.Toggle();
	end
	if(strsub(var, 1, 6) == "Close:" or strsub(var, 1, 6) == "close:") then
		--Auto Close, -1 Off, 0 Don't Open, Close after X seconds.
		LootFast2.Config.SetCloseOption(tonumber(strsub(var, 7)));
	end
	if(strsub(var, 1, 9) == "LootState" or strsub(var, 1, 9) == "lootstate" or strsub(var, 1, 9) == "lootState" or strsub(var, 1, 9) == "Lootstate") then
		if(strsub(var, 10) == "") then
			LootFast2.Config.SetLootState(LF2Settings.AllBut + 1);
		else
			LootFast2.Config.SetLootState(tonumber(strsub(var, 11)));
		end
	end
	if(var == "Reset" or var == "reset") then
		LootFast2.Config.Reset();
	end
	if(strsub(var, 1, 5) == "Name " or strsub(var, 1, 5) == "name ") then
		--Filter by Name
		local nam, num = strsplit(":", strsub(var, 6));
		LootFast2.Config.SetNameFilter(nam,num);
	end
	if(strsub(var, 1, 8) == "Quality " or strsub(var, 1, 8) == "quality ") then
		--Filter by Quality
		local qual, num = strsplit(":", strsub(var, 9));
		qual = tonumber(qual);
		num = tonumber(num);
		LootFast2.Config.SetQuality(qual,num);
	end
	if(var == "List" or var == "list") then
		if(LF2Settings.Enabled == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("LootFast is on");
		else
			DEFAULT_CHAT_FRAME:AddMessage("LootFast is off");
		end
		if(LF2Settings.closeLoot >= 0) then
			DEFAULT_CHAT_FRAME:AddMessage("LootFast will close the loot window after " .. LF2Settings.closeLoot .. " Seconds.");
		else
			DEFAULT_CHAT_FRAME:AddMessage("LootFast will not close the loot window.");
		end
		DEFAULT_CHAT_FRAME:AddMessage("Names specified:");
		for k in pairs(LF2Settings.LootName) do
			if(LF2Settings.LootName[k] >= 1) then
				DEFAULT_CHAT_FRAME:AddMessage(k .. ": " .. LF2Settings.LootName[k]);
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage("Qualities specified:");
		for k in pairs(LF2Settings.LootQual) do
			if(LF2Settings.LootQual[k] >= -1) then
				qual = k;
				if(qual == -1) then
					nam = "|cFF00ccffMoney|r";
				elseif(qual == 0) then
					nam = "|cff9d9d9dPoors|r";
				elseif(qual == 1) then
					nam = "|cffffffffCommons|r";
				elseif(qual == 2) then
					nam = "|cff1eff00Uncommons|r";
				elseif(qual == 3) then
					nam = "|cff0070ddRares|r";
				elseif(qual == 4) then
					nam = "|cffa335eeEpics|r";
				elseif(qual == 5) then
					nam = "|cffff8000Legendaries|r";
				elseif(qual == 6) then
					nam = "|cffe6cc80Artifact|r";
				end
				DEFAULT_CHAT_FRAME:AddMessage(nam .. ": " .. LF2Settings.LootQual[k]);
			end
		end
		--Sell Price
		local sp = "Sell Price Threshold: ";
		if(LF2Settings.PriceThresh ~= 0) then
			sp = sp..GetCoinTextureString(LF2Settings.PriceThresh);
		else
			sp = sp.."Loot All";
		end
		DEFAULT_CHAT_FRAME:AddMessage(sp);
	end
	if(var == "Config" or var == "config") then
		LootFast2.Config.Open();
	end
	if(strsub(var, 1, 2) == "SP" or strsub(var, 1, 2) == "sp" or strsub(var, 1, 2) == "Sp" or strsub(var, 1, 2) == "sP") then
		--ChatFrame1:AddMessage("LF2 DEBUG: SP Input: "..strsub(var, 3, 8));
		if(strsub(var, 3, 8) == "") then
			LootFast2.Config.SetPriceThreshold(0);
		else
			LootFast2.Config.SetPriceThreshold(strsub(var, 3, 8))
		end
	end
	if(var == "") then
		DEFAULT_CHAT_FRAME:AddMessage("LootFast2 Commands:");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF : lists commands");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Tog : toggles on/off");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Close:# : sets close time: -1 means don't close, 0 means close immediately (never opens) and greater than 0 is the number of seconds to leave the loot window open");
		DEFAULT_CHAT_FRAME:AddMessage("For the following commands, the # sets the greediness of the looting. 0: do not auto loot, 1: auto loot, 2: auto greed on rolls, 3: auto accept BoP items");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF LootState:# : sets the loot state (0 is default). if no number is given, will cycle through possible states");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Name itemname:# : adds the item to the loot filter (full item name required. do not include brackets)");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Quality #:# : sets the quality level represented by the first # to the loot level given by the second (-1:money 0:grey, 1:white, 2:green, 3:blue, 4:purple, 5:orange)");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF SP # : sets the amount of copper the item must sell for before lootting. Sell price filtering comes before other filters.");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Reset : clears all stored data.");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF List : lists current loot filters.");
		DEFAULT_CHAT_FRAME:AddMessage("  /LF Config : Show Config GUI.");
	end
end
function LootFast2.InitSettings()
	LF2Settings={
		MinimapPos = 45,
		Enabled = 1,
		closeLoot = 0,
		LootName = {},
		AllBut = 0,
		LootQual = {1, 1, 1, 1, 1, 1}, --Index 6 Artifact, Always Loot!
		LootNameKeys = {},
		db = {profile={minimap={hide=false}}}, --New Var for DBIcon integration, also used for builtin minimap button if no Lib-DBIcon.
		PriceThresh = 0 --Price Threshhold.  0 = Loot Everything.
	};
	LF2Settings.LootQual[0] = 1;
	LF2Settings.LootQual[-1] = 1;
end
function LootFast2.OnEvent(event,...)
	if(event == "ADDON_LOADED") then
		local arg1 = ...;
		if(arg1 == "LootFast2") then
			SlashCmdList["LOOTFASTCMDLIST"] = LootFast2.List;
			SLASH_LOOTFASTCMDLIST1 = "/LootFast";
			SLASH_LOOTFASTCMDLIST2 = "/LF";
			SLASH_LOOTFASTCMDLIST3 = "/lf";
			SLASH_LOOTFASTCMDLIST4 = "/Lf";
			SLASH_LOOTFASTCMDLIST5 = "/lootfast";
			SLASH_LOOTFASTCMDLIST6 = "/Lootfast";
			SLASH_LOOTFASTCMDLIST7 = "/lootFast";

			if(not LF2Settings) then
				--DEFAULT_CHAT_FRAME:AddMessage("LootFast: InitSettings!"); --DEBUG
				--DEFAULT_CHAT_FRAME:AddMessage("LootFast: "..tostring(LF2Settings)); --DEBUG
				LootFast2.InitSettings();
			end

			if(LF2Settings.LootQual[-1] == nil) then
				LF2Settings.LootQual[-1] = 1;
			end
			if(LF2Settings.LootQual[6] == nil) then
				--Upgrade Settings v7.1.0.01132017.
				LF2Settings.LootQual[6] = 1; --Ensure we always loot artifacts!!
			end

			if(LF2Settings.db == nil) then
				--Upgrade Settings v7.1.5.01192017
				LF2Settings.db = {profile={minimap={hide=false}}};
				LF2Settings.MinimapEnabled = nil;
			end

			if(LF2Settings.PriceThresh == nil) then
				--Upgrade Settings v7.2.0.04112017
				LF2Settings.PriceThresh = 0;
			end

			LootFast2.InitLDB();
			LootFast2.Config.InitConfigDropDowns();
		end
	end
	if(event == "PLAYER_ENTERING_WORLD") then
		--Setup UI Here.
		if not LF2Settings.db.profile.minimap.hide then
			if not LootFast2.icon then
				LootFast2.Minimap.Reposition();
			end
		end
	end
	if ( event == "LOOT_OPENED" ) then
		if( LF2Settings.Enabled == 1) then
			local i = 1;
			local lootIcon, lootName, lootQuantity,nCurr, rarity, locked, isQuest, questId, isActive = GetLootSlotInfo(i);
			while(lootIcon ~= nil) do
				-- ChatFrame1:AddMessage(#LF2Settings.LootQual);
				-- ChatFrame1:AddMessage("name:"..lootName);
				-- ChatFrame1:AddMessage("quantity:" .. tostring(lootQuantity));
				-- ChatFrame1:AddMessage("curr:" .. tostring(nCurr));
				-- ChatFrame1:AddMessage("rareity:" .. tostring(rarity));
				-- ChatFrame1:AddMessage("LootQual: " .. tostring(LF2Settings.LootQual[rarity]));
				-- ChatFrame1:AddMessage(lootName .. ", " .. lootQuantity .. ", " .. rarity .. ", " .. tostring(LF2Settings.LootQual[rarity]));
				-- ChatFrame1:AddMessage(strsub(icon, 1, 29) .. " == " .. "Interface\\Icons\\INV_Misc_Coin");
				if(strsub(lootIcon, 1, 29) == "Interface\\Icons\\INV_Misc_Coin") then
					--Loot Money
					if(LF2Settings.LootQual[-1] == nil) then
						LF2Settings.LootQual[-1] = 1;
					end
					if(LF2Settings.LootQual[-1] > 0) then
						LootSlot(i);
					end
				else
					--Loot Items
					local itemlink = GetLootSlotLink(i);
					local priceok = false;
					--Check Sell Price
					if(itemlink ~= nil)then
						-- ChatFrame1:AddMessage("LF2 DEBUG: Item Link: "..itemlink);
						local price = select(11, GetItemInfo(itemlink));
						-- ChatFrame1:AddMessage("LF2 DEBUG: Item Price: "..GetCoinTextureString(price));
						if(price == 0 or price == nil) then
							priceok = true;
							-- ChatFrame1:AddMessage("LF2 DEBUG: "..itemlink.." No Sell Price");
						elseif(price >= LF2Settings.PriceThresh)then
							priceok = true;
						else
							priceok = false;
							-- ChatFrame1:AddMessage("LF2 DEBUG: "..itemlink.." Sell Price did not meet threshhold.");
						end
					else
						priceok = true;
					end
					--Check Quality
					if(priceok) then
						-- ChatFrame1:AddMessage("LF2 DEBUG: "..tostring(LF2Settings.LootQual[rarity]));
						-- ChatFrame1:AddMessage("LF2 DEBUG: "..tostring(LF2Settings.LootName[name]));
						-- ChatFrame1:AddMessage("LF2 DEBUG: "..tostring(LF2Settings.AllBut));
						if(
							(LF2Settings.LootQual[rarity] ~= nil and LF2Settings.LootQual[rarity] >= 1) or 
						((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 1) and 
						LF2Settings.AllBut == 0) or 
						(not ((LF2Settings.LootName[name] ~= nil and 
						LF2Settings.LootName[name] >= 1)) and 
						LF2Settings.AllBut >= 1)) then
							LootSlot(i);
							if(LF2Settings.LootQual[rarity] >= 3 or ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 3) and LF2Settings.AllBut == 0) or (not ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 1)) and LF2Settings.AllBut >= 3)) then
								ConfirmLootSlot(i);
							end
						end
					end
				end

				i = i + 1;
				lootIcon, lootName, lootQuantity,nCurr, rarity, locked, isQuest, questId, isActive = GetLootSlotInfo(i);
			end
			if(LF2Settings.closeLoot <= 0) then
				if(LF2Settings.closeLoot == 0) then
					CloseLoot();
				end
				timeStart = -1;
			else
				timeStart = GetTime();
			end
		end
	end
	if (event == "START_LOOT_ROLL") then
		if( LF2Settings.Enabled == 1) then
			local id = ...;
			local icon, name, quan, rare = GetLootRollItemInfo(id);
			--ChatFrame1:AddMessage(name .. ", " .. quan .. ", " .. rare .. ", " .. LF2Settings.LootQual[rare]);
			if(LF2Settings.LootQual[rare] >= 2 or ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 2) and LF2Settings.AllBut == 0) or (not ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 1)) and LF2Settings.AllBut >= 2)) then
					RollOnLoot(id, 2);
					if(LF2Settings.LootQual[rare] >= 3 or ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 3) and LF2Settings.AllBut == 0) or (not ((LF2Settings.LootName[name] ~= nil and LF2Settings.LootName[name] >= 1)) and LF2Settings.AllBut >= 3)) then
						ConfirmLootRoll(id, 2);
					end
			end
		end
	end
	if (event == "ITEM_PUSH") then
		if( LF2Settings.Enabled == 1) then
			bag = ...;
			local i = 1;
			--local icon, name, quan, rare = GetLootSlotInfo(i);
			--DeleteCursorItem();
		end
	end
end
function LootFast2.ButtonTips(button)
	if(button == "LootFast2_MinimapButton")then
		GameTooltip:SetOwner(LootFast2_MinimapButton);
		GameTooltip:SetText("LootFast2", nil, nil, nil, nil, 1);
		GameTooltip:AddLine("|cFFFFFFFFLeft Click:|r Toggle LootFast");
		GameTooltip:AddLine("|cFFFFFFFFRight Click:|r Open Options");
	end
	GameTooltip:Show();
end
function LootFast2.InitLDB()
	local LDB = LibStub and LibStub("LibDataBroker-1.1", true)

	if (LDB) then
		local ldbButton = LDB:NewDataObject("LootFast2", {
			type = "launcher",
			text = "LootFast2",
			label = "LootFast2",
			icon = "Interface\\Icons\\inv_misc_coin_01",
			OnClick = function(button, msg)
				if not UnitAffectingCombat("player") then
					if msg == "RightButton" then
						LootFast2.Config.Open();
					elseif msg == "LeftButton" then
						--Toggle LF Enabled.
						LootFast2.Config.Toggle();
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("|cFFEE0000LootFast2|r: Combat lockdown restriction. Leave combat and try again.")
				end
			end,
		})

		if LootFast2.icon then
			LootFast2_MinimapButton:Hide();
			LootFast2.icon:Register("LootFast2", ldbButton, LF2Settings.db.profile.minimap)
		end

		if ldbButton then
			function ldbButton:OnTooltipShow()
				self:AddLine("LootFast2")
				self:AddLine("|cFFFFFFFFLeft Click:|r Toggle LootFast", 1, 1, 1)
				self:AddLine("|cFFFFFFFFRight Click:|r Open Options", 1, 1, 1)
			end
		end
	end
end
