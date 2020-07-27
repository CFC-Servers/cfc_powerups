drawHalos = () ->
    me = LocalPlayer!

    isInPvp = me\GetNWBool "CFC_PvP_Mode", false
    return unless isInPvp

    activeWeapon = me\GetActiveWeapon!
    hasWeapon = IsValid activeWeapon
    hasCameraOut = hasWeapon and activeWeapon\GetClass! == "gmod_camera"

    if hasCameraOut then return

    -- TODO: Have clients keep track of this as players gain/lose powerups
    playersWithPowerups = [ply for ply in *player.GetAll! when ply\GetNWBool("HasPowerup", false)]

    halo.Add playersWithPowerups, Color(255,0,0), 3, 3, 2, true, true
hook.Add "PreDrawHalos", "DrawPowerupHalos", drawHalos

stopPvpHalos = (ply) ->
    if ply\GetNWBool("HasPowerup", false)
        return false
hook.Add "CFC_PvP_SetPlayerHalo", "PreventPvPHalosForPowerups", stopPvpHalos
