d--------------------------------------------------------
-- Minetest :: Interactive Physics (physics)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2019-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/physics/init.lua
--------------------------------------------------------

--local S1, S1_ = Stopwatch( "physics" )

local config = minetest.load_config( )

local materials = { }
local motion_sounds = {
	diving = "default_water_footstep",
	floating = "default_water_footstep",
	hitting_stone = "default_hard_footstep",
	hitting_dirt = "default_dirt_footstep",
	hitting_sand = "default_sand_footstep",
	hitting_gravel = "default_gravel_footstep",
	hitting_wood = "default_wood_footstep",
	hitting_grass = "default_grass_footstep",
	hitting_glass = "default_glass_footstep",
	hitting_metal = "default_metal_foostep",
	hitting_snow = "default_snow_footstep",
}

--------------------

local min = math.min
local max = math.max
local abs = math.abs

local function ramp( f, cur_v, max_v )
       	-- min function handles NaN, but let's err on the side of caution
        return max_v == 0 and f or f * min( 1, cur_v / max_v )
end

local function get_facing_axis( pos1, pos2 )
        local x_abs = math.abs( pos1.x - pos2.x )
       	local y_abs = math.abs( pos1.y - pos2.y )
        local z_abs = math.abs( pos1.z - pos2.z )
        if x_abs < y_abs and z_abs < y_abs then
                return "y"
        elseif x_abs < z_abs and y_abs < z_abs then
                return "z"
        elseif z_abs < x_abs and y_abs < x_abs then
                return "x"
        end
        return nil
end

--------------------

local function import_materials( )
	local raw_materials = dofile( minetest.get_modpath( "physics" ) .. "/materials.lua" )

	for k, v in pairs( raw_materials ) do
		-- we need to do this with a secondary table since pairs function
		-- does not support safe insertions during traversal
		local group = string.match( k, "^group:([a-z0-9_]+)$" )
		if group then
			for name, ndef in pairs( minetest.registered_nodes ) do
				if ndef.groups[ group ] and not raw_materials[ name ] then
					materials[ name ] = table.copy( v )
				end
			end
		else
			materials[ k ] = v
		end
	end
end

--------------------

local function open_global_editor( player_name )
	local get_formspec = function ( )
		local formspec = 
			"size[12,5]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			"label[0.0,0.0;Physics Properties]" ..
			"box[0.0,0.6;3.8,0.1;#555555]" ..
			"box[4.0,0.6;7.8,0.1;#555555]" ..

			"label[0.0,1.1;World Gravity:]" ..
			"button[2.0,1.2;0.7,0.3;gravity_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;gravity_add;>]" ..
			string.format( "label[2.7,1.1;%d]", config.world_gravity ) ..

			"label[0.0,2.1;Air Density:]" ..
			"button[2.0,2.2;0.7,0.3;density_sub;<]" ..
			"box[2.5,2.0;0.7,0.6;#000000]" ..
			"button[3.2,2.2;0.7,0.3;density_add;>]" ..
			string.format( "label[2.7,2.1;%0.1f]", config.air_density ) ..

			"label[0.0,3.1;Air Viscosity:]" ..
			"button[2.0,3.2;0.7,0.3;viscosity_sub;<]" ..
			"box[2.5,3.0;0.7,0.6;#000000]" ..
			"button[3.2,3.2;0.7,0.3;viscosity_add;>]" ..
			string.format( "label[2.7,3.1;%0.1f]", config.air_viscosity ) ..


			"label[4.0,1.1;Solid Friction:]" ..
			"button[6.0,1.2;0.7,0.3;sol_friction_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;sol_friction_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", config.default_solid.friction ) ..

			"label[4.0,2.1;Solid Elasticity:]" ..
			"button[6.0,2.2;0.7,0.3;sol_elasticity_sub;<]" ..
			"box[6.5,2.0;0.7,0.6;#000000]" ..
			"button[7.2,2.2;0.7,0.3;sol_elasticity_add;>]" ..
			string.format( "label[6.7,2.1;%0.1f]", config.default_solid.elasticity ) ..


			"label[8.0,1.1;Liquid Viscosity:]" ..
			"button[10.0,1.2;0.7,0.3;liq_viscosity_sub;<]" ..
			"box[10.5,1.0;0.7,0.6;#000000]" ..
			"button[11.2,1.2;0.7,0.3;liq_viscosity_add;>]" ..
			string.format( "label[10.7,1.1;%0.1f]", config.default_liquid.viscosity ) ..

			"label[8.0,2.1;Liquid Density:]" ..
			"button[10.0,2.2;0.7,0.3;liq_density_sub;<]" ..
			"box[10.5,2.0;0.7,0.6;#000000]" ..
			"button[11.2,2.2;0.7,0.3;liq_density_add;>]" ..
			string.format( "label[10.7,2.1;%0.1f]", config.default_liquid.density ) ..


			"box[0.0,4.0;3.8,0.1;#555555]" ..
			"box[4.0,0.6;7.8,0.1;#555555]" ..
			"button_exit[10.0,4.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.close then return end

		if fields.gravity_sub then
			config.world_gravity = math.max( 0.0, config.world_gravity - 1 )
		elseif fields.gravity_add then
			config.world_gravity = math.min( 10, config.world_gravity + 1 )
		elseif fields.density_sub then
			config.air_density = math.max( 0.0, config.air_density - 0.1 )
		elseif fields.density_add then
			config.air_density = math.min( 1.0, config.air_density + 0.1 )
		elseif fields.viscosity_sub then
			config.air_viscosity = math.max( 0.0, config.air_viscosity - 0.1 )
		elseif fields.viscosity_add then
			config.air_viscosity = math.min( 1.0, config.air_viscosity + 0.1 )
		end

		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

