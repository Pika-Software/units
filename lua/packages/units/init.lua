install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )
local string_lower = string.lower
local string_match = string.match
local table_Empty = table.Empty
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local tonumber = tonumber
local IsValid = IsValid
local type = type
local lib = {}

-- Functions
local functions = {}

function lib.GetFunctions()
    return functions
end

function lib.GetFunction( unitsName )
    return functions[ unitsName ]
end

function lib.SetFunction( unitsName, func )
    functions[ unitsName ] = func
end

-- Cache
local cache = {}
function lib.ClearCache()
    table_Empty( cache )
end

-- Calculating
function lib.Get( str, ... )
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

    local digits, unitsName = string_match( string_lower( str ), "%s*([%d%.]+)%s*([%a%%]+)%s*" )
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
        local result = math_max( 1, math_floor( number ) )
        cache[ str ] = result
        return result
    end

    local result = func( number, ... )
    if not result then result = number end
    result = math_max( 1, math_floor( result ) )
    cache[ str ] = result
    return result
end

-- Inches ( 1in = 2.54cm = 96px )
lib.SetFunction( "in", function( number )
    return number * 96
end )

-- Centimeters ( 1cm = 37.8px = 25.2/64in )
lib.SetFunction( "cm", function( number )
    return number * 37.8
end )

-- Millimeters ( 1mm = 1/10th of 1cm )
lib.SetFunction( "mm", function( number )
    return number * 3.78
end )

-- Picas ( 1pc = 1/6th of 1in )
lib.SetFunction( "pc", function( number )
    return number * 16
end )

-- Points ( 1pt = 1/72nd of 1in )
lib.SetFunction( "pt", function( number )
    return ( number * 96 ) / 72
end )

-- Quarter-millimeters ( 1Q = 1/40th of 1cm )
lib.SetFunction( "q", function( number )
    return number * 0.945
end )

-- Width of parent panel in percent
lib.SetFunction( "%w", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetWidth() / 100 ) * num
end )

-- Height of parent panel in percent
lib.SetFunction( "%h", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    return ( parent:GetHeight() / 100 ) * num
end )

-- Percentage of size of the parent panel
lib.SetFunction( "%", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( ( ( width + height ) / 2 ) / 100 ) * num
end )

-- Percentage of minimum panel side size
lib.SetFunction( "%min", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math_min( width, height ) / 100 ) * num
end )

-- Percentage of maximum panel side size
lib.SetFunction( "%max", function( num, panel )
    if not IsValid( panel ) then return 0 end

    local parent = panel:GetParent()
    if not IsValid( parent ) then return 0 end

    local width, height = parent:GetSize()
    return ( math_max( width, height ) / 100 ) * num
end )

local vh, vw = 0, 0

-- 1% of the viewport's width
lib.SetFunction( "vw", function( num )
    return vw * num
end )

-- 1% of the viewport's height
lib.SetFunction( "vh", function( num )
    return vh * num
end )

local vmin, vmax = 0, 0

-- 1% of the viewport's smaller dimension
lib.SetFunction( "vmin", function( num )
    return vmin * num
end )

-- 1% of the viewport's larger dimension
lib.SetFunction( "vmax", function( num )
    return vmax * num
end )

local fp = 0

-- Percentage of current screen size to FullHD ( 1920x1080 )
lib.SetFunction( "fp", function( num )
    return fp * num
end )

function lib.Recompute( width, height )
    lib.ClearCache()

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

hook.Add( "ScreenResolutionChanged", "Recompute", function( width, height )
    lib.Recompute( width, height )
    lib.ClearCache()
end )

lib.Recompute( util.ScreenResolution() )
units = lib
return lib