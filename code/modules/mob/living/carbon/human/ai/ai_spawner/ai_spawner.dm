/// Types of click intercepts used by /datum/game_master variable current_click_intercept_action
#define SPAWN_CLICK_INTERCEPT_ACTION "spawn_click_intercept_action"

//GLOBAL_LIST_EMPTY(human_ai_equipment_presets)

/datum/human_ai_spawner_menu
	var/static/list/lazy_ui_data = list()
	var/update_preset_list_now = FALSE
	var/static/list/super_silly_pref_save = list()
	var/viewing_faction
	var/current_path
	var/spawn_ai = TRUE
	var/paradrop = FALSE
	var/desc = TRUE
	var/species = SPECIES_HUMAN
	var/current_click_intercept_action
	var/spawn_click_intercept = FALSE
	var/selected_equipment
	var/selected_faction
	var/outfit = FALSE
	var/zombie_outer_wear = FALSE
	var/zombie_outer_wear_chance = 40
	var/auto_clean = FALSE
	var/zombie_delimb_multi = 1
	var/mob/living/carbon/human/species_dummy


/datum/human_ai_spawner_menu/New()
	usr.client.click_intercept = src
	if(!length(lazy_ui_data))
		for(var/datum/human_ai_equipment_preset/preset_type as anything in subtypesof(/datum/human_ai_equipment_preset))
			if(!preset_type::name || !preset_type::path)
				continue
			var/datum/human_ai_equipment_preset/preset_obj = new preset_type()
			//GLOB.human_ai_equipment_presets["[preset_type]"] = preset_obj
			add_preset(preset_obj.path, preset_obj.desc, update_ui = FALSE)


/datum/human_ai_spawner_menu/ui_close(mob/user)
	. = ..()

	var/client/user_client = user.client
	if(user_client?.click_intercept == src)
		user_client.click_intercept = null
		spawn_click_intercept = FALSE

/datum/human_ai_spawner_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanAISpawner")
		ui.open()

/datum/human_ai_spawner_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_ai_spawner_menu/proc/add_preset(datum/equipment_preset/preset, desc, update_ui = FALSE)
	if(!preset)
		return
	if(!lazy_ui_data[preset.faction])
		lazy_ui_data[preset.faction] = list()
	if(!species_dummy)
		species_dummy = new() //things have learned to walk that ought to crawl
		GLOB.peak_humans--
	else
		species_dummy.set_species("Human")

	preset = GLOB.gear_path_presets_list[preset.type]
	preset.load_race(species_dummy)//great holes are secretly dug where earths pores ought to suffice
	var/species_of_this_preset = species_dummy.get_species()
	//check for dupes
	var/list/faction_list = lazy_ui_data[preset::faction]
	for(var/list/preset_data in faction_list)
		if(preset_data["path"] == preset.type)
			if(usr)
				to_chat(usr, SPAN_WARNING("You can't add two of [preset.name]!"))
			else
				log_debug("A duplicate equipment preset given to human_ai_spawner_menu's internal preset dictionary. Path:[preset.type] ")
			return
	lazy_ui_data[preset::faction] += list(list(
		"name" = preset.name,
		"description" = "[desc ? desc : "Added Preset."]",
		"path" = preset.type,
		"faction" = preset.faction,
		"selected_equipment" = "Full Equipment",
		"species" = species_of_this_preset
	))

	if(update_ui)
		update_preset_list_now = TRUE

/datum/human_ai_spawner_menu/ui_data(mob/user)
	var/list/data = list()
	var/datum/equipment_preset/gotten_path = text2path(current_path)
	var/list/faction_list = lazy_ui_data[gotten_path?.faction] //runtime o'clock
	for(var/list/preset_data in faction_list)
		if(preset_data["path"] == gotten_path)
			data["selected_faction"] = preset_data["faction"] //update the dropdown to the value the faction is in our big list
			data["selected_equipment"] = preset_data["selected_equipment"]
			data["species_selected"] = preset_data["species"]

			//
			selected_equipment = preset_data["selected_equipment"]
			selected_faction = preset_data["selected_faction"]
			species = preset_data["species_selected"]

			break
	data["viewing_faction"] = viewing_faction
	data["spawn_ai"] = spawn_ai
	data["paradrop"] = paradrop
	data["desc"] = desc
	data["outfit"] = outfit
	data["spawn_click_intercept"] = spawn_click_intercept
	data["zombie_outer_wear"] = zombie_outer_wear
	data["zombie_outer_wear_chance"] = zombie_outer_wear_chance
	data["autoClean"] = auto_clean
	data["zombie_delimb_multi"] = zombie_delimb_multi
	if(update_preset_list_now)
		update_preset_list_now = FALSE
		src.update_static_data_for_all_viewers()

	return data

