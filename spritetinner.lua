-- Sprite Tinner - command line texture packing program
-- 
-- Author: Jesse van Herk <jesse@imaginaryrobots.net>
-- 
-- License: MIT.
-- 
-- Depends: Lua 5.1+, lua-filesystem

local version = "1.2.0"

local usage = [[
Usage: spritetinner [-n] [-h] [-p<spritefile.png>] [-m<metafile.lua>] -i<imagedir>
 
  This will create a power-of-2 sized PNG image called spritefile.png,
  as well as metadata in metafile.lua, suitable for use by coronaSDK.
  All images contained in imagedir will be included, recursively.

  OPTIONS:
  -i: source image directory to parse. required.
  -p: filename for output PNG file. default is output.png
  -m: filename for output lua metadata file. default is output.lua
  -n: no autocropping of sprites, includes transparent borders
  -h: show this help

  Allowed input image format is PNG. 
]]

-- can't require a different chunk by name when compiled together,
-- so check if it's already present first
if not _G[ 'Packer' ] then
    Packer = require( 'packer' )
end

fs = require( 'lfs' )
io = require( 'io' )

-- inline getopt_alt.lua
-- getopt, POSIX style command line argument parser
-- param arg contains the command line arguments in a standard table.
-- param options is a string with the letters that expect string values.
-- returns a table where associated keys are true, nil, or a string value.
function getopt( arg, options )
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

-- read from arg[] array rather than ... to play nice when compiled
local options = getopt( arg, "himnp" )
local sprite_filename   = options[ 'p' ] or 'output.png'
local metadata_filename = options[ 'm' ] or 'output.lua'
local image_dir         = options[ 'i' ]
local no_crop = options[ 'n' ] == 'c'
local show_help = options[ 'h' ]

-- make sure we have the needed params
if show_help or not image_dir then
    print( usage )
    print( "This is SpriteTinner version " .. version )
    return 1
end

local packer = Packer( not no_crop )
packer:pack( image_dir )

-- write the sheet metadata file
local metadata = packer:getMetadata()
local metadata_file = io.open( metadata_filename , "w" )
metadata_file:write( metadata )
metadata_file:close()

-- write the spritesheet image file
packer:writeSheetImage( sprite_filename )

print( "Done! Files written:" )
print( " * " .. sprite_filename )
print( " * " .. metadata_filename )

-- done
