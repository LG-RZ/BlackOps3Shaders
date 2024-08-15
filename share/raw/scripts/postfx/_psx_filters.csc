#using scripts\codescripts\struct;

#using scripts\shared\filter_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\postfx\_filters;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\postfx\_filters.gsh;
#insert scripts\postfx\_psx_filters.gsh;

#namespace psx_filters;

function init_psx_filter()
{
    if(!isdefined(level.postFxFilters))
        level.postFxFilters = [];

    if(isdefined(level.postFxFilters[FILTER_PSX]))
        return;

    // Doing posterization here is up to you
    
    posterizationPass = new Pass();
    downsamplePass = new Pass();
    upsamplePass = new Pass();
    ditherPass = new Pass();

    [[posterizationPass]]->Set(FILTER_PSX_POSTERIZATION_MATERIAL, 0, false, false);
    [[downsamplePass]]->Set(FILTER_PSX_DOWNSAMPLE_MATERIAL, 0, false, false);
    [[upsamplePass]]->Set(FILTER_PSX_UPSAMPLE_MATERIAL, 0, false, false);
    [[ditherPass]]->Set(FILTER_PSX_DITHER_MATERIAL, 0, false, false);

    filter = new Filter();

    [[filter]]->Set(FILTER_PSX, 0, posterizationPass, downsamplePass, upsamplePass, ditherPass);

    level.postFxFilters[FILTER_PSX] = filter;
}

// self == local player
function enable_psx_filter()
{
    if(!isdefined(level.postFxFilters[FILTER_PSX]))
        init_psx_filter();
    
    self filters::enable_filter(FILTER_PSX);
}

// self == local player
function disable_psx_filter()
{
    self filters::disable_filter();
}