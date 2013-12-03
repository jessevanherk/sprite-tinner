# Sprite Tinner 

command line texture packing program for linux.

# Overview

This is a simple command line tool to create a spritesheet(texture atlas)
from all images in a given folder. It outputs a .lua file by default, which
should be compatible with the Corona SDK.

# Installation

## Requirements

Requires 
* lua 5.1 or higher
* lua-filesystem
* imlib2

# Usage

Usage: spritetinner <outfile> <imagedir>
 
This will create a power-of-2 sized PNG image called outfile.png, as well as
metadata in outfile.lua, suitable for use by coronaSDK.  All images contained
in imagedir will be included, recursively. 

The only allowed image format is PNG (for now). 

# License

This is free software released under the MIT license. See LICENSE for details.

# Credits

Author: Jesse van Herk <jesse@imaginaryrobots.net>

Based heavily on Jakesgordon's code from:
https://github.com/jakesgordon/bin-packing/blob/master/js/packer.growing.js