local function open_solid_editor( player_name, node_name )
	local def = minetest.registered_items[ node_name ]
	local props = materials[ node_name ] or { friction = config.default_solid.friction, elasticity = config.default_solid.elasticity }

	local get_formspec = function ( )
		local formspec = 
			"size[8,4]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			string.format( "label[0.0,0.0;Physics Properties (%s)]", materials[ node_name ] and "Override" or "Default" ) ..
			"box[0.0,0.6;7.8,0.1;#555555]" ..

			"label[0.0,1.1;Friction:]" ..
			"button[2.0,1.2;0.7,0.3;friction_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;friction_add;>]" ..
			string.format( "label[2.7,1.1;%0.1f]", props.friction ) ..

			"label[4.0,1.1;Elasticity:]" ..
			"button[6.0,1.2;0.7,0.3;elasticity_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;elasticity_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", props.elasticity ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "label[0.0,3.4;%s]", def.description ) ..
			"button[4.0,3.5;2,0.3;reset;Reset]" ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.close then return end

		if fields.reset then
			materials[ node_name ] = nil
		else
			if fields.friction_sub then
				props.friction = math.max( 0.0, props.friction - 0.1 )
			elseif fields.friction_add then
				props.friction = math.min( 1.0, props.friction + 0.1 )
			elseif fields.elasticity_sub then
				props.elasticity = math.max( 0.0, props.elasticity - 0.1 )
			elseif fields.elasticity_add then
				props.elasticity = math.min( 1.0, props.elasticity + 0.1 )
			end

			if not materials[ node_name ] then
				materials[ node_name ] = props
			end
		end

		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

local function open_liquid_editor( player_name, node_name )
	local def = minetest.registered_items[ node_name ]
	local props = materials[ node_name ] or { viscosity = config.default_liquid.viscosity, density = config.default_liquid.density }

	local get_formspec = function ( )
		local formspec = 
			"size[8,4]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			string.format( "label[0.0,0.0;Physics Properties (%s)]", materials[ node_name ] and "Override" or "Default" ) ..
			"box[0.0,0.6;7.8,0.1;#555555]" ..

			"label[0.0,1.1;Viscosity:]" ..
			"button[2.0,1.2;0.7,0.3;viscosity_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;viscosity_add;>]" ..
			string.format( "label[2.7,1.1;%0.1f]", props.viscosity ) ..

			"label[4.0,1.1;Density:]" ..
			"button[6.0,1.2;0.7,0.3;density_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;density_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", props.density ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "label[0.0,3.4;%s]", def.description ) ..
			"button_exit[4.0,3.5;2,0.3;reset;Reset]" ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.close then return end

		if fields.reset then
			materials[ node_name ] = nil
		else
			if fields.viscosity_sub then
				props.viscosity = math.max( 0.0, props.viscosity - 0.1 )
			elseif fields.viscosity_add then
				props.viscosity = math.min( 1.0, props.viscosity + 0.1 )
			elseif fields.density_sub then
				props.density = math.max( 0.01, props.density - 0.1 )
			elseif fields.density_add then
				props.density = math.min( 1.0, props.density + 0.1 )
			else
				return
			end
		end

		if not materials[ node_name ] then
			materials[ node_name ] = props
		end

		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

