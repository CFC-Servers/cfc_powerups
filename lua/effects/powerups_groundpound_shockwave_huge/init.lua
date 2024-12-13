-- Slimmed down version of m9k_gdcw_cinematicboom from M9K

function EFFECT:Init( data )
    self.Pos = data:GetOrigin() -- Origin determines the global position of the effect
    self.Scale = data:GetScale() -- Scale determines how large the effect is
    self.DirVec = data:GetNormal() -- Normal determines the direction of impact for the effect
    self.Emitter = ParticleEmitter( self.Pos ) -- Emitter must be there so you don't get an error

    sound.Play( "ambient/explosions/explode_" .. math.random( 1, 4 ) .. ".wav", self.Pos, 100, 100 )

    self:Dust()

    self.Emitter:Finish()
end

function EFFECT:Dust()
    for _ = 1, 5 do
        local Flash = self.Emitter:Add( "effects/muzzleflash" .. math.random( 1, 4 ), self.Pos )
        if Flash then
            Flash:SetVelocity( self.DirVec * 100 )
            Flash:SetAirResistance( 200 )
            Flash:SetDieTime( 0.15 )
            Flash:SetStartAlpha( 255 )
            Flash:SetEndAlpha( 0 )
            Flash:SetStartSize( self.Scale * 300 )
            Flash:SetEndSize( 0 )
            Flash:SetRoll( math.Rand( 180, 480 ) )
            Flash:SetRollDelta( math.Rand( -1, 1 ) )
            Flash:SetColor( 255, 255, 255 )
            Flash:SetCollide( true )
        end
    end

    for _ = 1, 20 * self.Scale do
        local Dust = self.Emitter:Add( "particle/particle_composite", self.Pos )
        if Dust then
            Dust:SetVelocity( self.DirVec * math.random( 100, 400 ) * self.Scale + VectorRand():GetNormalized() * 300 * self.Scale )
            Dust:SetDieTime( math.Rand( 2, 3 ) )
            Dust:SetStartAlpha( 230 )
            Dust:SetEndAlpha( 0 )
            Dust:SetStartSize( 50 * self.Scale )
            Dust:SetEndSize( 100 * self.Scale )
            Dust:SetRoll( math.Rand( 150, 360 ) )
            Dust:SetRollDelta( math.Rand( -1, 1 ) )
            Dust:SetAirResistance( 150 )
            Dust:SetGravity( Vector( 0, 0, math.Rand( -100, -400 ) ) )
            Dust:SetColor( 80, 80, 80 )
            Dust:SetCollide( true )
        end
    end

    for _ = 1, 15 * self.Scale do
        local Dust = self.Emitter:Add( "particle/smokesprites_000" .. math.random( 1, 9 ), self.Pos )
        if Dust then
            Dust:SetVelocity( self.DirVec * math.random( 100, 400 ) * self.Scale + VectorRand():GetNormalized() * 400 * self.Scale )
            Dust:SetDieTime( math.Rand( 1, 3 ) * self.Scale )
            Dust:SetStartAlpha( 50 )
            Dust:SetEndAlpha( 0 )
            Dust:SetStartSize( 80 * self.Scale )
            Dust:SetEndSize( 100 * self.Scale )
            Dust:SetRoll( math.Rand( 150, 360 ) )
            Dust:SetRollDelta( math.Rand( -1, 1 ) )
            Dust:SetAirResistance( 250 )
            Dust:SetGravity( Vector( math.Rand( -200, 200 ), math.Rand( -200, 200 ), math.Rand( 10, 100 ) ) )
            Dust:SetColor( 90, 85, 75 )
            Dust:SetCollide( true )
        end
    end

    for _ = 1, 25 * self.Scale do
        local Debris = self.Emitter:Add( "effects/fleck_cement" .. math.random( 1, 2 ), self.Pos )
        if Debris then
            Debris:SetVelocity( self.DirVec * math.random( 0, 700 ) * self.Scale + VectorRand():GetNormalized() * math.random( 0, 700 ) * self.Scale )
            Debris:SetDieTime( math.random( 1, 2 ) * self.Scale )
            Debris:SetStartAlpha( 255 )
            Debris:SetEndAlpha( 0 )
            Debris:SetStartSize( math.random( 5, 10 ) * self.Scale )
            Debris:SetRoll( math.Rand( 0, 360 ) )
            Debris:SetRollDelta( math.Rand( -5, 5 ) )
            Debris:SetAirResistance( 40 )
            Debris:SetColor( 60, 60, 60 )
            Debris:SetGravity( Vector( 0, 0, -600 ) )
            Debris:SetCollide( true )
        end
    end
end
