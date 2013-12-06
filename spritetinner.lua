-- Sprite Tinner - command line texture packing program
-- 
-- Author: Jesse van Herk <jesse@imaginaryrobots.net>
-- 
-- License: MIT.
-- 
-- Depends: Lua 5.1+, lua-filesystem

local version = "1.1.0"

local usage = [[
Usage: spritetinner <spritefile.png> <metafile.lua> <imagedir>
 
  This will create a power-of-2 sized PNG image called spritefile.png,
  as well as metadata in metafile.lua, suitable for use by coronaSDK.
  All images contained in imagedir will be included, recursively.

  Allowed image format is PNG (for now). 
]]

-- can't load a different chunk by name when compiled together
if not _G[ 'Packer' ] then
    Packer = require( 'packer' )
end

fs = require( 'lfs' )
io = require( 'io' )

-- read from arg[] array rather than ... to play nice when compiled
local sprite_filename   = arg[ 1 ]
local metadata_filename = arg[ 2 ]
local image_dir         = arg[ 3 ]

-- make sure we have the needed params
if not image_dir then
    print( usage )
    print( "This is SpriteTinner version " .. version )
    return 1
end

local packer = Packer()
local metadata = packer:pack( image_dir )

-- write the sheet metadata file
local metadata_file = io.open( metadata_filename , "w" )
metadata_file:write( metadata )
metadata_file:close()

-- write the spritesheet image file
packer:writeSheetImage( sprite_filename )

print( "Done! Files written:" )
print( " * " .. sprite_filename )
print( " * " .. metadata_filename )

-- done
