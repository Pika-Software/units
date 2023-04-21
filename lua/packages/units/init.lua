import( gpm.LuaPackageExists( "packages/glua-extensions" ) and "packages/glua-extensions" or "https://raw.githubusercontent.com/Pika-Software/glua-extensions/main/package.json" )

-- Libraries
local string = string
local math = math

-- Variables
local util_ScreenResolution = util.ScreenResolution
local packageName = gpm.Package:GetIdentifier()
local hook_Add = hook.Add
local tonumber = tonumber
local IsValid = IsValid
local type = type

module( "units" )

local units = {}
function GetAll()
    return units
end

function GetFunction( unitsName )
    return units[ unitsName ]
end

function Set( unitsName, func )
    units[ unitsName ] = func
end

function Get( str, ... )
    if ( type( str ) == "number" ) then return str end
    if ( type( str ) ~= "string" ) then return 0 end

    -- TODO: Improve pattern
    local digits, unitsName = string.match( string.lower( str ), "%s*([%d%.]+)%s*([%a%%]+)%s*" )
    if not digits then return 0 end

    local number = tonumber( digits )
    if not number then return 0 end

    local func = units[ unitsName ]
    if not func then return number end

    local result = func( number, ... )
    if not result then return number end

    return math.max( 1, math.floor( result ) )
end

Set( "in", function( number )
    return number * 96
end )

Set( "cm", function( number )
    return number * 37.8
end )

Set( "mm", function( number )
    return number * 3.78
end )

Set( "pc", function( number )
    return number * 16
end )

Set( "pt", function( number )
    return ( number * 96 ) / 72
end )

Set( "q", function( number )
    return number * 0.945
end )

Set( "%w", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetWidth() / 100 ) * num
end )

Set( "%h", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetHeight() / 100 ) * num
end )

Set( "%", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( ( ( width + height ) / 2 ) / 100 ) * num
end )

Set( "%min", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math.min( width, height ) / 100 ) * num
end )

Set( "%max", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math.max( width, height ) / 100 ) * num
end )

local vh, vw = 0, 0
Set( "vh", function( num )
    return vh * num
end )

Set( "vw", function( num )
    return vw * num
end )

local vmin, vmax = 0, 0
Set( "vmin", function( num )
    return vmin * num
end )

Set( "vmax", function( num )
    return vmax * num
end )

local fp = 0
Set( "fp", function( num )
    return fp * num
end )

local function updateViewPort( width, height )
    fp = ( width + height ) / 3000
    vh = height / 100
    vw = width / 100

    if vh > vw then
        vmin = vw
        vmax = vh
    else
        vmin = vh
        vmax = vw
    end
end

hook_Add( "ScreenResolutionChanged", packageName, updateViewPort )
updateViewPort( util_ScreenResolution() )