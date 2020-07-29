# CFC Powerups
Randomly spawning powerups

## Requirements

 - [CFC Logger](https://github.com/CFC-Servers/cfc_logger)

## Using
Because Powerups is a Moonscript addon, you'll need to use a tool to compile it into Lua.
Numerous tools exist for this purpose, I'll leave it up to you to do some quick research on how to do this for your platform.
(Eventually we'll be placing compiled versions in the GitHub releases tab)

Once you have the compiled lua, you can just plop the whole thing into your addons directory.


## Adding a new powerup
 - Copy `moon/powerups/server/_template_powerup.moon` to `moon/powerups/server/your_powerup.moon`
 - Modify your new powerup file to your liking
 - Copy the `moon/entities/_powerup_template` directory to `moon/entities/powerup_your_name`
 - Modify the new entity files (self explanatory once you're in there)
 - Modify `moon/autorun/server/sv_powerups_init.moon` to `include` your powerup and `AddCSLuaFile` any clientside files you made (if applicable)
 - If needed, modify `moon/autorun/client/cl_powerups_init.moon` to include your clientside files (if you made any)

And that's it! Assuming your code runs, your new powerup should work!
