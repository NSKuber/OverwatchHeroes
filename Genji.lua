--Preliminary setup

local Pi = 3.14159265359
local fEps = 0.01

local PV = function(vVec)
  return (vVec.x.." "..vVec.y.." "..vVec.z)
end

local path = "Content/SeriousSam3/Databases/Weapons/OW/Generic/ShurikenWeapon.ep"

--Setup for the Weapon Engine
worldGlobals.WeaponScriptedFiringParams[path] = {["Fired01"] = {},
  ["Fired01Sound"] = {},["Fired02"] = {},["Fired02Sound"] = {},["Hello"] = {},
  ["FiredDeflect"] = {},}

worldGlobals.WeaponScriptedFiringParams[path]["Fired01"][1] = {
  ["type"] = "projectile",
  ["projectile"] = "Content/SeriousSam3/Databases/Projectiles/OW/ShurikenGenji.ep",
  ["velocity"] = {72,72},
  ["source"] = "Barrel01",
  ["direction"] = "crosshair",
}

worldGlobals.WeaponScriptedFiringParams[path]["FiredDeflect"][1] = {
  ["type"] = "hitscan",
  ["source"] = "BarrelMelee",
  ["direction"] = "crosshair",
  ["damage"] = {1},
  ["noBulletTracersOnViewer"] = true,
}

worldGlobals.WeaponScriptedFiringParams[path]["Fired01"]["ammoSpent"] = 1

worldGlobals.WeaponEngineCopyFireableObject(path,"Fired01",1,path,"Fired02",1)
worldGlobals.WeaponScriptedFiringParams[path]["Fired02"][1]["source"] = "Barrel02",
worldGlobals.WeaponEngineCopyFireableObject(path,"Fired02",1,path,"Fired02",2)
worldGlobals.WeaponScriptedFiringParams[path]["Fired02"][2]["offset"] = {-9,0}
worldGlobals.WeaponEngineCopyFireableObject(path,"Fired02",1,path,"Fired02",3)
worldGlobals.WeaponScriptedFiringParams[path]["Fired02"][3]["offset"] = {9,0}

worldGlobals.WeaponScriptedFiringParams[path]["Fired02"]["ammoSpent"] = 3
worldGlobals.WeaponScriptedFiringParams[path]["Fired02"]["fireWithoutAmmo"] = true

--Setup for the main Overwatch Heroes script
worldGlobals.OWScriptedGenericWeapons[path] = {
  ["name"] = "Genji",
  ["idle"] = "Idle",
  ["primary"] = {"Fire",1},
  ["secondary"] = {"FireSecondary",0.75},
  ["reload"] = {"Reload",1.5},
  ["melee"] = "Melee",
  ["hello"] = "Hello",  
  ["abilities"] = {
    [1] = {0,"Dash",0.5,6,1},
    [2] = {0,"Deflect",2,6,1},
  },
  ["maxAmmo"] = 30,
}

worldGlobals.WeaponScriptedFiringParams[path]["Fired01Sound"]["firingSounds"] = {
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/PrimaryFire01.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/PrimaryFire02.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/PrimaryFire03.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/PrimaryFire04.wav",1,1,0.02},
}

worldGlobals.WeaponScriptedFiringParams[path]["Fired02Sound"]["firingSounds"] = {
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/SecondaryFire01.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/SecondaryFire02.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/SecondaryFire03.wav",1,1,0.02},
}

worldGlobals.WeaponScriptedFiringParams[path]["Hello"]["firingSounds"] = {
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/HelloMisc01.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/HelloMisc02.wav",1,1,0.02},
  {"Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/HelloMisc03.wav",1,1,0.02},
}

worldGlobals.OWAbilitySounds["Dash"] = {
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Dash.wav",1},
}
worldGlobals.OWAbilitySounds["GenjiReload"] = {
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Reload01.wav",1},
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Reload02.wav",1},
}
worldGlobals.OWAbilitySounds["GenjiMeleeStereo"] = {
  {"stereo","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Melee01.wav",1},
  {"stereo","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Melee02.wav",1},
}
worldGlobals.OWAbilitySounds["GenjiMeleeMono"] = {
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Melee01Mono.wav",1},
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Melee02Mono.wav",1},
}
worldGlobals.OWAbilitySounds["GenjiHello"] = {
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Hello01.wav",1},
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Hello02.wav",1},
  {"mono","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Hello03.wav",1},
}
worldGlobals.OWAbilitySounds["Deflect"] = {
  {"stereo","Content/SeriousSam3/Models/Weapons/OW/GenjiShurikens/Sounds/Deflect.wav",1},
}


