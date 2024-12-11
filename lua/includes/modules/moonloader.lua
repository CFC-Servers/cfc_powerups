AddCSLuaFile( "includes/modules/moonloader.lua" )
print( "Loading stubbed moonloader.lua - binary not installed!" )
_G.moonloader = { PreCacheDir = function() end, PreCacheFile = function() end }
