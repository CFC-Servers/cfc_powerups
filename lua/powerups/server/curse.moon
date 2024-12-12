get: getConf = CFCPowerups.Config

CLICK_WINDOW = 0.5
BLACKLISTED_EFFECTS = {
    -- FullUpdate is bad in pvp, causes a several-second freeze once it ends
    EntJitter: true
    EntMagnet: true
    FreshPaint: true
    ThanosSnap: true

    -- Irrelevant in pvp
    NoclipSpam: true
    DisableNoclip: true
    TextScramble: true

    -- Too short of a duration to matter
    ColorModifyContinuous: true
    TextureShuffleContinuous: true

    -- Not fun or too unfair
    JumpExplode: true
    SprintExplode: true
    Respawn: true
    Clumsy: true
    TheFloorIsLava: true
    Drunk: true
    NoInteract: true
    Lidar: true

    -- Causes a big lagspike for the first time per session, and doesn't affect pvp a huge amount
    SoundShuffle: true
    RandomSounds: true

    -- Would be fun to include, but it'll end up causing accidental photos and toolgun clicks.
    WeaponIndecision: true

    -- Allow FilmDevelopmentNoClear, but not the regular one.
    FilmDevelopment: true
}

export CursePowerup
class CursePowerup extends BasePowerup
    @powerupID: "powerup_curse"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @UsesRemaining = getConf "curse_uses"
        @durationMin = getConf "curse_duration_min"
        @durationMax = getConf "curse_duration_max"
        @amountMin = getConf "curse_amount_min"
        @amountMax = getConf "curse_amount_max"
        @cooldown = getConf "curse_cooldown"
        @range = getConf "curse_range"
        @dotLimit = math.cos(math.rad getConf("curse_cone") / 2)

        @onCooldown = false
        @leftState = false
        @rightState = false
        @leftExpireTime = 0
        @rightExpireTime = 0

        @ApplyEffect!

    KeyPressWatcher: =>
        (ply, key) ->
            return unless ply == @owner
            return if @onCooldown

            now = CurTime!

            if key == IN_ATTACK
                @leftState = true
                @leftExpireTime = now + CLICK_WINDOW
            
            if key == IN_ATTACK2
                @rightState = true
                @rightExpireTime = now + CLICK_WINDOW
            
            return unless @leftState and @rightState
            return unless @leftExpireTime > now and @rightExpireTime > now

            @CurseBlast!

    KeyReleaseWatcher: =>
        (ply, key) ->
            return unless ply == @owner

            if key == IN_ATTACK
                @leftState = false

            if key == IN_ATTACK2
                @rightState = false

    CurseBlast: =>
        @onCooldown = true
        @UsesRemaining -= 1

        timer.Create @hookName, @cooldown, 1, ->
            @onCooldown = false

        @Remove! if @UsesRemaining <= 0

        -- TODO: Sounds and effects

        shootPos = @owner\GetShootPos!
        shootDir = @owner\GetAimVector!

        for ply in *player.GetAll!
            continue unless ply ~= @owner
            continue unless ply\IsInPvp!
            continue unless ply\Alive!
            continue if ply\HasGodMode!

            plyPos = ply\NearestPoint shootPos
            toPly = plyPos - shootPos
            dist = toPly\Length!
            continue unless dist <= @range

            toPlyDir = toPly / dist
            continue unless toPlyDir\Dot(shootDir) >= @dotLimit

            tr = util.TraceLine {
                start: shootPos
                endpos: plyPos
                filter: @owner
                mask: MASK_SHOT
            }

            continue if tr.Hit and tr.Entity ~= ply

            @Curse ply

    Curse: (ply) =>
        effectData = CFCUlxCurse.GetRandomEffect ply, BLACKLISTED_EFFECTS
        return unless effectData -- No compatible effects at this time

        duration = math.Rand @durationMin, @durationMax

        CFCUlxCurse.ApplyCurseEffect ply, effectData, duration

    ApplyEffect: =>
        super self

        @hookName = "CFC_Powerups-Curse-#{@owner\SteamID64!}"
        hook.Add "KeyPress", @hookName, @KeyPressWatcher!
        hook.Add "KeyRelease", @hookName, @KeyReleaseWatcher!

        @owner\ChatPrint "You've gained #{@UsesRemaining} Curse rounds, left and right click at the same time to use it"

    Refresh: =>
        super self

        usesGained = getConf "curse_uses"

        @UsesRemaining += usesGained
        @owner\ChatPrint "You've gained #{usesGained} extra Curse rounds (total: #{@UsesRemaining})"

    Remove: =>
        super self

        timer.Remove @hookName
        hook.Remove "KeyPress", @hookName
        hook.Remove "KeyRelease", @hookName

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Curse Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

hook.Add "CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-Curse-CheckDependencies", (_, powerupId) ->
    return unless powerupId == "powerup_curse"
    return if CFCUlxCurse

    return true, "The server does not have CFC ULX Commands installed"
