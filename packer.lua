--[[
Based on code from:
https://github.com/jakesgordon/bin-packing/blob/master/js/packer.js
]]--

local imlib2 = require( 'imlib2' )
local io = require( 'io' )

-- create as global to play nice when compiled.
Packer = {}

-- hook up the prototype for method calls
Packer.__index = Packer
--hook up the meta-table, and set it up to initialize
setmetatable( Packer, {
    __call = function( classname, ... )
        local self = setmetatable( {}, classname )
        self:_init( ... )
        return self
    end,
})

local frame_template = [[   [%q] = %u,
]]
local block_template = [[
    { -- %s
        x = %u,
        y = %u,
        width = %u,
        height = %u,
        sourceX = %u,
        sourceY = %u,
        sourceWidth = %u,
        sourceHeight = %u,
    },
]] 
local sheet_template = [[
local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
        %s
    },
    sheetContentWidth = %u,
    sheetContentHeight = %u,
}

SheetInfo.frameIndex =
{
    %s
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex( name )
    return self.frameIndex[ name ];
end

return SheetInfo
]]

-- user can pass in a starting width and height to use
function Packer:_init( width, height )
    self.default_size = 512
    self.sprites_image = nil
    self.root = {}
end

-- primary call. 
function Packer:pack( image_dir )
    local sprites_image, metadata

    local image_files = Packer:findImages( image_dir )
    local blocks = self:loadImageBlocks( image_files )

    -- sort the blocks and figure out where to place each
    local sorted_blocks = self:sortBlocks( blocks )

    -- try multiple image sizes until we find one that can fit everything
    -- since this doesn't run often, performance is not critical.
    local fitted_blocks = nil
    local try_count = 0
    local try_width  = self.default_size
    local try_height = self.default_size
    while not fitted_blocks do
        print( "trying to fit in size " .. try_width .. "x" .. try_height )
        -- reset the root.
        self.root = {
            x = 0, 
            y = 0,
            width  = try_width,
            height = try_height,
        }
        fitted_blocks = self:fitBlocks( sorted_blocks )

        -- alternately double the width and the height.
        if try_count % 2 == 0 then
            try_width = try_width * 2
        else
            try_height = try_height * 2
        end
        try_count = try_count + 1
    end

    -- create the metadata file
    local metadata = self:buildSheetFile( fitted_blocks )
    -- create the output image data
    self.sprites_image = self:createSheetImage( fitted_blocks )

    return metadata
end

-- createSheetImage( blocks )
--
-- given a set of blocks with image and position data, create an
-- in-memory PNG image that can be written out.
function Packer:createSheetImage( blocks )
    local sheet_image = imlib2.image.new( self.root.width, self.root.height )
    sheet_image:clear()  -- blank it out - could be garbage memory otherwise
    sheet_image:set_format( 'png' )
    sheet_image:set_has_alpha( true ) -- the docs lie about this function's name.
    
    for _, block in ipairs( blocks ) do
        self:stampImage( block.image, sheet_image, block.x, block.y )
    end

    return sheet_image
end

function Packer:writeSheetImage( filename )
    if self.sprites_image then
        self.sprites_image:save( filename )
    end
end

-- buildSheetFile( blocks )
-- create the text for the metadata file describing the blocks and their 
-- positions in the sheet.
function Packer:buildSheetFile( blocks )
    local block_texts = {}
    local frame_texts = {}

    for i, block in ipairs( blocks ) do
        -- fill in that block's text
        local block_text = string.format( block_template, block.name,
                       block.x, block.y, block.width, block.height,
                       block.source_x, block.source_y, block.source_width, block.source_height )
        table.insert( block_texts, block_text )

        -- fill in that frame's text, so blocks can be fetched by name
        local frame_text = string.format( frame_template, block.name, i )
        table.insert( frame_texts, frame_text )

    end
    local all_blocks = table.concat( block_texts )
    local all_frames = table.concat( frame_texts )
    local content = string.format( sheet_template, 
                        all_blocks, self.root.width, self.root.height, all_frames )
    return content
end


