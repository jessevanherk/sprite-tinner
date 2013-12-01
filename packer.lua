local Packer = {}

function Packer.findImages( image_dir )
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
                local sub_images = Packer.findImages( sub_dir )
                for _, sub_image in ipairs( sub_images ) do
                    table.insert( images, sub_image )
                end
            end
        end
    end

    return images
end

return Packer