/datum/human_ai_spawner_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["presets"] = lazy_ui_data
	//data["defense_presets"]
	data["selectable_factions"] = FACTION_LIST_HUMANOID + "Normal Hive"
	data["equipment_settings"] = list("Full Equipment", "No Weapons", "Birthday Suit")
	data["species_settings"] = SYNTH_TYPES + SPECIES_HUMAN + SPECIES_ZOMBIE
	return data

/datum/human_ai_spawner_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_selected_faction")
			if(!params["path"])
				return
			if(!params["selected_faction"])
				return
			var/datum/human_ai_equipment_preset/gotten_path = text2path(params["path"])
			if(!gotten_path)
				return
			var/list/faction_list = lazy_ui_data[gotten_path.faction]
			for(var/list/preset_data in faction_list)
				if(preset_data["path"] == gotten_path)
					preset_data["faction"] = params["selected_faction"]
					selected_faction = params["selected_faction"]
					return TRUE
		if("remember_path")
			current_path = params["path"]
			return TRUE
		if("save")
			var/file_name = "hAi_dictionary_[usr.ckey]-[length(lazy_ui_data)].txt"

			var/file = file("tmp/[file_name]")

			file << json_encode(lazy_ui_data)

			usr << ftp(file, file_name)
		if("human_spawn_ai_toggle")
			spawn_ai = !spawn_ai
		if("paradrop_toggle")
			paradrop = !paradrop
		if("hide_desc")
			desc = !desc
		if("delete_preset")
			var/datum/equipment_preset/preset_path = text2path(params["path"])
			var/faction_i = 0
			for(var/faction_name in lazy_ui_data)
				faction_i++ //i feel like there is a better way to do this
				if(faction_name == preset_path.faction)
					var/list/faction_list = lazy_ui_data[faction_name]
					var/preset_i = 0
					for(var/list/preset_data in faction_list)
						preset_i++ //sometimes it just works
						if(preset_data["path"] == preset_path)
							update_preset_list_now = TRUE
							faction_list.Cut(preset_i, preset_i+1)
							// remove entire faction if there are no more presets in it
							if(!length(faction_list))
								lazy_ui_data.Cut(faction_i, faction_i+1)
							return TRUE
		if("outfit")
			outfit = !outfit
		if("set_selected_species")
			species = params["species_selected"]
			var/datum/equipment_preset/gotten_path = text2path(current_path)
			if(!gotten_path)
				return
			var/list/faction_list = lazy_ui_data[gotten_path.faction]
			for(var/list/preset_data in faction_list)
				if(preset_data["path"] == gotten_path)
					preset_data["species"] = params["species_selected"]
					species = params["species_selected"]
					return TRUE
		if("set_selected_equipment")
			var/datum/human_ai_equipment_preset/gotten_path = text2path(params["path"])
			if(!gotten_path)
				return

			var/mob/living/carbon/human/ai_human = new()
			ai_human.AddComponent(/datum/component/human_ai)

			arm_equipment(ai_human, gotten_path::path, TRUE)

			ai_human.face_dir(ui.user.dir)
			ai_human.forceMove(get_turf(ui.user))

			ai_human.get_ai_brain().appraise_inventory(armor = TRUE)
			return TRUE

/client/proc/open_human_ai_spawner_panel()
	set name = "Create Human AI"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	if(human_spawn_menu)
		human_spawn_menu.tgui_interact(mob)
		return

	human_spawn_menu = new /datum/human_ai_spawner_menu(src)
	human_spawn_menu.tgui_interact(mob)


/datum/human_ai_equipment_preset
	/// The GM-visible name of the equipment preset
	var/name = ""
	/// A short description of what the preset does. Including important equipment or usecases is a good idea
	var/desc = ""
	/// What faction the preset is related to
	var/faction = FACTION_NEUTRAL
	/// The /datum/equipment_preset that this preset should create
	var/path

#undef SPAWN_CLICK_INTERCEPT_ACTION