-- recursively find images under given directory.
-- make sure they are the correct format.
function Packer:findImages( image_dir )
    local images = {}

    for file in fs.dir( image_dir ) do
        local file_path = image_dir .. "/" .. file
        local mode = fs.attributes( file_path, 'mode' )

        if mode == "file" then
            local extension = string.gmatch( file, ".+%.(%w+)" )
            if string.lower( extension() ) == 'png' then
                table.insert( images, file_path )
            end
        elseif mode == "directory" then
            if file ~= '.' and file ~= '..' then
                local sub_dir = image_dir .. "/" .. file
                local sub_images = Packer:findImages( sub_dir )
                for _, sub_image in ipairs( sub_images ) do
                    table.insert( images, sub_image )
                end
            end
        end
    end

    return images
end

-- load all of the images into memory
-- read their sizes
function Packer:loadImageBlocks( image_files )
    local blocks = {}
    for _, file_path in ipairs( image_files ) do
        local image  = imlib2.image.load( file_path )
        local width  = image:get_width()
        local height = image:get_height()
        local name   = string.gmatch( file_path, ".*/(.+)%.(%w+)" )()
        -- FIXME: trim excess blank space automatically
        local block = {
            filename = file_path,
            name  = name,
            image = image,
            width = width,
            height = height,
            source_x = 0,
            source_y = 0,
            source_width = width,
            source_height = height,
        }
        table.insert( blocks, block )
    end
    return blocks
end

-- sortBlocks( blocks )
-- given a table of blocks, each with a width and height entry,
-- return the blocks sorted from biggest to smallest. 
-- sort only on height for now.
function Packer:sortBlocks( blocks )
    -- copy into a temporary table since table.sort operates in-place
    local working = {}
    for _, block in ipairs( blocks ) do
        table.insert( working, block )
    end
    table.sort( working, function( a, b ) return a.height > b.height end )
    return working
end

-- FIXME: see if these actually work!
-- build a binary tree to contain all of our image blocks.
-- returns a copy of the blocks array, with fit info inside.
function Packer:fitBlocks( blocks )
    -- copy blocks into working array
    -- FIXME: use deep copy or clone!
    local working_blocks = {}
    for _, block in ipairs( blocks ) do
        table.insert( working_blocks, block )
    end

    -- fit the rest of the blocks
    for _, block in ipairs( working_blocks ) do
        local node = self:findNode( self.root, block.width, block.height )
        if node then  -- found a spot for it
            -- fit it
            block.x = node.x
            block.y = node.y
            -- split it
            self:splitNode( node, block.width, block.height )
        else
            return nil -- can't fit, give up.
        end
    end

    return blocks
end

-- find a node in the binary tree that is big enough to hold a block
-- with the given width and height.
-- returns a node table
function Packer:findNode( parent, width, height ) 
    local node = nil
    if parent.used then  
        -- check the right sub-tree
        node = self:findNode( parent.right, width, height ) 
        if not node then -- no luck
            -- check the down sub-tree 
            node = self:findNode( parent.down, width, height )
        end
    elseif width <= parent.width and height <= parent.height then -- make sure it fits 
        node = parent
    end

    return node
end

-- splitNode( node, w, h )
-- create 2 new sub-nodes
-- called when a block is placed in a node
-- returns a node table
function Packer:splitNode( node, width, height )
    node.used = true
    -- create the right sub-node. 
    node.right = {
        x = node.x + width,
        y = node.y,
        width = node.width - width,
        height = height,
    }
    -- create the down sub-node
    node.down = {
        x = node.x,
        y = node.y + height,
        width = node.width,
        height = node.height - height,
    }
    return node
end

-- stampImage( source_image, target_image, left, top )
-- because the lua imlib2 binding doesn't seem to have a way to
-- combine images, do it manually pixel-by-pixel.
-- <left, top> are the coordinates where we want to copy the source image to.
-- modifies target_image in-place
function Packer:stampImage( source_image, target_image, left, top )
    local source_width = source_image:get_width()
    local source_height = source_image:get_height()

    local target_width = target_image:get_width()
    local target_height = target_image:get_height()

    if left + source_width > target_width or 
       top + source_height > target_height then
            print( "source image is too big for target, won't continue." )
            return nil
    end

    for y = 0, source_height - 1 do
        for x = 0, source_width - 1 do
            local colour = source_image:get_pixel( x, y )
            target_image:draw_pixel( left + x, top + y, colour )
        end
    end
end

return Packer