local newPath = string.gsub(path,"SeriousSam3","SeriousSamHD")
worldGlobals.WeaponScriptedFiringParams[newPath] = worldGlobals.WeaponScriptedFiringParams[path]
worldGlobals.OWScriptedGenericWeapons[newPath] = worldGlobals.OWScriptedGenericWeapons[path]

newPath = "Content/SeriousSam3/Databases/Weapons/OW/ShurikenWeapon.ep"
worldGlobals.WeaponScriptedFiringParams[newPath] = {["Fired01"] = {},}
worldGlobals.WeaponScriptedFiringParams[newPath]["Fired01"][1] = worldGlobals.WeaponScriptedFiringParams[path]["Fired01"][1]
newPath = string.gsub(newPath,"SeriousSam3","SeriousSamHD")
worldGlobals.WeaponScriptedFiringParams[newPath] = {["Fired01"] = {},}
worldGlobals.WeaponScriptedFiringParams[newPath]["Fired01"][1] = worldGlobals.WeaponScriptedFiringParams[path]["Fired01"][1]

--FUNCTIONS
local worldInfo = worldGlobals.worldInfo

local fDeflectDuration = 1.8
local HitscanDamageTypes = {["Bullet"] = true, ["Slug"] = true,}

--Function which handles the invisible 'shield' used for the Deflect ability,
--catches hitscan damage from it and shoots it back
local HandleDeflectShield = function(weapon,enDeflectShield)
  RunAsync(function()
    
    enDeflectShield:TurnOnDamageReporting()
    
    RunHandled(function()
      while not IsDeleted(enDeflectShield) do
        Wait(CustomEvent("OnStep"))
      end
    end,
    
    OnEvery(Event(enDeflectShield.Damaged)),
    function(pay)
      --pay : CDamagedScriptEvent
      if HitscanDamageTypes[pay:GetDamageType()] then
        local inflictor = pay:GetInflictor()
        worldGlobals.CurrentWeaponScriptedParams[weapon]["FiredDeflect"][1]["damage"] = {pay:GetDamageAmount()}
        SignalEvent(weapon,"FiredDeflect")
      end
    end)
  end)
end

--Function which handles Genji's Deflect ability.
--Spawns invisible shield for preventing and redirecting hitscan damage
--and redirects projectiles which come close
worldGlobals.HandleGenjiDeflect = function(player,weapon)
  RunAsync(function()
    
    if not worldGlobals.netIsHost and not player:IsLocalOperator() then return end
      
    RunHandled(function()
      while not IsDeleted(player) and not IsDeleted(weapon) do
        Wait(CustomEvent("OnStep"))
      end
    end,
    
    OnEvery(CustomEvent(player,"Deflect")),
    function()

      if player:IsLocalOperator() then
        RunAsync(function()
          local pay = Wait(Any(Delay(3),CustomEvent(player,"ForcedNewAnim")))
          if (pay.any.signaledIndex == 2) then
            SignalEvent(player,"OWStopSoundDeflect")
          end
        end)
      end
      
      local vBBox = player:GetBoundingBoxSize()
      local fStretch = mthMaxF(vBBox.x,vBBox.z) + 0.1
      
      if not worldGlobals.netIsHost then return end
      
      local qvDeflectShield = player:GetPlacement()
      qvDeflectShield.qh = player:GetLookOrigin().qh 
      local vPlayerVel = player:GetLinearVelocity()
      qvDeflectShield:SetVect(qvDeflectShield:GetVect() + vPlayerVel*worldInfo:SimGetStep())      
      local enDeflectShield = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("DeflectShield",worldInfo,qvDeflectShield)
      enDeflectShield:SetStretch(fStretch)
      HandleDeflectShield(weapon,enDeflectShield)
      
      RunHandled(function()
        Wait(Any(Delay(fDeflectDuration),CustomEvent(player,"ForcedNewAnim")))
      end,
      
      OnEvery(CustomEvent("OnStep")),
      function()
        if IsDeleted(player) or IsDeleted(weapon) then return end 
        
        local fStep = worldInfo:SimGetStep()
        local qvDeflectSource = weapon:GetBarrelPlacement("BarrelMelee")
        local qvDeflectShoot = mthCloneQuatVect(qvDeflectSource)
        local qvDeflectShield = player:GetPlacement()
        local vLookDir = mthQuaternionToDirection(qvDeflectSource:GetQuat())        
        
        local vPlayerVel = player:GetLinearVelocity()
        qvDeflectShoot:SetVect(qvDeflectShoot:GetVect() + vLookDir*1 + vPlayerVel*fStep)
        qvDeflectShield.qh = player:GetLookOrigin().qh
        if IsDeleted(enDeflectShield) then
          enDeflectShield:SetStretch(fStretch)
          enDeflectShield = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("DeflectShield",worldInfo,qvDeflectShield)
          HandleDeflectShield(weapon,enDeflectShield)
        end
        enDeflectShield:SetPlacement(qvDeflectShield)
        
        local Projs = worldInfo:GetAllEntitiesOfClass("CGenericProjectileEntity")
        for _,proj in pairs(Projs) do
          --proj : CGenericProjectileEntity
          if (worldInfo:GetDistance(proj,player) < 15) then
            
            local vVel = proj:GetLinearVelocity()
            local vPos = proj:GetPlacement():GetVect()
            if (mthDotV3f(vLookDir,vVel) < 0) and (mthDotV3f(vPos - (qvDeflectSource:GetVect() - vLookDir),vLookDir) > 0) then
              
              local enHitEntity,vHitPoint,_ = CastRay(worldInfo,proj,vPos,mthNormalize(vVel),(mthLenV3f(vVel) + mthDotV3f(vPlayerVel,vLookDir))*fStep + 2,0.75,"bullet_no_solids")
              
              if enHitEntity then
                if (enHitEntity == player) then
                  proj:SetPlacement(qvDeflectShoot)
                  proj:SetLinearVelocity(vLookDir*mthLenV3f(vVel))
                end
              end
              
            end

          end
        
        end

      end)
      
      if not IsDeleted(enDeflectShield) then enDeflectShield:Delete() end
      
    end)
  end)
