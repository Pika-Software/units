install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )

-- Libraries
local string = string
local math = math

-- Variables
local util_ScreenResolution = util.ScreenResolution
local table_Empty = table.Empty
local hook_Add = hook.Add
local tonumber = tonumber
local IsValid = IsValid
local type = type

module( "units" )

-- Functions
local functions = {}
function GetFunctions()
    return functions
end

function GetFunction( unitsName )
    return functions[ unitsName ]
end

function SetFunction( unitsName, func )
    functions[ unitsName ] = func
end

-- Cache
local cache = {}
function ClearCache()
    table_Empty( cache )
end

-- Calculating
function Get( str, ... )
    local cached = cache[ str ]
    if cached then
        return cached
    end

    local stringType = type( str )
    if stringType == "number" then
        cache[ str ] = str
        return str
    end

    if stringType ~= "string" then
        cache[ str ] = 0
        return 0
    end

    local digits, unitsName = string.match( string.lower( str ), "%s*([%d%.]+)%s*([%a%%]+)%s*" )
    if not digits then
        cache[ str ] = 0
        return 0
    end

    local number = tonumber( digits )
    if not number then
        cache[ str ] = 0
        return 0
    end

    local func = functions[ unitsName ]
    if not func then
        local result = math.max( 1, math.floor( number ) )
        cache[ str ] = result
        return result
    end

    local result = func( number, ... )
    if not result then
        local result = math.max( 1, math.floor( number ) )
        cache[ str ] = result
        return result
    end

    result = math.max( 1, math.floor( result ) )
    cache[ str ] = result
    return result
end

-- Inches ( 1in = 2.54cm = 96px )
SetFunction( "in", function( number )
    return number * 96
end )

-- Centimeters ( 1cm = 37.8px = 25.2/64in )
SetFunction( "cm", function( number )
    return number * 37.8
end )

-- Millimeters ( 1mm = 1/10th of 1cm )
SetFunction( "mm", function( number )
    return number * 3.78
end )

-- Picas ( 1pc = 1/6th of 1in )
SetFunction( "pc", function( number )
    return number * 16
end )

-- Points ( 1pt = 1/72nd of 1in )
SetFunction( "pt", function( number )
    return ( number * 96 ) / 72
end )

-- Quarter-millimeters ( 1Q = 1/40th of 1cm )
SetFunction( "q", function( number )
    return number * 0.945
end )

-- Width of parent panel in percent
SetFunction( "%w", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetWidth() / 100 ) * num
end )

-- Height of parent panel in percent
SetFunction( "%h", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetHeight() / 100 ) * num
end )

-- Percentage of size of the parent panel
SetFunction( "%", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( ( ( width + height ) / 2 ) / 100 ) * num
end )

-- Percentage of minimum panel side size
SetFunction( "%min", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math.min( width, height ) / 100 ) * num
end )

-- Percentage of maximum panel side size
SetFunction( "%max", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math.max( width, height ) / 100 ) * num
end )

local vh, vw = 0, 0

-- 1% of the viewport's width
SetFunction( "vw", function( num )
    return vw * num
end )

-- 1% of the viewport's height
SetFunction( "vh", function( num )
    return vh * num
end )

local vmin, vmax = 0, 0

-- 1% of the viewport's smaller dimension
SetFunction( "vmin", function( num )
    return vmin * num
end )

-- 1% of the viewport's larger dimension
SetFunction( "vmax", function( num )
    return vmax * num
end )

local fp = 0

-- Percentage of current screen size to FullHD ( 1920x1080 )
SetFunction( "fp", function( num )
    return fp * num
end )

function Recompute( width, height )
    ClearCache()

    fp = ( width + height ) / 3000
    vh = height / 100
    vw = width / 100

    if vh > vw then
        vmin = vw
        vmax = vh
        return
    end

    vmin = vh
    vmax = vw
end

hook_Add( "ScreenResolutionChanged", "ViewPortUpdate", function( width, height )
    Recompute( width, height )
    ClearCache()
end )

Recompute( util_ScreenResolution() )