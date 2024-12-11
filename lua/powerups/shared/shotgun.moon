
-- Some addons shoot multiple separate bullets instead of using the Num param.
-- Put them here so they get treated properly, with the value being a function or string to get the intended bullet count.
FORCE_MULTI_CLASSES = { -- Direct class lookup

}
FORCE_MULTI_CLASS_STARTS = { -- Anything that starts with these strings
    "cw_": "Shots"
}

forceMultiClassCache = {}
lastCommandNum = nil
commandSeedIncr = 0

isForcedMulti = (wep) ->
    wepClass = wep\GetClass!
    cached = forceMultiClassCache[wepClass]
    return cached if cached ~= nil

    getter = FORCE_MULTI_CLASSES[wepClass]

    if not getter
        for start, newGetter in *FORCE_MULTI_CLASS_STARTS
            if string.StartsWith wepClass, start
                getter = newGetter
                break

    if not getter
        forceMultiClassCache[wepClass] = false
        return false

    -- Need to also check the gun's listed bullet count, to see if it actually shoots multiple bullets or not.
    num = ( type getter == "function" ) and ( getter wep ) or wep[getter] or 1
    forcedMulti = num > 1

    forceMultiClassCache[wepClass] = forcedMulti
    return forcedMulti

-- Handles the shared logic of modifying bullets for the shotgun powerup.
class ShotgunPowerupHandler
    new: (owner, singleBulletsMin, singleBulletsMax, singleDamageMult, singleSpreadMult, singleSpreadAdd, multiBulletsMult, multiDamageMult) =>
        @owner = owner
        @singleBulletsMin = singleBulletsMin
        @singleBulletsMax = singleBulletsMax
        @singleDamageMult = singleDamageMult
        @singleSpreadMult = singleSpreadMult
        @singleSpreadAdd = singleSpreadAdd
        @multiBulletsMult = multiBulletsMult
        @multiDamageMult = multiDamageMult

        @ownerSteamID64 = @owner\SteamID64!
        @hookName = "CFC-Powerups_Shotgun-#{@ownerSteamID64}"

        @ApplyEffect!

    BulletWatcher: =>
        (ent, bullet) ->
            return unless ent == @owner

            num = bullet.Num

            -- Multi-bullet gun
            if num > 1
                bullet.Num = math.ceil bullet.Num * @multiBulletsMult
                bullet.Damage = bullet.Damage * @multiDamageMult
                return

            wep = ent\GetActiveWeapon!
            return unless IsValid wep -- Shooting bullets with your mind? Nonsense!

            commandNum = lastCommandNum

            -- Bullets on players should always be fired in a predicted hook, but for just in case...
            if GetPredictionPlayer! == ent
                commandNum = ent\GetCurrentCommand!\CommandNumber!

            -- If multiple bullets are fired in the same command (i.e. with force-multi weapons), increment the seed
            if commandNum == lastCommandNum
                commandSeedIncr = commandSeedIncr + 1
            else
                lastCommandNum = commandNum
                commandSeedIncr = 0
                wep\EmitSound "weapons/shotgun/shotgun_fire6.wav", 75, 100, 1, CHAN_WEAPON -- Play a sound to make the powerup more noticeable, but only once per command

            seed = ent\EntIndex! .. commandNum .. commandSeedIncr

            -- Single-bullet gun
            if not isForcedMulti wep
                bullet.Num = util.SharedRandom seed, @singleBulletsMin, @singleBulletsMax
                bullet.Damage = bullet.Damage * @singleDamageMult

                spread = bullet.Spread
                spreadMult = @singleSpreadMult
                spreadAdd = @singleSpreadAdd

                spread.x = spread.x * spreadMult + spreadAdd
                spread.y = spread.y * spreadMult + spreadAdd

                return

            -- Forced-multi gun
            bullet.Damage = bullet.Damage * @multiDamageMult

            multiBulletsMult = @multiBulletsMult
            newNum = math.floor multiBulletsMult
            leftover = multiBulletsMult - newNum

            if leftover > 0
                -- Leftover is used as a chance to add another bullet
                if (util.SharedRandom seed, 0, 1) < leftover
                    newNum = newNum + 1

            bullet.Num = newNum

    ApplyEffect: =>
        hook.Add "EntityFireBullets", @hookName, @BulletWatcher!

    Remove: =>
        hook.Remove "EntityFireBullets", @hookName

CFCPowerups.SharedHandlers.ShotgunPowerupHandler = ShotgunPowerupHandler
