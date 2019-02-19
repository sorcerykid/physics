--------------------------------------------------------
-- Minetest :: MetaPhysics Mod v1.0 (physics)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2016-2019, Leslie Ellen Krause
--
-- ./games/minetest_game/mods/physics/init.lua
--------------------------------------------------------

local physics = { }

local props = {
	world_gravity = 10,
	air_viscosity = 0.1,
	air_density = 0.5,
	default_liquid = { viscosity = 0.0, density = 0.5 },
	default_solid = { friction = 0.5, elasticity = 0.5 },
}

local entities = { }
local materials = {
	["default:water_source"] = { type = "liquid", viscosity = 0.5, density = 0.5 },
}

physics.open_global_editor = function ( player_name )
	local get_formspec = function ( )
		local formspec = 
			"size[8,5]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			"label[0.0,0.0;Weather Properties]" ..
			"box[0.0,0.6;3.8,0.1;#555555]" ..

			"label[0.0,1.1;Temperature:]" ..
			"button[2.0,1.2;0.7,0.3;temp_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;temp_add;>]" ..
			string.format( "label[2.7,1.1;%d]", 32 ) ..

			"label[0.0,2.1;Wind Speed:]" ..
			"button[2.0,2.2;0.7,0.3;wind_sub;<]" ..
			"box[2.5,2.0;0.7,0.6;#000000]" ..
			"button[3.2,2.2;0.7,0.3;wind_add;>]" ..
			string.format( "label[2.7,2.1;%d]", 12 ) ..

			"label[0.0,3.1;Precipitation:]" ..
			"button[2.0,3.2;0.7,0.3;prec_sub;<]" ..
			"box[2.5,3.0;0.7,0.6;#000000]" ..
			"button[3.2,3.2;0.7,0.3;prec_add;>]" ..
			string.format( "label[2.7,3.1;%0.1f]", 0.1 ) ..

			"label[4.0,0.0;Physics Properties]" ..
			"box[4.0,0.6;3.8,0.1;#555555]" ..

			"label[4.0,1.1;World Gravity:]" ..
			"button[6.0,1.2;0.7,0.3;gravity_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;gravity_add;>]" ..
			string.format( "label[6.7,1.1;%d]", physics.world_gravity ) ..

			"label[4.0,2.1;Air Density:]" ..
			"button[6.0,2.2;0.7,0.3;density_sub;<]" ..
			"box[6.5,2.0;0.7,0.6;#000000]" ..
			"button[7.2,2.2;0.7,0.3;density_add;>]" ..
			string.format( "label[6.7,2.1;%0.1f]", physics.air_density ) ..

			"label[4.0,3.1;Air Viscosity:]" ..
			"button[6.0,3.2;0.7,0.3;viscosity_sub;<]" ..
			"box[6.5,3.0;0.7,0.6;#000000]" ..
			"button[7.2,3.2;0.7,0.3;viscosity_add;>]" ..
			string.format( "label[6.7,3.1;%0.1f]", physics.air_viscosity ) ..

			"box[0.0,4.0;3.8,0.1;#555555]" ..
			"button_exit[6.0,4.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.gravity_sub then
			physics.world_gravity = math.max( 0.0, physics.world_gravity - 1 )
		elseif fields.gravity_add then
			physics.world_gravity = math.min( 10, physics.world_gravity + 1 )
		elseif fields.density_sub then
			physics.air_density = math.max( 0.0, physics.air_density - 0.1 )
		elseif fields.density_add then
			physics.air_density = math.min( 1.0, physics.air_density + 0.1 )
		elseif fields.viscosity_sub then
			physics.air_viscosity = math.max( 0.0, physics.air_viscosity - 0.1 )
		elseif fields.viscosity_add then
			physics.air_viscosity = math.min( 1.0, physics.air_viscosity + 0.1 )
		else
			return
		end
		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

physics.open_entity_editor = function ( player_name, entity )
	if not entities[ entity.itemstring ] then
		entities[ entity.itemstring ] = entity.physics
	end
	local prop = this.physics
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
			string.format( "label[2.7,1.1;%0.1f]", prop.friction ) ..

			"label[0.0,2.1;Density:]" ..
			"button[2.0,2.2;0.7,0.3;density_sub;<]" ..
			"box[2.5,2.0;0.7,0.6;#000000]" ..
			"button[3.2,2.2;0.7,0.3;density_add;>]" ..
			string.format( "label[2.7,2.1;%0.1f]", prop.density ) ..

			"label[4.0,1.1;Elasticity:]" ..
			"button[6.0,1.2;0.7,0.3;elasticity_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;elasticity_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", prop.elasticity ) ..

			"label[4.0,2.1;Resistance:]" ..
			"button[6.0,2.2;0.7,0.3;resistance_sub;<]" ..
			"box[6.5,2.0;0.7,0.6;#000000]" ..
			"button[7.2,2.2;0.7,0.3;resistance_add;>]" ..
			string.format( "label[6.7,2.1;%0.1f]", prop.resistance ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "image[0.1,3.2;1.0,1.0;%s]", minetest.registered_items[ this.itemstring ].inventory_image ) ..
			string.format( "label[1.2,3.4;%s (Solid)]", this.description ) ..
			"button_exit[4.0,3.5;2,0.3;close;Reset]" ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"

		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.reset then
			objects[ this.itemstring ] = nil
			return
		elseif fields.friction_sub then
			prop.friction = math.max( 0.0, prop.friction - 0.1 )
		elseif fields.friction_add then
			prop.friction = math.min( 1.0, prop.friction + 0.1 )
		elseif fields.density_sub then
			prop.density = math.max( 0.0, prop.density - 0.1 )
		elseif fields.density_add then
			prop.density = math.min( 1.0, prop.density + 0.1 )
		elseif fields.elasticity_sub then
			prop.elasticity = math.max( 0.0, prop.elasticity - 0.1 )
		elseif fields.elasticity_add then
			prop.elasticity = math.min( 1.0, prop.elasticity + 0.1 )
		elseif fields.resistance_sub then
			prop.resistance = math.max( 0.0, prop.resistance - 0.1 )
		elseif fields.resistance_add then
			prop.resistance = math.min( 1.0, prop.resistance + 0.1 )
		else
			return
		end
		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

