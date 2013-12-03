# SpriteTinner 

This is a simple command line tool to quickly create a spritesheet(texture atlas)
from all images in a given folder. It outputs one big PNG image containing the sprites,
and a .lua file containing the metadata for indexing them.

SpriteTinner can replace a more complex tool like TexturePacker, especially if you
only need a basic spritesheet.

The metadata file is compatible with CoronaSDK. 

## Installation

### Download SpriteTinner

Official releases are hosted on [github](https://github.com/jessevanherk/sprite-tinner/),
along with the latest code.

> git clone https://github.com/jessevanherk/sprite-tinner.git

### Install Dependencies

There aren't very many dependencies, and they are easy to install!

* lua 5.1 (or higher)
* lua-filesystem
* imlib2

On an Ubuntu system, you can install these by running:

`sudo apt-get install lua lua-filesystem luarocks`

`sudo luarocks install lua-imlib2`

## Usage

> spritetinner outfile imagedir
 
Outfile should not have an extension - SpriteTinner will add those for you.
All PNG images contained in imagedir will be included, recursively. 

### Example:

> spritetinner myspritesheet ./images/source/

This will create 2 files:
* myspritesheet.png - contains all of the sprites in one big image
* myspritesheet.lua - contains info about each sprite, suitable for use by coronaSDK

### Limits

* The only allowed input image format is PNG (for now). 
* only creates images with power-of-2 sizes. This is on purpose, for older video cards.
* some graphics cards don't play nicely with large texture atlases. 

## License

This is free software released under the MIT license. You can use it for
almost anything, including commercial projects.

See the [LICENSE](LICENSE) file for full details.

## Credits

Author: Jesse van Herk <jesse@imaginaryrobots.net>

Based heavily on Jakesgordon's code from:
https://github.com/jakesgordon/bin-packing/blob/master/js/packer.growing.js
