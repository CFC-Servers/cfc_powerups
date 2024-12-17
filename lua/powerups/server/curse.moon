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
    SeeingDouble: true

    -- Too short of a duration to matter
    ColorModifyContinuous: true
    TextureShuffleContinuous: true
    RollAimIncremental: true
    Schizophrenia: true

    -- Not fun or too unfair
    JumpExplode: true
    SprintExplode: true
    Respawn: true
    Clumsy: true
    TheFloorIsLava: true
    Drunk: true
    NoInteract: true
    Lidar: true
    Ball: true
    Blindness: true
    DoNoHarm: true
    DoSomeHarm: true
    RotatedAim: true
    InvertedAim: true
    Crouch: true
    StaggeredAim: true
    ViewPummel: true
    TopDown: true
    Trainfuck: true

    -- Causes a big lagspike for the first time per session, and doesn't affect pvp a huge amount
    SoundShuffle: true
    RandomSounds: true

    -- Would be fun to include, but it'll end up causing accidental photos and toolgun clicks.
    WeaponIndecision: true

    -- Allow FilmDevelopmentNoClear, but not the regular one.
    FilmDevelopment: true

    -- Too much nausea
    SanFransisco: true

    -- Too hard to notice or to realize what the source is
    NoHud: true
    NoJump: true
    InputDrop: true
    Rubberband: true
    SpineBreak: true
    Butterfingers: true
    HealthDrain: true
    AimSensitivity: true
    OffsetAim: true
}

util.AddNetworkString "CFC_Powerups-Curse-Start"
util.AddNetworkString "CFC_Powerups-Curse-Stop"
util.AddNetworkString "CFC_Powerups-Curse-CurseHit"

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

        @duration = getConf "curse_duration"
        @durationMin = getConf "curse_duration_min"
        @durationMax = getConf "curse_duration_max"
        @chance = getConf "curse_chance"
        @ratelimit = getConf "curse_ratelimit"

        @nextCurseTimes = {}

        @ApplyEffect!

    DamageWatcher: =>
        (victim, damageInfo) ->
            return unless victim == @owner

            attacker = damageInfo\GetAttacker!
            return if attacker == victim
            return unless IsValid attacker
            return unless attacker\IsPlayer!

            curEffects = CFCUlxCurse.GetCurrentEffects attacker
            hasNoEffects = next(curEffects) == nil

            @Curse attacker if hasNoEffects -- Always curse if they don't have one

            -- Chance to give additional curses, with a ratelimit
            return unless math.random! <= @chance

            nextCurseTime = @nextCurseTimes[attacker] or 0
            return if CurTime! < nextCurseTime

            @Curse attacker

            return nil

    Curse: (ply) =>
        effectData = CFCUlxCurse.GetRandomEffect ply, BLACKLISTED_EFFECTS
        return unless effectData -- No compatible effects at this time

        rf = RecipientFilter!
        rf\AddPlayer ply

        for i = 0, 4
            pitch = Lerp i / 5, 80, 130
            ply\EmitSound "buttons/button19.wav", 75, pitch, 0.65, CHAN_AUTO, 0, 0, rf

        ply\EmitSound "ambient/levels/prison/radio_random9.wav", 75, 100, 0.5, CHAN_AUTO, 0, 0, rf
        ply\EmitSound "ambient/levels/prison/radio_random14.wav", 75, 100, 0.5, CHAN_AUTO, 0, 0, rf

        duration = math.Rand @durationMin, @durationMax
        @nextCurseTimes[ply] = CurTime! + @ratelimit

        CFCUlxCurse.ApplyCurseEffect ply, effectData, duration

        net.Start "CFC_Powerups-Curse-CurseHit"
        net.WriteEntity @owner
        net.WriteEntity ply
        net.Broadcast!

    ApplyEffect: =>
        super self

        @ownerSteamID64 = @owner\SteamID64!
        @hookName = "CFC_Powerups-Curse-#{@ownerSteamID64}"
        hook.Add "EntityTakeDamage", @hookName, @DamageWatcher!
        timer.Create @hookName, @duration, 1, -> @Remove!

        net.Start "CFC_Powerups-Curse-Start"
        net.WriteString @ownerSteamID64
        net.Broadcast!

        @owner\ChatPrint "You've gained #{@duration} seconds of the Curse Powerup"

    Refresh: =>
        super self
        timer.Start @hookName
        @owner\ChatPrint "You've refreshed the duration of the Curse Powerup"

    Remove: =>
        super self

        timer.Remove @hookName
        hook.Remove "EntityTakeDamage", @hookName

        net.Start "CFC_Powerups-Curse-Stop"
        net.WriteString @ownerSteamID64
        net.Broadcast!

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Curse Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

hook.Add "CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-Curse-CheckDependencies", (_, powerupId) ->
    return unless powerupId == "powerup_curse"
    return if CFCUlxCurse

    return true, "The server does not have CFC ULX Commands installed"
