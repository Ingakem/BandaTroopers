/datum/rto_support_action_template/halo/engineering
	parent_type = /datum/rto_support_action_template/halo
	shared_cooldown = 360 SECONDS
	personal_cooldown = 780 SECONDS
	category = "engineering"
	icon_state = "build"

/datum/rto_support_action_template/halo_toolbox_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_toolbox_drop"
	name = "HALO Toolbox Drop"
	description = "Drops engineering tools, supply kits and repair load-bearing gear."
	fire_support_path = /datum/fire_support/supply_drop/halo/toolbox
	icon_state = "tools"

/datum/rto_support_action_template/halo_toolbox_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_toolbox_drop"
	name = "Инженерный комплект"
	description = "Сбрасывает инженерные инструменты, расходники и снаряжение для полевого ремонта."
	fire_support_path = /datum/fire_support/supply_drop/halo/toolbox

/datum/rto_support_action_template/halo_fortification_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_fortification_drop"
	name = "HALO Fortification Drop"
	description = "Drops sandbags, plasteel, folding barricades and defensive mines."
	fire_support_path = /datum/fire_support/supply_drop/halo/fortification

/datum/rto_support_action_template/halo_breaching_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_breaching_drop"
	name = "HALO Breaching Drop"
	description = "Drops breaching charges, demolition blocks and entry tools."
	fire_support_path = /datum/fire_support/supply_drop/halo/breaching
	icon_state = "demo"

/datum/rto_support_action_template/halo_vehicle_service_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_vehicle_service_drop"
	name = "HALO Vehicle Service Drop"
	description = "Drops field repair and power supplies for HALO vehicle crews."
	fire_support_path = /datum/fire_support/supply_drop/halo/vehicle_service

/datum/rto_support_action_template/halo_field_service_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_field_service_drop"
	name = "Ящик полевого ремонта"
	description = "Сбрасывает полевой ремонтный набор."
	fire_support_path = /datum/fire_support/supply_drop/halo/field_service
	icon_state = "tools"