physics.open_solid_editor = function ( player_name, node_name )
	local def = minetest.registered_items[ node_name ]
	local solid = materials[ node_name ] or { friction = physics.default_solid.friction, elasticity = physics.default_solid.elasticity }

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
			string.format( "label[2.7,1.1;%0.1f]", solid.friction ) ..

			"label[4.0,1.1;Elasticity:]" ..
			"button[6.0,1.2;0.7,0.3;elasticity_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;elasticity_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", solid.elasticity ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "image[0.1,3.2;1.0,1.0;%s]", def.tiles[ 1 ].name or def.tiles[ 1 ] ) ..
			string.format( "label[1.2,3.4;%s]", def.description ) ..
			"button_exit[4.0,3.5;2,0.3;reset;Reset]" ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.reset then
			materials[ node_name ] = nil
			return
		elseif fields.friction_sub then
			solid.friction = math.max( 0.0, solid.friction - 0.1 )
		elseif fields.friction_add then
			solid.friction = math.min( 1.0, solid.friction + 0.1 )
		elseif fields.elasticity_sub then
			solid.elasticity = math.max( 0.0, solid.elasticity - 0.1 )
		elseif fields.elasticity_add then
			solid.elasticity = math.min( 1.0, solid.elasticity + 0.1 )
		else
			return
		end

		if not materials[ node_name ] then
			materials[ node_name ] = solid
		end
		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

physics.open_liquid_editor = function ( player_name, node_name )
	local def = minetest.registered_items[ node_name ]
	local liquid = materials[ node_name ] or { viscosity = physics.default_liquid.viscosity, density = physics.default_liquid.density }

	local get_formspec = function ( )
		local formspec = 
			"size[8,4]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			string.format( "label[0.0,0.0;Physics Properties (%s)]", materials[ node_name ] and "Override" or "Default" ) ..
			"box[0.0,0.6;3.8,0.1;#555555]" ..

			"label[0.0,1.1;Viscosity:]" ..
			"button[2.0,1.2;0.7,0.3;viscosity_sub;<]" ..
			"box[2.5,1.0;0.7,0.6;#000000]" ..
			"button[3.2,1.2;0.7,0.3;viscosity_add;>]" ..
			string.format( "label[2.7,1.1;%0.1f]", liquid.viscosity ) ..

			"label[4.0,1.1;Density:]" ..
			"button[6.0,1.2;0.7,0.3;density_sub;<]" ..
			"box[6.5,1.0;0.7,0.6;#000000]" ..
			"button[7.2,1.2;0.7,0.3;density_add;>]" ..
			string.format( "label[6.7,1.1;%0.1f]", liquid.density ) ..

			"box[0.0,3.0;7.8,0.1;#555555]" ..
			string.format( "image[0.1,3.2;1.0,1.0;%s]", def.tiles[ 1 ].name or def.tiles[ 1 ] ) ..
			string.format( "label[1.2,3.4;%s]", def.description ) ..
			"button_exit[4.0,3.5;2,0.3;reset;Reset]" ..
			"button_exit[6.0,3.5;2,0.3;close;Close]"
		return formspec
	end

	local on_close = function ( meta, player, fields )
		if fields.reset then
			materials[ node_name ] = nil
			return
		elseif fields.viscosity_sub then
			liquid.viscosity = math.max( 0.0, liquid.viscosity - 0.1 )
		elseif fields.viscosity_add then
			liquid.viscosity = math.min( 1.0, liquid.viscosity + 0.1 )
		elseif fields.density_sub then
			liquid.density = math.max( 0.01, liquid.density - 0.1 )
		elseif fields.density_add then
			liquid.density = math.min( 1.0, liquid.density + 0.1 )
		else
			return
		end

		if not materials[ node_name ] then
			materials[ node_name ] = liquid
		end
		minetest.update_form( player_name, get_formspec( ) )
	end

	minetest.create_form( nil, player_name, get_formspec( ), on_close )
end

