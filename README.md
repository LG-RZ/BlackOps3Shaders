# BlackOps3Shaders
 A Shader Library for Black Ops III.

# Installation
 Download the latest release and extract all of the files into the Black Ops III directory.

# Contents
 PostFX Material Types (Category: 2d):
 * zm_afterlife_alcatraz
 * zm_afterlife_alcatraz_visionset
 * zm_afterlife_alcatraz_lerp
 * zm_afterlife_alcatraz_lerp_visionset
 * zm_afterlife (Whos Who)
 * zm_afterlife_visionset (Whos Who)
 * chromatic_aberration_postfx
 * downsample (used with upsample in a 2-pass filter)
 * upsample (used with downsample in a 2-pass filter)
 * fisheye
 * posterization
 * psx_dither

 Object Material Types:
 * chromatic_aberration_effect (Category: Geometry Effect)
 * lit_advanced_fullspec_pom (Category: Geometry Custom)
 * psx_lit (Category: PSX)
 * psx_lit_vertex_snap (Category: PSX)
 * psx_lit_alphatest (Category: PSX)
 * psx_lit_alphatest_vertex_snap (Category: PSX)

 GDTs:
 * postfx_templates (Contains templates for all of the listed postfx material types including the ones required for the PSX filter)
 * shader_templates (Contains templates for the object material types)

 Scripts:
 * scripts/postfx/_filters.csc
 * scripts/postfx/_filters.gsh
 * scripts/postfx/_psx_filters.csc
 * scripts/postfx/_psx_filters.gsh

# Usage
 Using a PostFX can be done in 2 ways:
 1. PostFX Bundles
    - Create a new 'postfxbundle' in APE and set looping to true and then set the material of the postfx that you want.
    - Include that 'postfxbundle' in your zone file like this `scriptbundle,your_bundle_name`.
    - In a CSC file put this `#using scripts\shared\postfx_shared;` and then you can play the postfx on a player by doing this `player thread postfx::playPostfxBundle( "your_bundle_name" );`
     
 2. Filters Script (Only recommended for filters that use more than 1 pass)
    - In your zone file add this `include,filters`
    - In your csc file add these:
      ```
      #using scripts\postfx\_filters;
      #insert scripts\postfx\_filters.gsh;
      ```
    - Example:
      - In your zone file add the materials:
        ```
        material,example_filter_material_1
        material,example_filter_material_2
        ```
      - In your csc file add these:
		```
		function init_example_filter()
		{
			if(!isdefined(level.postFxFilters))
				level.postFxFilters = [];
		
			if(isdefined(level.postFxFilters["example_filter"]))
				return;
			
			myPass1 = new Pass();
			myPass2 = new Pass();
		
			[[myPass1]]->Set("example_filter_material_1", 0, false, false);
			[[myPass2]]->Set("example_filter_material_2", 0, false, false);
		
			filter = new Filter();
		
			[[filter]]->Set("example_filter", 0, myPass1, myPass2);
		
			level.postFxFilters["example_filter"] = filter;
		}
		
		// self == local player
		function enable_example_filter()
		{
			if(!isdefined(level.postFxFilters["example_filter"]))
				init_example_filter();
			
			self filters::enable_filter("example_filter");
		}
		```
      - And you can play it on the player by doing `player enable_example_filter();`
      
 Object Materials:
 - Using object materials is very simple just make a material and assign it the desired material type and you'll be good to go.

 PSX Filter:
 - The PSX Filter is made using 4 passes and the passes are:
   - Posterization.
   - Downsample.
   - Upsample.
   - PSX Dithering.

 - To use it follow the instructions below:
   - In your zone file add:
     ```
     include,filters
     include,psx_filters
     ```
   - In your csc file add:
     ```
     #using scripts\postfx\_psx_filters;
     ```
   - And you can play the PSX filter in your csc like this `player psx_filters::enable_psx_filter();`

Previewing PostFX in APE:
 - Right Click the Viewport -> Set 'Rendering' to 'No Lighting'.
 - Right Click the Viewport -> Set 'Shape' to 'Plane'.


Black Ops II Visionset effects are using T6 vision settings and their previews aren't a 100% accurate to the game so it can be a bit brighter or darker in-game.

# Credits
* LG
* Scobulula
* Dobby
* Acerola