end

--Dash ability
local fMaxDashForgivingAngle = Pi/18
local fMinForgivingCos = mthCosF(fMaxDashForgivingAngle)
local fVerticalStep = 0.25
local vVerticalStep = mthVector3f(0,fVerticalStep,0)
local vStraightDown = mthVector3f(0,-1,0)

local fDashDistance = 18
if not worldGlobals.OWisBFE then
  fDashDistance = fDashDistance*1.15
end
local fDashTime = 0.25
local fDashAccelerationTime = 0.03
local fDashMaxSpeed = fDashDistance / (fDashTime - fDashAccelerationTime)
local fDashDamage = 70
local fShurikenIndex

local fKillMonstersForDashReset = 4
local PlayerMonsterCounts = {}

--Function which returns how much distance should be covered by the Dash in this frame
local ReturnDashTravelledDistance = function(fTime)
  if (fTime <= fDashAccelerationTime) then
    return fDashMaxSpeed * (fTime*fTime/(2*fDashAccelerationTime))
  elseif (fTime <= fDashTime - fDashAccelerationTime) then
    return fDashMaxSpeed * (fDashAccelerationTime/2 + (fTime-fDashAccelerationTime))
  else
    return fDashMaxSpeed * (fDashAccelerationTime + (fDashTime-2*fDashAccelerationTime) - mthPowAF(fDashTime-fTime,2)/(2*fDashAccelerationTime))
  end
end

--player : CPlayerPuppetEntity

local GetSolidCast = function(player,vOrigin,vDir,fDist)
  local _,vHitPoint,_ = CastRay(worldInfo,player,vOrigin,vDir,fDist,0,"character_only_solids")
  if (mthLenV3f(vHitPoint) == 0) then
    vHitPoint = vOrigin + vDir * fDist
    return vHitPoint,false
  end
  return vHitPoint,true
end

