minetest.get_node_above = function ( pos, off )
        return minetest.get_node( { x = pos.x, y = pos.y + ( off or 1 ), z = pos.z } )
end

vector.origin = { x = 0, y = 0, z = 0 }


print( "RUNNING!" )
