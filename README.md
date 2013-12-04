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

> git clone --recursive https://github.com/jessevanherk/sprite-tinner.git

### Install Dependencies

SpriteTinner depends on:
* lua 5.1 (or higher)
* lua-filesystem
* lua-imlib2
* imlib2

On an Ubuntu system, you can install these by running:

`sudo apt-get install lua5.1 lua-filesystem luarocks libimlib2 libimlib2-dev`

`sudo luarocks install lua-imlib2`

### Build

Start the build by running:

> make 

### Install

Install the binary by running:

> sudo make install

This will install the spritetinner executable into /usr/local/bin. You can
move it somewhere else if you want. 

## Usage

> spritetinner spritefile.png metafile.lua imagedir
 
All PNG images contained in imagedir will be included, recursively. 

### Example:

> spritetinner images/myspritesheet.png data/myspritesheet.lua ./images/

This will create 2 files:
* images/myspritesheet.png - contains all of the sprites in one big image
* data/myspritesheet.lua - contains info about each sprite, suitable for use by coronaSDK

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