local function open_entity_editor( player_name, entity )
	local props = entity.physics

	local get_formspec = function ( )
		local formspec = 
			"size[8,4]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			"label[0.0,0.0;Physics Properties]" ..
			"box[0.0,0.6;7.8,0.1;#555555]" ..

			"label[0.0,1.1;Friction:]" ..
			"button[2.0,1.2;0.7,0.3;friction_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;friction_add;>]" ..
			string.format( "label[2.7,1.1;%0.1f]", props.friction ) ..

			"label[0.0,2.1;Density:]" ..
			"button[2.0,2.2;0.7,0.3;density_sub;<]" ..
			"box[2.5,2.0;0.7,0.6;#000000]" ..
			"button[3.2,2.2;0.7,0.3;density_add;>]" ..
			string.format( "label[2.7,2.1;%0.1f]", props.density ) ..

			"label[4.0,1.1;Elasticity:]" ..
			"button[6.0,1.2;0.7,0.3;elasticity_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;elasticity_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", props.elasticity ) ..

			"label[4.0,2.1;Resistance:]" ..
			"button[6.0,2.2;0.7,0.3;resistance_sub;<]" ..
			"box[6.5,2.0;0.7,0.6;#000000]" ..
			"button[7.2,2.2;0.7,0.3;resistance_add;>]" ..
			string.format( "label[6.7,2.1;%0.1f]", props.resistance ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "label[0.0,3.4;%s (entity)]", entity.name ) ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"

		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.close then return end

		if fields.friction_sub then
			props.friction = math.max( 0.0, props.friction - 0.1 )
		elseif fields.friction_add then
			props.friction = math.min( 1.0, props.friction + 0.1 )
		elseif fields.density_sub then
			props.density = math.max( 0.0, props.density - 0.1 )
		elseif fields.density_add then
			props.density = math.min( 1.0, props.density + 0.1 )
		elseif fields.elasticity_sub then
			props.elasticity = math.max( 0.0, props.elasticity - 0.1 )
		elseif fields.elasticity_add then
			props.elasticity = math.min( 1.0, props.elasticity + 0.1 )
		elseif fields.resistance_sub then
			props.resistance = math.max( 0.0, props.resistance - 0.1 )
		elseif fields.resistance_add then
			props.resistance = math.min( 1.0, props.resistance + 0.1 )
		end

		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

--------------------

minetest.register_tool( "physics:physics_wand", {
	description = "Physics Wand",
	range = 5,
	inventory_image = "physics_wand.png",
	groups = { not_in_creative_inventory = 1 },
	liquids_pointable = true,

	on_use = function ( itemstack, clicker, pointed_thing )
		local player_name = clicker:get_player_name( )
		if pointed_thing.type == "object" then
			local this = pointed_thing.ref:get_luaentity( )
			open_entity_editor( player_name, this )
		elseif pointed_thing.type == "node" then
			local node_name = minetest.get_node( pointed_thing.under ).name
			local def = minetest.registered_items[ node_name ]
			if def.groups.liquid then
				open_liquid_editor( player_name, node_name )
			else
				open_solid_editor( player_name, node_name )
			end
		else
			open_global_editor( player_name )
		end
	end
} )

--------------------