--Function which calculates how much distance will be actually
--covered by the Dash in the current frame, taking collision into account.
local GetDashRealDistance = function(player,vDashDir,fDistance)
  
  local vBBox = player:GetBoundingBoxSize()
  local vU = mthVector3f(0,vBBox.y,0)
  local vF = vDashDir * vBBox.z/2
  local vL = mthRotateVector(mthHPBToQuaternion(Pi/2,0,0),vDashDir) * vBBox.x/2
  
  local vPlayer = player:GetPlacement():GetVect()
  
  local vEndPoint = player:GetPlacement():GetVect()
  local vBaseCastOrigin = vEndPoint + vVerticalStep
  local fRemainingDist = fDistance

  while (fRemainingDist > 0) do
    
    local vHitPoint,bHitSomething = GetSolidCast(player,vBaseCastOrigin,vDashDir,fRemainingDist)
    
    if not bHitSomething then 
      local vGroundHitPoint,_ = GetSolidCast(player,vHitPoint-vStraightDown*0.001,vStraightDown,fVerticalStep)
      vEndPoint = vGroundHitPoint
      break
    end
    
    local vDiffDir = mthNormalize(vHitPoint - vEndPoint)
    local fCoveredDistance = mthLenV3f(vHitPoint - vBaseCastOrigin)
    
    if (mthDotV3f(vDiffDir,vDashDir) < fMinForgivingCos) then 
      break
    else
      
      fRemainingDist = fRemainingDist - fCoveredDistance
      
      local vGroundHitPoint,_ = GetSolidCast(player,vHitPoint-vStraightDown*0.001,vStraightDown,fVerticalStep)
      
      vEndPoint = vGroundHitPoint
      vBaseCastOrigin = vEndPoint + vVerticalStep - vDashDir*0.001
    end  
        
  end
  
  local vCastOrigins = {}
  vCastOrigins[#vCastOrigins+1] = vPlayer + vU * 0.95
  vCastOrigins[#vCastOrigins+1] = vPlayer + vU/2 + vF * 0.9
  vCastOrigins[#vCastOrigins+1] = vPlayer + vU/2 + vL * 0.9
  vCastOrigins[#vCastOrigins+1] = vPlayer + vU/2 - vL * 0.9
  
  local fMaxDistance = mthLenV3f(vEndPoint - vPlayer)
  local vNewDashDir = mthNormalize(vEndPoint - vPlayer)
  
  for i=1,#vCastOrigins,1 do
    
    local _,vHitPoint,vHitNormal = CastRay(worldInfo,player,vCastOrigins[i],vNewDashDir,fMaxDistance,0,"character_only_solids")
    if (mthLenV3f(vHitPoint) == 0) then
      vHitPoint = vCastOrigins[i] + vNewDashDir * fMaxDistance
    end
    fMaxDistance = mthMinF(fMaxDistance,mthLenV3f(vHitPoint - vCastOrigins[i]))
  
  end
  
  return (vPlayer + fMaxDistance * vNewDashDir)
  
end

--Function which handles Genji's Dash
worldGlobals.HandleGenjiDash = function(player,weapon)
  RunAsync(function()
    
    PlayerMonsterCounts[player] = 0
    local weaponPath = weapon:GetParams():GetFileName()
  
    if (fShurikenIndex == nil) then
      fShurikenIndex = player:GetWeaponIndex(weapon:GetParams())
    end
  
    RunHandled(function()
      Wait(CustomEvent("OnStep"))
      while not IsDeleted(player) and not IsDeleted(weapon) do
        if (worldGlobals.OWWeaponAbilityParams[player] ~= nil) then
          if (worldGlobals.OWWeaponAbilityParams[player][weaponPath] ~= nil) then
            if worldGlobals.OWWeaponAbilityParams[player][weaponPath][1]["activeCooldown"] == worldGlobals.OWWeaponAbilityParams[player][weaponPath][1]["maxCooldown"] then
              PlayerMonsterCounts[player] = 0
            end
          end
        end
        Wait(CustomEvent("OnStep"))
      end
    end,
    
    OnEvery(CustomEvent(player,"Dash")),
    function()
    
      --THE DAMAGING PART
      RunAsync(function()
        
        local MobHitByMelee = {}
        local qvPrevPos = weapon:GetBarrelPlacement("BarrelMelee")
        
        RunHandled(function()
          Wait(Delay(fDashTime))
        end,
        
        OnEvery(CustomEvent("OnStep")),
        function()
          if IsDeleted(player) or IsDeleted(weapon) then return end
          local qvHitOrigin = weapon:GetBarrelPlacement("BarrelMelee")
          local qvHitIntermediate = mthCloneQuatVect(qvHitOrigin)
          qvHitIntermediate:SetVect((qvHitOrigin:GetVect()+qvPrevPos:GetVect())/2)
          
          local locator01 = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("DashLocator",worldInfo,qvHitOrigin)
          local locator02 = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("DashLocator",worldInfo,qvHitIntermediate)
      
          local AllMobs = worldInfo:GetCharacters("","Evil",locator01,20)
          for i=1,#AllMobs,1 do
            if (locator01:IsInside(AllMobs[i]) or locator02:IsInside(AllMobs[i])) and not MobHitByMelee[AllMobs[i]] then
              MobHitByMelee[AllMobs[i]] = true
              if worldGlobals.netIsHost then
                local damage = fDashDamage
                if (worldGlobals.WeaponEngineIsPlayerPoweredUp[player] > 0) then
                  damage = damage * 4
                end                
                player:InflictDamageToTarget(AllMobs[i],damage,fShurikenIndex,"Cut")
              end
              worldGlobals.OWMeleeHitSound(qvHitOrigin,"Genji")
            end
          end
          
          qvPrevPos = qvHitOrigin
        
          locator01:Delete()
          locator02:Delete()
          
        end)         
      end)
      
      if not player:IsLocalOperator() then return end
      
      --The movement part
      player:EnableMovingAbility("Flying")
      
      local lookDir = player:GetLookDirEul()
      local qvLookTarget = player:GetLookOrigin()
      qvLookTarget:SetVect(qvLookTarget:GetVect()+100*mthEulerToDirectionVector(lookDir))
      local lookTarget = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("LookTarget",worldInfo,qvLookTarget)      
      lookTarget:SetParent(player,"")
      player:SetLookTarget(lookTarget) 
      
      local vSpeedMult = player:GetSpeedMultiplier()
      player:SetSpeedMultiplier(mthVector3f(0,0,0))      
      
      local timer = worldInfo:SimGetStep()
    
      --if IsDeleted(player) then return end
      
      local qvBasePlacement = player:GetPlacement()
      local qvPlacement = player:GetPlacement()
      local vDashDirection = mthQuaternionToDirection(qvLookTarget:GetQuat())
           
      local fPrevDistance = 0
      local vPrevPoint = player:GetPlacement():GetVect()
      local bFinishDash = false
      
      while not IsDeleted(player) do
        
        local fTotalDist = ReturnDashTravelledDistance(timer)

        local vFinishingPoint = vPrevPoint
        if not bFinishDash then

          vFinishingPoint = GetDashRealDistance(player,vDashDirection,fTotalDist - fPrevDistance)

          if (mthLenV3f(vFinishingPoint - vPrevPoint) < mthMinF(fTotalDist - fPrevDistance - fEps,0.01)) then
            bFinishDash = true
          end
          
        end
        
        vPrevPoint = vFinishingPoint        
        fPrevDistance = fTotalDist
        qvPlacement:SetVect(vFinishingPoint)
        player:SetPlacement(qvPlacement) 
        if (timer >= fDashTime) then break end    
        timer = mthMinF(timer + Wait(CustomEvent("OnStep")):GetTimeStep(),fDashTime)
      end
      
      if not IsDeleted(player) then
        player:DisableMovingAbility("Flying")
      end
      
      player:SetSpeedMultiplier(vSpeedMult)  
      
      Wait(CustomEvent("OnStep"))
      if not IsDeleted(lookTarget) then lookTarget:Delete() end    
    
    end)    
    
  end)
end

--Function used to track monsters killed for the Dash reset
--monster : CLeggedCharacterEntity
local HandleMonsterKilled = function(monster)
  RunAsync(function()
    --pay : CDiedScriptEvent
    local fHealth = monster:GetHealth()
    
    local pay = Wait(Event(monster.Died))
    
    local player = pay:GetKillerPlayer()
    
    if (player ~= nil) then
      local weapon = player:GetRightHandWeapon()
      if (weapon ~= nil) then
        local path = weapon:GetParams():GetFileName()
        if (string.find(path,"Generic/ShurikenWeapon") ~= nil) then
          if (worldGlobals.OWWeaponAbilityParams[player][path][1]["activeCooldown"] < worldGlobals.OWWeaponAbilityParams[player][path][1]["maxCooldown"]) then
            
            local fHeadCount
            if (fHealth > 299) then
              fHeadCount = 4
            elseif (fHealth > 199) then
              fHeadCount = 3
            elseif (fHealth > 149) then
              fHeadCount = 2
            elseif (fHealth > 99) then
              fHeadCount = 1.5
            else
              fHeadCount = 1
            end
          
            PlayerMonsterCounts[player] = PlayerMonsterCounts[player] + fHeadCount
            
            if (PlayerMonsterCounts[player] >= fKillMonstersForDashReset) then
              PlayerMonsterCounts[player] = 0
              if worldInfo:IsSinglePlayer() then
                SignalEvent(player,"DashReset")
              else
                worldGlobals.OWSignalEventServer(player,"DashReset",true)
              end
            end
            
          else
          
          end
        end
      end
    end

  end)
end

local gunPathHD = "Content/SeriousSamHD/Databases/Weapons/OW/Generic/ShurikenWeapon.ep"
local gunPathBFE = "Content/SeriousSam3/Databases/Weapons/OW/Generic/ShurikenWeapon.ep"
worldGlobals.OWWaitForWeapon(gunPathHD,gunPathBFE)

if worldGlobals.netIsHost then
  local IsHandled = {}
  while true do
    local Monsters = worldInfo:GetCharacters("","Evil",worldInfo,10000)
    for i=1,#Monsters,1 do
      if not IsHandled[Monsters[i]] then
        IsHandled[Monsters[i]] = true
        HandleMonsterKilled(Monsters[i])
      end
    end
    Wait(Delay(0.2))
  end
end