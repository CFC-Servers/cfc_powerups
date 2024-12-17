import insert, remove from table
import DrawBeam, SetMaterial from render
import Clamp, ceil, random from math
import Decompress, JSONToTable from util

class ThornManager
    new: =>
        @thorns = {}
        @thornMat = Material "cable/blue_elec"
        @thornDuration = 0.25
        @thornDamageMult = 5

        hook.Add "PostDrawTranslucentRenderables", "CFC_Powerups-ThornsRenderer", ->
            @drawThorns!

    getSparkSound: =>
        sparkNumber = random 3, 6
        "ambient/energy/spark#{sparkNumber}.wav"

    playSparkSound: (attacker) =>
        sparkSound = @getSparkSound!
        attacker\EmitSound sparkSound, 75, 100, 1

    generateThornSegments: (thorn) =>
        :ply, :attacker, :amount, :createdAt = thorn

        return unless IsValid attacker
        -- Vertical offsets
        startOffset = random 45, 50
        offset = random 20, 50

        startPos = ply\GetPos! + Vector 0, 0, startOffset
        endPos = attacker\GetPos! + Vector 0, 0, offset

        segments = {}

        segmentLength = 50
        segmentCount = ceil( startPos\Distance(endPos) / segmentLength ) + 2
        lastPos = startPos
        lastOffset = Vector 0, 0, 0

        for i = 1, segmentCount
            t = i / segmentCount

            lerpedPos = startPos * (1 - t) + endPos * t

            if i == 1
                lerpedPos = startPos

            offset = Vector 0, 0, 0

            if ( i ~= 1 ) and i ~= segmentCount
                zigZaggyness = random 10, 40
                offset = VectorRand! * zigZaggyness

            insert segments, lerpedPos + offset

            lastPos = lerpedPos
            lastOffset = offset

        thorn.segments = segments

    drawThorns: =>
        now = CurTime!

        for i, thorn in pairs @thorns
            amount = thorn.amount
            createdAt = thorn.createdAt
            segments = thorn.segments

            lifetime = now - createdAt

            if lifetime > @thornDuration
                remove @thorns, i
                continue

            for k, segment in pairs segments
                lastPos = segments[k - 1] or segment

                t = k / #segments

                widthModifier = amount * @thornDamageMult
                thornAge = 1 - lifetime / @thornDuration
                width = widthModifier * thornAge

                SetMaterial @thornMat
                DrawBeam lastPos, segment, width, 0, 0, Color(93, 227, 232)

    addThorn: (thorn) =>
        @generateThornSegments thorn
        insert @thorns, thorn
        @playSparkSound thorn.attacker

class Thorn
    new: (thornyPly, attacker, amount) =>
        @ply = thornyPly
        @attacker = attacker
        @amount = amount
        @createdAt = CurTime!

manager = ThornManager!

net.Receive "CFC_Powerups-ThornsDamage", ->
    print "Receiving thorns damage.."
    damageData = net.ReadTable!
    PrintTable damageData

    for ply, attackers in pairs damageData do
        continue unless IsValid ply

        for attacker, amount in pairs attackers
            continue unless IsValid attacker

            thorn = Thorn ply, attacker, amount
            manager\addThorn thorn

            -- Hard limit the amount of beams rendered by the client
            return if #manager.thorns >= 25