function BasicPhysics( self )
	local old_on_step = self.on_step
	local unknown_ndef = { walkable = true, groups = { } }

	local function play_sound( name )
		minetest.sound_play( self.motion_sounds[ name ] or motion_sounds[ name ],
			{ object = self.object, xgain = 0.4, loop = false }, true )
	end

	local function handle_physics( pos, new_vel, old_vel, collisions )
		local props = self.physics
		local node_below = minetest.get_node_above( pos, self.is_swimming and 0.3 or -0.2 )
		local ndef_below = minetest.registered_nodes[ node_below.name ] or unknown_ndef

		-- if entity is rolling or floating, then it should slow down and stop
		if ndef_below.groups.liquid then
			local liquid = materials[ node_below.name ] or config.default_liquid

			if not self.is_swimming and new_vel.y < -2.0 then
				play_sound( "diving" )
			end

			local drag = -new_vel.y * liquid.viscosity * 1.5
			local buoyancy = props.density - liquid.density
       			self.object:set_acceleration_vert( -config.world_gravity * buoyancy + drag )

			new_vel.x = new_vel.x * ( 1.0 - props.resistance * liquid.viscosity )
			new_vel.z = new_vel.z * ( 1.0 - props.resistance * liquid.viscosity )

	       		self.is_swimming = true

		elseif self.is_swimming then
			play_sound( "floating" )

			self.object:set_acceleration_vert( ramp( -config.world_gravity, new_vel.y, 2.0 ) )   -- hack to reduce oscilations
			self.is_swimming = false

		elseif ndef_below.walkable and new_vel.y <= 0 then
			local solid = materials[ node_below.name ] or config.default_solid
			new_vel.x = new_vel.x * ( 1.0 - props.friction * solid.friction )
			new_vel.z = new_vel.z * ( 1.0 - props.friction * solid.friction )

		else
			new_vel = vector.multiply( new_vel, 1.0 - props.resistance * config.air_viscosity )
			self.object:set_acceleration_vert( config.world_gravity * ( config.air_density - props.density ) )
		end

--[[		-- this is a hacky workaround for broken collision detection in engine
		if new_vel.y == 0 and abs( old_vel.y ) > 0.2 then
			new_vel.y = self.has_bounce and old_vel.y or -old_vel.y * self.elasticity
			self.has_bounce = not self.has_bounce
		elseif new_vel.x == 0 and abs( old_vel.x ) > 0.2 then
			new_vel.x = self.has_bounce and old_vel.x or -old_vel.x * self.elasticity
			self.has_bounce = not self.has_bounce
		elseif new_vel.z == 0 and abs( old_vel.z ) > 0.2 then
			new_vel.z = self.has_bounce and old_vel.z or -old_vel.z * self.elasticity
			self.has_bounce = not self.has_bounce
		else
			self.has_bounce = false
		end

		if self.has_bounce then
			minetest.sound_play( "ballkick4", { object = self.object, gain = 0.8 } )
		end]]

		-- if entity collided while rolling or floating, then it should bounce
		local hit_axis
		if new_vel.y == 0 and abs( old_vel.y ) > 0.2 then
			hit_axis = "y"
			new_vel.y = -old_vel.y * props.elasticity
		elseif new_vel.x == 0 and abs( old_vel.x ) > 0.2 then
			hit_axis = "x"
			new_vel.x = -old_vel.x * props.elasticity
		elseif new_vel.z == 0 and abs( old_vel.z ) > 0.2 then
			hit_axis = "z"
			new_vel.z = -old_vel.z * props.elasticity
		end

		if hit_axis then
			for idx = 1, #collisions  do
				local hit_info = collisions[ idx ]

				if hit_info.side[ hit_axis ] ~= 0 and hit_info.impacts then
					local node = minetest.get_node( hit_info.node_pos )
					local ndef = minetest.registered_nodes[ node.name ] or unknown_ndef

					if ndef.sounds then
						local sound = "hitting_" .. string.match( ndef.sounds.footstep.name, "^default_(.-)_footstep$" )
						play_sound( motion_sounds[ sound ] and sound or "hitting_stone" )
					else
						play_sound( "hitting_stone" )
					end

				end
			end
		end

		if abs( new_vel.x ) <= 0.1 and abs( new_vel.z ) <= 0.1 then
			new_vel.x = 0.0
			new_vel.z = 0.0
		end

		self.object:set_velocity( new_vel )
	end

	self.on_step = function( self, dtime, pos, rot, new_vel, old_vel, move_result )
		--S1()		
		local is_standing = vector.equals( new_vel, vector.origin ) and move_result.is_standing
		if not is_standing then
			handle_physics( pos, new_vel, old_vel, move_result.collisions )
		end
		--S1_()
		old_on_step( self, dtime, pos, rot, new_vel, old_vel, move_result )
	end
end

--------------------

import_materials( )

-- compatibility for Minetest S3 engine

if not vector.origin and not minetest.get_node_above then
	dofile( minetest.get_modpath( "physics" ) .. "/compatibility.lua" )
end
