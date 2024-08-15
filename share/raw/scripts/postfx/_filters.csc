#using scripts\codescripts\struct;

#using scripts\shared\filter_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\postfx\_filters.gsh;

#namespace filters;

class Pass
{
    var material; // String
    var index; // Integer
    var hdrFilter; // Boolean
    var firstPersonOnly; // Boolean
    var numQuads; // Integer (0 -> 2048)

    constructor()
    {
        material = "";
        index = -1;
        hdrFilter = false;
        firstPersonOnly = false;
        numQuads = 0;
    }

    function SetMaterial(_Material)
    {
        material = _Material;
    }

    function SetIndex(_Index)
    {
        index = _Index;
    }

    function SetHDR(_HDR)
    {
        hdrFilter = _HDR;
    }

    function SetFirstPersonOnly(_FirstPersonOnly)
    {
        firstPersonOnly = _FirstPersonOnly;
    }

    function Set(_Material, _Index, _HDR, _FirstPersonOnly)
    {
        material = _Material;
        index = _Index;
        hdrFilter = _HDR;
        firstPersonOnly = _FirstPersonOnly;
    }
}

class Filter
{
    var name; // String
    var index; // Integer
    var passes; // Pass[]

    constructor()
    {
        name = undefined;
        index = -1;
        passes = undefined;
    }

    function Set(_Name, _Index, ...)
    {
        name = _Name;
        index = _Index;
        passes = vararg;

        for(i = 0; i < passes.size; i++)
        {
            passes[i].index = i;
        }
    }

    function Enable(localPlayer)
    {
        if(!isdefined(localPlayer))
            return false;

        if(index <= -1)
            return false;

        if(!isdefined(passes) || passes.size <= 0)
            return false;
        
        if(localPlayer.currentFilter)

        localClientNum = localPlayer.localClientNum;

        for(i = 0; i < passes.size; i++)
        {
            pass = passes[i];

            filter::map_material_helper( localPlayer, pass.material );

	        SetFilterPassMaterial( localClientNum, index, pass.index, filter::mapped_material_id( pass.material ) );
	        SetFilterPassEnabled( localClientNum, index, pass.index, true, pass.hdrFilter, pass.firstPersonOnly );
	        SetFilterPassQuads( localClientNum, index, pass.index, pass.numQuads );
        }

        return true;
    }

    function Disable(localPlayer)
    {
        if(!isdefined(localPlayer))
            return false;

        if(index <= -1)
            return false;

        if(!isdefined(passes) || passes.size <= 0)
            return false;

        localClientNum = localPlayer.localClientNum;

        for(i = 0; i < passes.size; i++)
        {
            pass = passes[i];

	        SetFilterPassMaterial( localClientNum, index, pass.index, "" );
	        SetFilterPassEnabled( localClientNum, index, pass.index, false );
	        SetFilterPassQuads( localClientNum, index, pass.index, 0 );
        }

        return true;
    }
}

REGISTER_SYSTEM( "filters", &__init__, undefined )

function __init__()
{
    level.postFxFilters = [];
}

// self == local player
function enable_filter(filterName)
{
    if(!isdefined(level.postFxFilters[filterName]))
        return false;

    if(isdefined(self.currentPostFxFilter))
        self disable_filter();

    filter = level.postFxFilters[filterName];

    [[filter]]->Enable(self);

    self.currentPostFxFilter = filterName;
}

// self == local player
function disable_filter()
{
    if(!isdefined(self.currentPostFxFilter))
        return false;

    if(!isdefined(level.postFxFilters[self.currentPostFxFilter]))
        return false;

    filter = level.postFxFilters[self.currentPostFxFilter];

    [[filter]]->Disable(self);

    self.currentPostFxFilter = undefined;

    return true;
}

function get_constant_offset(constantIndex)
{
    if(constantIndex > 7)
        constantIndex = 7;

    constantOffset = SCRIPT_VECTOR_0;
    
    switch(constantIndex)
    {
        case 0:
            constantOffset = SCRIPT_VECTOR_0;
            break;
        case 1:
            constantOffset = SCRIPT_VECTOR_1;
            break;
        case 2:
            constantOffset = SCRIPT_VECTOR_2;
            break;
        case 3:
            constantOffset = SCRIPT_VECTOR_3;
            break;
        case 4:
            constantOffset = SCRIPT_VECTOR_4;
            break;
        case 5:
            constantOffset = SCRIPT_VECTOR_5;
            break;
        case 6:
            constantOffset = SCRIPT_VECTOR_6;
            break;
        case 7:
            constantOffset = SCRIPT_VECTOR_7;
            break;
    }

    return constantOffset;
}

// self == local player
function set_constant_for_pass(constantIndex, passIndex, x, y, z, w)
{
    if(!isdefined(self.currentPostFxFilter))
        return false;

    if(!isdefined(level.postFxFilters[self.currentPostFxFilter]))
        return false;

    filter = level.postFxFilters[self.currentPostFxFilter];

    constantOffset = get_constant_offset(constantIndex);

    pass = filter.passes[passIndex];

    SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_X, x);
    SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_Y, y);
    SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_Z, z);
    SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_W, w);

    return true;
}

// self == local player
function set_constant(constantIndex, x, y, z, w)
{
    if(!isdefined(self.currentPostFxFilter))
        return false;

    if(!isdefined(level.postFxFilters[self.currentPostFxFilter]))
        return false;

    filter = level.postFxFilters[self.currentPostFxFilter];

    constantOffset = get_constant_offset(constantIndex);

    for(i = 0; i < filter.passes.size; i++)
    {
        pass = filter.passes[i];

        SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_X, x);
        SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_Y, y);
        SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_Z, z);
        SetFilterPassConstant(self.localClientNum, filter.index, pass.index, constantOffset + SCRIPT_VECTOR_W, w);
    }

    return true;
}

function create_pass(passMaterial, passIndex, hdr = false, firstPersonOnly = false)
{
    pass = new Pass();

    [[pass]]->Set(passMaterial, passIndex, hdr, firstPersonOnly);

    return pass;
}

function add_filter(filter)
{
    if(!isdefined(level.postFxFilters))
        level.postFxFilters = [];

    if(isdefined(level.postFxFilters[filter.name]))
        return;

    level.postFxFilters[filter.name] = filter;

    return filter;
}

function create_filter(filterName, filterIndex, ...)
{
    if(!isdefined(level.postFxFilters))
        level.postFxFilters = [];

    if(isdefined(level.postFxFilters[filterName]))
        return;

    filter = new Filter();

    [[filter]]->Set(filterName, filterIndex, vararg);

    level.postFxFilters[filterName] = filter;

    return filter;
}

function exists(filterName)
{
    if(!isdefined(level.postFxFilters))
        level.postFxFilters = [];
    
    return isdefined(level.postFxFilters[filterName]);
}