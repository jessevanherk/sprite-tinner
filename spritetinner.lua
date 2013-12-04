-- Sprite Tinner - command line texture packing program
-- 
-- Author: Jesse van Herk <jesse@imaginaryrobots.net>
-- 
-- License: MIT.
-- 
-- Depends: Lua 5.1+, lua-filesystem

local usage = [[
Usage: spritetinner <outfile> <imagedir>
 
  This will create a power-of-2 sized PNG image called outfile.png, as
  well as metadata in outfile.lua, suitable for use by coronaSDK.
  All images contained in imagedir will be included, recursively.

  Allowed image format is PNG (for now). 
]]

-- can't load a different chunk by name when compiled together
if not _G[ 'Packer' ] then
    Packer = require( 'packer' )
end

fs = require( 'lfs' )
io = require( 'io' )

local allowed_types = { 'png' }

-- read from arg[] array rather than ... to play nice when compiled
local out_name, image_dir = arg[ 1 ], arg[ 2 ]

-- make sure we have the needed params
if not out_name or not image_dir then
    print( usage )
    return 1
end

local packer = Packer()
local metadata = packer:pack( image_dir )

-- write the sheet metadata file
local metadata_filename = out_name .. ".lua"
local metadata_file = io.open( metadata_filename , "w" )
metadata_file:write( metadata )
metadata_file:close()

-- write the spritesheet image file
local sprite_filename = out_name .. ".png"
packer:writeSheetImage( sprite_filename )

print( "Done! Files written:" )
print( " * " .. sprite_filename )
print( " * " .. metadata_filename )

-- done