minetest.register_tool( "athletics:physics_wand", {
	description = "Physics Wand",
	range = 5,
	inventory_image = "physics_wand.png",
	groups = { not_in_creative_inventory = 1 },
	liquids_pointable = true,

	on_use = function ( itemstack, clicker, pointed_thing )
		local player_name = clicker:get_player_name( )
		if pointed_thing.type == "object" then
			local this = pointed_thing.ref:get_luaentity( )
			physics.open_object_editor( player_name, this )
		elseif pointed_thing.type == "node" then
			local node_name = minetest.get_node( pointed_thing.under ).name
			local def = minetest.registered_items[ node_name ]
			if def.groups.liquid then
				physics.open_liquid_editor( player_name, node_name )
			else
				physics.open_solid_editor( player_name, node_name )
			end
		else
			physics.open_global_editor( player_name )
		end
	end
} )

function BasicPhysics( self )
	if entities[ self.name ] then
		-- override physics of prototype
		self.physics = entities[ self.name ]
	end

	self.vel = { x = 0, y = 0, z = 0 }
	self.object:setvelocity( self.vel )
	self.object:setacceleration( { x = 0, y = -physics.world_gravity, z = 0 } )
	
	self.handle_motion_physics = function ( )
		local vel = self.object:getvelocity( )
		local pos = self.object:getpos( )
		local node_name = minetest.get_node( pos ).name
		local prop = self.physics

		local ndef = minetest.registered_nodes[ node_name ]

		if ndef.groups.liquid then
			-- ball should sink or float in water and lava
			local liquid = materials[ node_name ] or physics.default_liquid

			vel.x = vel.x * ( 1.0 - liquid.viscosity / 2 )
			vel.z = vel.z * ( 1.0 - liquid.viscosity / 2 )
			if not self.is_floating then
				-- reduce inertia only on initial splash
				if vel.y < -2 then
					minetest.sound_play( "ambience_player_dive", { object = self.object, gain = 0.4, loop = false } )
				end
				vel.y = vel.y * ( 1.0 - prop.resistance * liquid.viscosity )
			end

			self.object:setacceleration_vert( physics.world_gravity * ( liquid.density - prop.density ) )
			self.object:setvelocity_vert( vel.y )
			self.is_floating = true
		else
			local node_below = minetest.get_node_above( pos, -0.5 )
			local ndef_below = minetest.registered_nodes[ node_below.name ]

			-- if ball is rolling or floating, then it should slow down and stop
			if ndef_below.groups.liquid then
				local liquid = materials[ node_below.name ] or physics.default_liquid

				self.object:setacceleration_vert( -physics.world_gravity * ( 1.0 - prop.density * liquid.viscosity ) )
				if self.sound_delay == 0 and vel.y > 0 then
					self.sound_delay = 12
					minetest.sound_play( "ambience_player_splash", { object = self.object, gain = 0.4, loop = false } )
				end
				if vel.y <= 0 then
					local liquid = materials[ node_below.name ] or physics.default_liquid
					vel.x = vel.x * ( 1.0 - prop.friction * liquid.viscosity )
					vel.z = vel.z * ( 1.0 - prop.friction * liquid.viscosity )

				end

			elseif ndef_below.walkable and vel.y <= 0 then
				local solid = materials[ node_below.name ] or physics.default_solid
				vel.x = vel.x * ( 1.0 - prop.friction * solid.friction )
				vel.z = vel.z * ( 1.0 - prop.friction * solid.friction )

			else
				vel = vector.multiply( vel, 1.0 - prop.resistance * physics.air_viscosity )
				self.object:setacceleration_vert( physics.world_gravity * ( physics.air_density - prop.density ) )
			end

			-- if ball collided while rolling or floating, then it should bounce
			if vel.y == 0 and self.vel.y < 0 then
				vel.y = -self.vel.y * prop.elasticity
				minetest.sound_play( "ballkick4", { object = self.object, gain = 0.8 } )
			end
			if vel.x == 0 and math.abs( self.vel.x ) > 0.2 then
				vel.x = -self.vel.x * prop.elasticity
				minetest.sound_play( "ballkick4", { object = self.object, gain = 0.8 } )
			end
			if vel.z == 0 and math.abs( self.vel.z ) > 0.2 then 
				vel.z = -self.vel.z * prop.elasticity
				minetest.sound_play( "ballkick4", { object = self.object, gain = 0.8 } )
			end
			self.is_floating = false
		end

		if math.abs( vel.x ) <= 0.2 and math.abs( vel.z ) <= 0.2 then
			vel.x = 0
			vel.z = 0
		end

		self.set_velocity( vel.x, vel.y, vel.z )
	end

	self.set_velocity = function ( x, y, z )
		self.vel = { x = x, y = y, z = z }
		self.object:setvelocity( self.vel )
	end

	self.add_velocity = function ( x, y, z )
		self.vel = { x = self.vel.x + x, y = self.vel.y + y, z = self.vel.z + z }
		self.object:setvelocity( self.vel )
	end

	self.reset_acceleration = function ( )
		self.object:setacceleration_vert( -physics.world_gravity )
	end
end
