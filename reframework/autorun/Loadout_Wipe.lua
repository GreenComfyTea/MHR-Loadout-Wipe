local status = "Waiting..."
local empty_loadout_name = "― ― ― ― ―";

local mod_name = "Loadout Wipe";

local equip_data_manager_type = sdk.find_type_definition("snow.data.EquipDataManager");
local get_player_equip_my_set_list_method = equip_data_manager_type:get_method("get_PlEquipMySetList");
local delete_equip_my_set_method = equip_data_manager_type:get_method("deleteEquipMySet");

local equip_my_set_data_type = sdk.find_type_definition("snow.equip.PlEquipMySetData");
local get_name_method = equip_my_set_data_type:get_method("get_Name");

local system_array_type_def = sdk.find_type_definition("System.Array");
local length_method = system_array_type_def:get_method("get_Length");
local get_value_method = system_array_type_def:get_method("GetValue(System.Int32)");

local function wipe_loadouts()
	local equip_data_manager = sdk.get_managed_singleton("snow.data.EquipDataManager");

	local loadout_array = get_player_equip_my_set_list_method:call(equip_data_manager);
	local loadout_array_length = length_method:call(loadout_array);

	local removed_count = 0;
	for i = 0, loadout_array_length - 1 do
		local loadout = get_value_method:call(loadout_array, i);
		if loadout == nil then
			goto continue
		end

		local loadout_name = get_name_method:call(loadout);
		if loadout_name == nil then
			goto continue
		end

		if loadout_name ~= empty_loadout_name then
			delete_equip_my_set_method:call(equip_data_manager, i);
			removed_count = removed_count + 1;
		end

		::continue::
	end

	status = "Wiped " .. tostring(removed_count) .. " loadouts.";
end

re.on_draw_ui(function()
	if imgui.button("Wipe Loadouts") then
		pcall(wipe_loadouts);
	end

	imgui.same_line();
	imgui.text("Status: " .. tostring(status));
end);

local mod_menu_api_package_name = "ModOptionsMenu.ModMenuApi";
local mod_menu = nil;

local native_UI = nil;

local function is_module_available(name)
	if package.loaded[name] then
		return true;
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name);

			if type(loader) == 'function' then
				package.preload[name] = loader;
				return true;
			end
		end

		return false;
	end
end

local function draw_native()
	local changed = false;
	local config_changed = false;
	local index = 1; 

	mod_menu.Label("Created by: <COL RED>GreenComfyTea</COL>", "",
		"Donate: <COL RED>https://streamelements.com/greencomfytea/tip</COL>\nBuy me a tea: <COL RED>https://ko-fi.com/greencomfytea</COL>\nSometimes I stream: <COL RED>twitch.tv/greencomfytea</COL>");
		mod_menu.Label("Version: <COL RED>2.0</COL>", "",
		"Donate: <COL RED>https://streamelements.com/greencomfytea/tip</COL>\nBuy me a tea: <COL RED>https://ko-fi.com/greencomfytea</COL>\nSometimes I stream: <COL RED>twitch.tv/greencomfytea</COL>");



	mod_menu.Header("Loadout Wipe");

	if mod_menu.Button("<COL YEL>Wipe Loadouts</COL>", "", false, "Wipe all your equipment loadouts.\nMake a back of your save file before proceeding.") then
		mod_menu.PromptYN("Make sure to backup your save file. Proceed?", function(result)
			if result == true then
				pcall(wipe_loadouts);
				mod_menu.Repaint();
			end
		end);
	end

	mod_menu.Label("Status", "", "Status: " .. tostring(status));
end

local function on_reset_all_settings()
end

if is_module_available(mod_menu_api_package_name) then
	mod_menu = require(mod_menu_api_package_name);

	if mod_menu == nil then
		log.info("[" .. mod_name .. "] No mod_menu_api API package found. You may need to download it or something.");
	else
		native_UI = mod_menu.OnMenu(
			mod_name,
			"Wipe all your equipment loadouts.",
			draw_native
		);
		
		native_UI.OnResetAllSettings = on_reset_all_settings;
	end
end