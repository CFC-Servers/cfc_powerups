# CFC Powerups
Randomly spawning powerups

## Requirements

 - [CFC Logger](https://github.com/CFC-Servers/cfc_logger)

## Using
You can download the latest release from our [Releases](https://github.com/CFC-Servers/cfc_powerups/releases) tab, or you can clone our [`lua` branch](https://github.com/CFC-Servers/cfc_powerups/tree/lua) and use it to stay up-to-date.


## Adding a new powerup
 - Install [moonloader](https://github.com/Pika-Software/gm_moonloader) to auto-compile while developing. It even works with lua autorefresh!
 - Copy `moon/powerups/server/_template_powerup.moon` to `moon/powerups/server/your_powerup.moon`
 - Modify your new powerup file to your liking
 - Copy the `moon/entities/_powerup_template` directory to `moon/entities/powerup_your_name`
 - Modify the new entity files (self explanatory once you're in there)
 - Modify `lua/powerups/loaders/sv_powerups_init.moon` to `include` your powerup and `AddCSLuaFile` any clientside files you made (if applicable)
 - If needed, modify `lua/powerups/loaders/cl_powerups_init.moon` to include your clientside files (if you made any)

And that's it! Assuming your code runs, your new powerup should work!
