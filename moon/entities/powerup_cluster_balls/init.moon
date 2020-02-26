AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

ORBS_PER_CLUSTER = 15

hook.Add "EntityRemoved", "CFC_Powerups_TriggerCombineCluster", (ent) ->
  if IsValid ent.CCBOwner and ent.IsClusterMaster
      if not string.find ent\GetClass!, "prop_combine_ball"
          return

      for i = 1, ORBS_PER_CLUSTER

          cballspawner = ents.Create "point_combine_ball_launcher"

          cballspawner\SetAngles ent\GetAngles!
          cballspawner\SetPos ent\GetPos!
          cballspawner\SetKeyValue "minspeed",1200
          cballspawner\SetKeyValue "maxspeed", 1200
          cballspawner\SetKeyValue "ballradius", "15"
          cballspawner\SetKeyValue "ballcount", "1"
          cballspawner\SetKeyValue "maxballbounces", "30"
          cballspawner\SetKeyValue "launchconenoise", 180
          cballspawner\Spawn!
          cballspawner\Activate!
          cballspawner\Fire "LaunchBall"
          cballspawner\Fire "kill", "", 0

          pos = ent:GetPos!
          owner = ent.CCBOwner

          timer.Simple 0.01, ->
              foundEnts = ents.FindInSphere pos, 20

              for found in *foundEnts
                  exists = IsValid found
                  isBall = found\GetClass! == "prop_combine_ball"
                  isOwnerless = not IsValid v\GetOwner!

                  if exists and isBall and isOwnerless
                      found\SetOwner owner
                      found.IsCluster = true
                      found\GetPhysicsObject!\AddGameFlag FVPHYSICS_WAS_THROWN
                      found\Fire "explode", "", 14

ENT.PowerupEffect = (ply) =>
    print "Test!"
