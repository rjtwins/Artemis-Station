/proc/size_percent( var/size = 0, var/max_size = 0 )
	if( !size )	return
	if( !max_size )	return

	return round( 100*( size/max_size ))

/obj/item/weapon/shard/supermatter
	name = "supermatter shard"
	desc = "A shard of supermatter. Incredibly dangerous, though not large enough to go critical."
	force = 10.0
	throwforce = 20.0
	icon = 'icons/obj/supermatter_artemis.dmi'
	icon_state = "supermattersmall"
	w_class = 2
	flags = CONDUCT

	var/smlevel = 1
	color = SM_DEFAULT_COLOR
	var/size = 1
	var/max_size = 100

/obj/item/weapon/shard/supermatter/New(var/loc, var/level = 1, var/set_size = 0)
	..()

	if( level > MAX_SUPERMATTER_LEVEL )
		level = MAX_SUPERMATTER_LEVEL
	else if( level < MIN_SUPERMATTER_LEVEL )
		level = MIN_SUPERMATTER_LEVEL

	smlevel = level
	color = getSMVar( smlevel, "color" )

	if( !set_size )
		size += rand(0, 10)
	else
		size = set_size

	update_icon()

/obj/item/weapon/shard/supermatter/update_icon()
	color = getSMVar( smlevel, "color" )
	name = getSMVar( smlevel, "color_name" ) + " " + initial(name)

	//set_light( light_range, light_power, light_color )

	if( src.size <= 34 )
		icon_state = "supermattersmall"
		src.pixel_x = rand(-12, 12)
		src.pixel_y = rand(-12, 12)
	else if( src.size <= 67 )
		icon_state = "supermattermedium"
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)
	else
		icon_state = "supermatterlarge"
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)

/obj/item/weapon/shard/supermatter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype( W, /obj/item/weapon ))
		if( W.force >= 5 )
			src.shatter()
	..()

/obj/item/weapon/shard/supermatter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/shard/supermatter/attack_hand(var/mob/user)
	if( !user.smSafeCheck() )
		user << pick( "<span class='alert'>You think twice before touching that without protection.</span>",
					  "<span class='alert'>You don't want to touch that without some protection.</span>",
					  "<span class='alert'>You probably should get something else to pick that up.</span>",
					  "<span class='alert'>You aren't sure that's a good idea.</span>",
					  "<span class='alert'>You aren't in the mood to get vaporized today.</span>",
					  "<span class='alert'>You really don't feel like frying your hand off.</span>",
					  "<span class='alert'>You assume that's a bad idea.</span>" )
		return

	..()

/obj/item/weapon/shard/supermatter/proc/feed( var/datum/gas_mixture/gas )
	size += gas.gases["plasma"][MOLES]

	if( size > max_size )
		shatter()

	qdel( gas )

	update_icon()

/obj/item/weapon/shard/supermatter/proc/shatter()
	if( size > 100 )
		src.visible_message( "The supermatter shard grows into a full-sized supermatter crystal!" )
		var/obj/machinery/power/supermatter_shard/supermatter/S = new /obj/machinery/power/supermatter_shard/supermatter( get_turf( src ))
		S.smlevel = smlevel
		S.update_icon()
	else if( size >= 10 )
		src.visible_message( "The supermatter shard shatters into smaller fragments!" )
		for( size, size >= 10, size -= 10 )
			new /obj/item/weapon/shard/supermatter( get_turf( src ), smlevel)
	else
		src.visible_message( "The supermatter shard shatters into dust!" )

	playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
	qdel( src )

