--Script handling general animations and abilities code for Overwatch Heroes mod
--By NSKuber

--Preliminary setup
worldGlobals.OWScriptedGenericWeapons = {}
worldGlobals.OWUsedScriptedGenericWeapons = {}

worldGlobals.OWAbilitySounds = {}
worldGlobals.OWLastForcedNewAnim = {}
worldGlobals.OWLastChargedShot = {}

local worldInfo = worldGlobals.worldInfo

--player : CPlayerPuppetEntity

local rscCDEndedSound = LoadResource("Content/SeriousSam3/Models/Weapons/OW/Shared/Sounds/AbilityOffCooldown.wav")
local rscAbilityBlockedSound = LoadResource("Content/SeriousSam3/Models/Weapons/OW/Shared/Sounds/AbilityUnavailable.wav")
local enAbilityBlockedSound

local Keybinds = {["Primary"] = "Mouse Button 1", ["Secondary"] = "Mouse Button 2",
    ["Ability 1"] = "Left Shift", ["Ability 2"] = "E", ["Melee"] = "F",}
local AbilityNumToCommand = {[0] = "plcmdAltFire", [1] = "plcmdSprint", [2] = "plcmdUse",}

local fMeleeDamage = 45
local qNullQuat = mthHPBToQuaternion(0,0,0)

local PlayAbilityBlockedSound = function(player)
  RunAsync(function()
    enAbilityBlockedSound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("AnaHealedSound",worldInfo,player:GetPlacement())
    enAbilityBlockedSound:SetSound(rscAbilityBlockedSound)
    enAbilityBlockedSound:SetVolume(0.5)
    Wait(enAbilityBlockedSound:PlayOnceWait(0,0))
    if not IsDeleted(enAbilityBlockedSound) then enAbilityBlockedSound:Delete() end
  end)
end

--General function for playing different sounds for abilities
local EffectResources = {}
worldGlobals.OWPlayRandom3DSound = function(player,strName)
  RunAsync(function()
    
    if (string.find(strName,"Melee") ~= nil) or (strName == "Wraith") then
      if player:IsLocalViewer() then strName = strName.."Stereo"
      else strName = strName.."Mono" end
    end   

    local SoundsTable = worldGlobals.OWAbilitySounds[strName]
    if (SoundsTable == nil) then return end
  
    local Sound = SoundsTable[mthRndRangeL(1,#SoundsTable)]
    local path = Sound[2]
    if (EffectResources[path] == nil) then
      EffectResources[path] = LoadResource(path)
    end
    
    local sound
    
    local qvPlace = player:GetPlacement()
    qvPlace.vy = qvPlace.vy + 1
    
    if (Sound[1] == "stereo") then
      if player:IsLocalViewer() then
        sound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("EmptySoundStereo",worldInfo,qvPlace)
      end
    else
      if player:IsLocalViewer() then
        sound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("EmptySound",worldInfo,qvPlace)
      else
        sound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("EmptySound3D",worldInfo,qvPlace)
      end
    end
    
    if IsDeleted(sound) then return end
    
    --sound : CStaticSoundEntity
    sound:SetVolume(Sound[3])
    sound:SetParent(player,"")
    sound:SetSound(EffectResources[path])
    Wait(Any(sound:PlayOnceWait(0,0),CustomEvent(player,"OWStopSound"..strName))) 
    if not IsDeleted(sound) then sound:Delete() end
  end)
  
end

--Function which displays an icon over the head of the player who uses an ability
worldGlobals.OWShowAbilityIcon = function(player,strName)
  RunAsync(function()    
    if (string.find(strName,"Hello") ~= nil) then strName = "Hello" end
    local strParticle = "Content/SeriousSam3/Models/Weapons/OW/Shared/Presets/"..strName..".pfx"
    if not scrFileExists(strParticle) then return end
    
    if (EffectResources[strParticle] == nil) then
      EffectResources[strParticle] = LoadResource(strParticle)
    end  
    
    local qvPlayer = player:GetPlacement()
    qvPlayer.vy = qvPlayer.vy + player:GetBoundingBoxSize().y*1.1
    
    local particle = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("EmptyAbilityEffect",worldInfo,qvPlayer)
    particle:ChangeEffect(EffectResources[strParticle])
    particle:SetParent(player,"")
    --particle : CParticleEffectEntity
    particle:Start()

    Wait(CustomEvent("OnStep"))
    Wait(Any(CustomEvent(player,"ClearedCustomAnim"),CustomEvent(player,"ForcedNewAnim"),Event(player.Died)))
    if not IsDeleted(particle) then particle:Delete() end
  end)

end

--Function which handles the HUD abilities/cooldown visuals
local SetAbilityVisuals = function(weapon,i,Ability)
  --COOLDOWNS VISUALS
  
  local cd = (Ability["activeCooldown"] % Ability["cooldown"])
  
  if (Ability["charges"] > 1) then
    
    local charges = mthFloorF(Ability["activeCooldown"] / Ability["cooldown"])
    weapon:SetShaderArgValFloat("Charges"..i, 0.0095 + 0.0625 * charges)
    --charges visuals
    if (Ability["activeCooldown"] < Ability["maxCooldown"]) then
      weapon:SetShaderArgValCOLOR("CooldownCircleColor"..i, 255,192,0,160)
      weapon:SetShaderArgValFloat("CooldownCircle"..i, cd / Ability["cooldown"] * 0.25 + 0.002)
      weapon:SetShaderArgValCOLOR("CooldownCircleBorder"..i, 0,0,0,0)
    else
      weapon:SetShaderArgValCOLOR("CooldownCircleColor"..i, 255,255,255,160)
      weapon:SetShaderArgValFloat("CooldownCircle"..i, 0.252)
      weapon:SetShaderArgValCOLOR("CooldownCircleBorder"..i, 0,0,0,0)
    end
    
    if (Ability["activeCooldown"] < Ability["cooldown"]) then
      weapon:SetShaderArgValCOLOR("CooldownBorder"..i, 255,0,0,64)
      weapon:SetShaderArgValFloat("CooldownOnOff"..i, 0.575)
      weapon:SetShaderArgValCOLOR("CooldownColor"..i, 255,0,0,64)       
    else
      weapon:SetShaderArgValCOLOR("CooldownBorder"..i, 0,0,0,160)
      weapon:SetShaderArgValFloat("CooldownOnOff"..i, 0.075)
      weapon:SetShaderArgValCOLOR("CooldownColor"..i, 255,255,255,160)   
    end
    weapon:SetShaderArgValFloat("Cooldown"..i, 0.6)
    weapon:SetShaderArgValFloat("Timer"..i, 0.75) 
    weapon:SetShaderArgValFloat("Timer1"..i, 0.75)
    weapon:SetShaderArgValFloat("Timer2"..i, 0.75)                 
    
  else
    
    weapon:SetShaderArgValCOLOR("CooldownBorder"..i, 0,0,0,160)
    --disable charges visuals
    weapon:SetShaderArgValFloat("Charges"..i, 0.75)
    weapon:SetShaderArgValFloat("CooldownCircle"..i, 0.6)
    weapon:SetShaderArgValCOLOR("CooldownCircleBorder"..i, 0,0,0,0) 

    if (Ability["activeCooldown"] < Ability["cooldown"]) then
      weapon:SetShaderArgValFloat("CooldownOnOff"..i, 0.575)
      weapon:SetShaderArgValCOLOR("CooldownColor"..i, 255,255,255,64)
      weapon:SetShaderArgValFloat("Cooldown"..i, cd / Ability["cooldown"] * 0.25)
      local displayCD = mthMinF(mthCeilF(Ability["cooldown"] - cd),99)
      if (displayCD < 10) then
        weapon:SetShaderArgValFloat("Timer"..i, 0.008 + 0.0625 * displayCD)
        weapon:SetShaderArgValFloat("Timer1"..i, 0.75)
        weapon:SetShaderArgValFloat("Timer2"..i, 0.75)
      else
        weapon:SetShaderArgValFloat("Timer"..i, 0.75)
        weapon:SetShaderArgValFloat("Timer1"..i, 0.008 + 0.0625 * (displayCD-displayCD%10)/10)
        weapon:SetShaderArgValFloat("Timer2"..i, 0.008 + 0.0625 * (displayCD%10))        
      end
    else
      weapon:SetShaderArgValFloat("CooldownOnOff"..i, 0.075)
      if (Ability["type"] > 1) and (Ability["active"]) then
        weapon:SetShaderArgValCOLOR("CooldownColor"..i, 255,192,0,160)
      else
        weapon:SetShaderArgValCOLOR("CooldownColor"..i, 255,255,255,160)
      end     
      weapon:SetShaderArgValFloat("Cooldown"..i, 0.6)
      weapon:SetShaderArgValFloat("Timer"..i, 0.75)
      weapon:SetShaderArgValFloat("Timer1"..i, 0.75)
      weapon:SetShaderArgValFloat("Timer2"..i, 0.75)      
    end
    
  end
end

local leftPromptTFX = LoadResource("Content/SeriousSam3/Models/Weapons/OW/ReaperShotguns/Presets/TeleportPromptLeft.tfx")
local rightPromptTFX = LoadResource("Content/SeriousSam3/Models/Weapons/OW/ReaperShotguns/Presets/TeleportPromptRight.tfx")

--Targeting function for targeting abilities (ex. Reaper's Shadowstep)
local fMaxTargetDistance = 60
if not worldGlobals.OWisBFE then
  fMaxTargetDistance = fMaxTargetDistance * 1.2
end
local fHookDownwardCast = 1
local fFinishDownwardCast = 3
local fHookCheckIntervals = 0.2
local fStepFromHit = 0.3
local fMaxNumberOfCasts = mthRoundF(fMaxTargetDistance/fHookCheckIntervals)

local vDownwardDir = mthVector3f(0,-1,0)

local FindTargetForTargetingAbility = function(player)
  local vCastOrigin = player:GetLookOrigin():GetVect()
  local vCastDir = mthQuaternionToDirection(player:GetLookOrigin():GetQuat())
  
  local vLastGoodPoint
  local vLastGoodNormal
  
  local vLastHookedPoint
  local vLastHookedNormal
  
  for i=1,fMaxNumberOfCasts,1 do
    local _,vHitPoint,vHitNormal = CastRay(worldInfo,player,vCastOrigin,vCastDir,fHookCheckIntervals,0,"character_only_solids")
    if (mthLenV3f(vHitPoint) ~= 0) then 
      vLastGoodPoint = vHitPoint
      vLastGoodNormal = vHitNormal
      break
    else
      local _,vDownHitPoint,vDownHitNormal = CastRay(worldInfo,player,vCastOrigin+vCastDir*fHookCheckIntervals,vDownwardDir,fHookDownwardCast,0,"character_only_solids")
      if (mthLenV3f(vDownHitPoint) ~= 0) then 
        vLastHookedPoint = vDownHitPoint
        vLastHookedNormal = vDownHitNormal
      end
    end
    vCastOrigin = vCastOrigin+vCastDir*fHookCheckIntervals
  end
  
  if (vLastGoodPoint ~= nil) then
    local _,vDownHitPoint,_ = CastRay(worldInfo,player,vLastGoodPoint+fStepFromHit*vLastGoodNormal,vDownwardDir,fFinishDownwardCast,0,"character_only_solids")
    if (mthLenV3f(vDownHitPoint) ~= 0) then 
      vLastGoodPoint = vDownHitPoint
    else
      vLastGoodPoint = nil
    end
  end
  
  if (vLastGoodPoint == nil) then
    vLastGoodPoint = vLastHookedPoint
    vLastGoodNormal = vLastHookedNormal
    if (vLastGoodPoint ~= nil) then
      local _,vDownHitPoint,_ = CastRay(worldInfo,player,vLastGoodPoint+fStepFromHit*vLastGoodNormal,vDownwardDir,fFinishDownwardCast,0,"character_only_solids")
      if (mthLenV3f(vDownHitPoint) ~= 0) then 
        vLastGoodPoint = vDownHitPoint
      else
        vLastGoodPoint = nil
      end
    end
  end
  
  return vLastGoodPoint
  
end

worldGlobals.OWWeaponAbilityParams = {}
worldGlobals.OWWeaponOwner = {}
worldGlobals.OWCurrentWeaponParamsTable = {}
worldGlobals.OWPlayingCustomAnim = {}
worldGlobals.OWWeaponCharge = {}

local strMeleeCommand = "plcmdOWMelee"
if corIsAppEditor() then strMeleeCommand = "plcmdTobiiResetDefaultHeadPose" end

--Main function which handles the Overwatch hero weapon

local HandleWeapon = function(player,weapon,ParamsTable)

RunAsync(function()
  
  --Preliminary setup
  
  worldGlobals.OWCurrentWeaponParamsTable[player] = {}
  for name, Item in pairs(ParamsTable) do
    worldGlobals.OWCurrentWeaponParamsTable[player][name] = Item
  end
  ParamsTable = worldGlobals.OWCurrentWeaponParamsTable[player]
  worldGlobals.OWWeaponCharge[player] = 0
  
  local bActivated = false
  RunAsync(function()  
    Wait(CustomEvent(weapon,"Activated"))
    player:PlayCustomAnimOnWeapon("",0,false)
    player:PlayCustomAnimOnWeapon(worldGlobals.OWCurrentWeaponParamsTable[player]["idle"],0,true)
    bActivated = true
  end)
  
  --weapon : CWeaponEntity
  local fWeaponIndex = player:GetWeaponIndex(weapon:GetParams())
  local fDesiredWeaponIndex = fWeaponIndex
  worldGlobals.OWWeaponOwner[weapon] = player  
  
  local fFiringTimer = 0
  local bFiringPrimary = false
  local bFiringSecondary = false
  
  local bChargingPrimary = false
  local bChargingSecondary = false
  
  local bFirePressed = false
  local bAltFirePressed = false  
  local bFireReleased = true
  local bAltFireReleased = true
  
  local bMeleePressed = false
  local bMeleeActive = false
  local fMeleeCooldown = 1
  local bMeleeHitting = false
  local MobHitByMelee = {}
  
  local bReloadPressed = false
  local bReloading = false 
   
  local bHelloPressed = false
  local bHelloing = false  

  local bFreeToFire = true
  local bFreeToAbility = true
  local bIsSwitchingWeapons = false
  
  local bHasPrimary = false
  local bHasSecondary = false
  local bHasPrimaryCharged = false
  local bHasSecondaryCharged = false  
  local bHasReload = false
  
  local bPrimarySwitch = 0
  local bSecondarySwitch = 0
  
  worldGlobals.OWPlayingCustomAnim[player] = false
  worldGlobals.OWLastForcedNewAnim[player] = worldInfo:SimNow()

  if (ParamsTable["reload"] ~= nil) then bHasReload = true end

  local params = weapon:GetParams()
  local maxAmmo = ParamsTable["maxAmmo"]
  local path = params:GetFileName()
  
  if (worldGlobals.OWWeaponAbilityParams[player] == nil) then
    worldGlobals.OWWeaponAbilityParams[player] = {}
  end
  
  if (worldGlobals.OWWeaponAbilityParams[player][path] == nil) then
    if worldGlobals.netIsHost then
      player:SetAmmoForWeapon(params,ParamsTable["maxAmmo"])
    end
    worldGlobals.OWWeaponAbilityParams[player][path] = {}
    for i,Ability in pairs(ParamsTable["abilities"]) do 
      worldGlobals.OWWeaponAbilityParams[player][path][i] = {}
      worldGlobals.OWWeaponAbilityParams[player][path][i]["type"] = ParamsTable["abilities"][i][1]
      if (type(ParamsTable["abilities"][i][2]) == "string") then
        worldGlobals.OWWeaponAbilityParams[player][path][i]["animation"] = function() return ParamsTable["abilities"][i][2] end
      else
        worldGlobals.OWWeaponAbilityParams[player][path][i]["animation"] = ParamsTable["abilities"][i][2]
      end
      worldGlobals.OWWeaponAbilityParams[player][path][i]["animTime"] = ParamsTable["abilities"][i][3]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["cooldown"] = ParamsTable["abilities"][i][4]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["charges"] = ParamsTable["abilities"][i][5]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["pressed"] = false
      worldGlobals.OWWeaponAbilityParams[player][path][i]["active"] = false
      worldGlobals.OWWeaponAbilityParams[player][path][i]["releasedAfterLastActivation"] = true
      worldGlobals.OWWeaponAbilityParams[player][path][i]["activeCooldown"] = ParamsTable["abilities"][i][4] * ParamsTable["abilities"][i][5]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["maxCooldown"] = ParamsTable["abilities"][i][4] * ParamsTable["abilities"][i][5]
    end
  else
    for i,Ability in pairs(ParamsTable["abilities"]) do 
      worldGlobals.OWWeaponAbilityParams[player][path][i]["pressed"] = false
      worldGlobals.OWWeaponAbilityParams[player][path][i]["active"] = false
      worldGlobals.OWWeaponAbilityParams[player][path][i]["cooldown"] = ParamsTable["abilities"][i][4]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["charges"] = ParamsTable["abilities"][i][5]
      worldGlobals.OWWeaponAbilityParams[player][path][i]["maxCooldown"] = ParamsTable["abilities"][i][4] * ParamsTable["abilities"][i][5] 
    end    
  end
  
  local AbilityParams = worldGlobals.OWWeaponAbilityParams[player][path]
  
  for i,Params in pairs(AbilityParams) do 
    SetAbilityVisuals(weapon,i,Params)
  end  
  
  for i,Params in pairs(AbilityParams) do
    Params["pressed"] = false
    local wasNotFull = (Params["activeCooldown"] ~= Params["maxCooldown"])
    Params["activeCooldown"] = mthMinF(Params["maxCooldown"], Params["activeCooldown"] + worldInfo:SimGetStep())
    local isFull = (Params["activeCooldown"] == Params["maxCooldown"])
    if wasNotFull and isFull and player:IsLocalViewer() then
      RunAsync(function()
        local cooldownEndedSound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("AnaHealedSound",worldInfo,player:GetPlacement())
        cooldownEndedSound:SetSound(rscCDEndedSound)
        cooldownEndedSound:SetVolume(0.5)
        Wait(cooldownEndedSound:PlayOnceWait(0,0))
        if not IsDeleted(cooldownEndedSound) then cooldownEndedSound:Delete() end
      end)
    end
  end
  
  if not worldInfo:IsSinglePlayer() then
    if worldGlobals.netIsHost then
      Wait(Delay(0.05))
      if IsDeleted(player) then return end
      player:SetPrimaryAmmo(0)
      player:SetSecondaryAmmo(0)    
    else
      Wait(Delay(0.1))
    end
  else
    player:SetPrimaryAmmo(0)
    player:SetSecondaryAmmo(0)  
  end
  
  --RUNHANDLED STARTS
  RunHandled(function()
    while not IsDeleted(weapon) and not IsDeleted(player) do
      Wait(CustomEvent("OnStep"))
    end
    
    --Checking weapon switch target when the weapon has already been 'stored'
    if IsDeleted(weapon) then
      bIsSwitchingWeapons = false
      local bIsPressed = false
      while not IsDeleted(player) do
        if not player:IsLocalOperator() then break end
        if not player:IsAlive() then break end
        if (player:GetRightHandWeapon() ~= nil) then break end
        
        --WEAPON SWITCHING
        if player:IsCommandPressed("plcmdToggleLastWeapon") then
          if (worldGlobals.OWPreviousWeaponIndex[player] ~= nil) then
            if (fDesiredWeaponIndex ~= worldGlobals.OWPreviousWeaponIndex[player]) then
              fDesiredWeaponIndex = worldGlobals.OWPreviousWeaponIndex[player]
            else
              fDesiredWeaponIndex = fWeaponIndex
            end
          end
        end
        
        fDesiredWeaponIndex,bIsPressed = worldGlobals.OWCheckDesiredWeapon(player,fDesiredWeaponIndex)
        if bIsPressed and not bIsSwitchingWeapons then
            
          bIsSwitchingWeapons = true
          worldGlobals.OWWeaponSwitch(player,fDesiredWeaponIndex)
          break
        end 
        
        Wait(CustomEvent("OnStep"))   
            
      end
    end
    
  end,
  
  OnEvery(CustomEvent("OWSendAssignedWeapons")),
  function()
    Wait(Delay(0.5*mthRndF()))
    if not IsDeleted(weapon) then
      worldGlobals.OWWeaponNetAssigned(weapon)
    end
  end,
  
  OnEvery(CustomEvent("OWResetParams")),
  function(pay)
    if (pay.p == worldGlobals.OWScriptedGenericWeapons[path]["name"]) then
      AbilityParams[pay.i]["cooldown"] = pay.cd
      AbilityParams[pay.i]["charges"] = pay.ch
      AbilityParams[pay.i]["maxCooldown"] = pay.cd * pay.ch
    end
  end,
  
  On(CustomEvent(weapon,"Deactivated")),
  function()
    bActivated = false
  end,
  
  OnEvery(CustomEvent(weapon,"FireInterruptible")),
  function()
    bFreeToAbility = true
  end,
  
  OnEvery(CustomEvent(weapon,"FireRechargeable")),
  function()
    bFreeToFire = true
  end,  

  OnEvery(CustomEvent(weapon,"Reloaded")),
  function()
    if IsDeleted(weapon) or IsDeleted(player) then return end
    if worldGlobals.netIsHost then
      player:SetAmmoForWeapon(params,maxAmmo)
    end
  end, 
  
  OnEvery(CustomEvent(weapon,"MeleeStarted")),
  function()
    bMeleeHitting = true
    MobHitByMelee = {}
  end,
  
  OnEvery(CustomEvent(weapon,"MeleeEnded")),
  function()
    bMeleeHitting = false
  end,  
  
  OnEvery(CustomEvent(player,"OWPickedUpWeapon")),
  function(pay)
    fDesiredWeaponIndex = pay.index
  end,
  
  OnEvery(CustomEvent(player,"DashReset")),
  function()
    if (ParamsTable["name"] == "Genji") then
      if (AbilityParams[1]["activeCooldown"] < AbilityParams[1]["maxCooldown"]) then
        AbilityParams[1]["activeCooldown"] = AbilityParams[1]["maxCooldown"] - 0.002
      end
    end
  end,
  
  OnEvery(CustomEvent(player,ParamsTable["name"].."ChargingPrimary")),
  function()
    if not player:IsLocalOperator() then
      bChargingPrimary = true
      fFiringTimer = 0
      Wait(Any(CustomEvent(player,"ForcedNewAnim"),CustomEvent(player,"ClearedCustomAnim")))
      bChargingPrimary = false
    end
  end,
    
  OnEvery(CustomEvent("OnStep")),
  function()
 
    if IsDeleted(player) or IsDeleted(weapon) then return end
    
    --Handling weapon switching from the script since, unfortunately
    --PlayCustomAnimOnWeapon() function 'blocks' the weapon (a non-resolved engine bug)
    --And we have to forcefully 'delete' the weapon from script to switch from it
    if player:IsLocalOperator() then
      
      if player:IsCommandPressed("plcmdToggleLastWeapon") then
        if (worldGlobals.OWPreviousWeaponIndex[player] ~= nil) then
          if (fDesiredWeaponIndex ~= worldGlobals.OWPreviousWeaponIndex[player]) then
            fDesiredWeaponIndex = worldGlobals.OWPreviousWeaponIndex[player]
          else
            fDesiredWeaponIndex = fWeaponIndex
          end
        end
      end
    
      fDesiredWeaponIndex = worldGlobals.OWCheckDesiredWeapon(player,fDesiredWeaponIndex)
      if (fDesiredWeaponIndex ~= fWeaponIndex) and bFreeToAbility and (bFreeToFire or bReloading) and not bIsSwitchingWeapons then
        
        bIsSwitchingWeapons = true
        worldGlobals.OWWeaponPlayAnimClient(player,"Deactivate",0.1,false)
        Wait(Any(Delay(0.5),CustomEvent(weapon,"Switch")))
        worldGlobals.OWWeaponSwitch(player,fDesiredWeaponIndex)
        Wait(Delay(0.5))
        if not IsDeleted(weapon) then bIsSwitchingWeapons = false end
        
        return
        
      end
    end
    
    --Apply melee damage and create melee hit sounds if a melee is active
    if bMeleeHitting  then 
      
      local qvHitOrigin = player:GetLookOrigin()
      
      if worldGlobals.OWisBFE then
        qvHitOrigin:SetVect(qvHitOrigin:GetVect()+1.2*mthQuaternionToDirection(qvHitOrigin:GetQuat()))
      else
        qvHitOrigin:SetVect(qvHitOrigin:GetVect()+1.6*mthQuaternionToDirection(qvHitOrigin:GetQuat()))
      end
      local locator = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("MeleeLocator",worldInfo,qvHitOrigin)
    
      local AllMobs = worldInfo:GetCharacters("","Evil",locator,20)
      for i=1,#AllMobs,1 do
        if locator:IsInside(AllMobs[i]) and not MobHitByMelee[AllMobs[i]] then
          MobHitByMelee[AllMobs[i]] = true
          if worldGlobals.netIsHost then
            local damage = fMeleeDamage
            if (worldGlobals.WeaponEngineIsPlayerPoweredUp[player] > 0) then
              damage = damage * 4
            end
            player:InflictDamageToTarget(AllMobs[i],damage,fWeaponIndex,"Punch")
          end
          worldGlobals.OWMeleeHitSound(qvHitOrigin,ParamsTable["name"])
        end
      end
      locator:Delete()
      
      qvHitOrigin = player:GetLookOrigin()
      local enHitEntity,_,_ = CastRay(worldInfo,player,qvHitOrigin:GetVect(),mthQuaternionToDirection(qvHitOrigin:GetQuat()),2,0.75,"character_only_solids")
      if enHitEntity then
        if (enHitEntity:GetClassName() == "CStaticModelEntity") and not MobHitByMelee[enHitEntity] then
          MobHitByMelee[enHitEntity] = true
          if worldGlobals.netIsHost then
            player:InflictDamageToTarget(enHitEntity,fMeleeDamage,fWeaponIndex,"Punch")
          end          
          worldGlobals.OWMeleeHitSound(qvHitOrigin,ParamsTable["name"])
        end
      end
      
    end    
    
    --SET ABILITY VISUALS
    for i,Params in pairs(AbilityParams) do 
      SetAbilityVisuals(weapon,i,Params)
    end
    
    --Add time to cooldowns and play sound if CD is finished
    for i,Params in pairs(AbilityParams) do
      local wasNotFull = (Params["activeCooldown"] ~= Params["maxCooldown"])
      Params["activeCooldown"] = mthMinF(Params["maxCooldown"], Params["activeCooldown"] + worldInfo:SimGetStep())
      local isFull = (Params["activeCooldown"] == Params["maxCooldown"])
      if wasNotFull and isFull and player:IsLocalViewer() then
        RunAsync(function()
          local cooldownEndedSound = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("AnaHealedSound",worldInfo,player:GetPlacement())
          cooldownEndedSound:SetSound(rscCDEndedSound)
          cooldownEndedSound:SetVolume(0.5)
          Wait(cooldownEndedSound:PlayOnceWait(0,0))
          if not IsDeleted(cooldownEndedSound) then cooldownEndedSound:Delete() end
        end)
      end
    end
    fMeleeCooldown = mthMinF(1,fMeleeCooldown + worldInfo:SimGetStep())
    
    --If the weapon has not yet 'Activated' or, conversely, has already been 'stored', do nothing
    if not bActivated then return end

    --Checking which buttons are pressed this frame
    bHasPrimary = (ParamsTable["primary"] ~= nil)
    bHasSecondary = (ParamsTable["secondary"] ~= nil)
    bHasPrimaryCharged = (ParamsTable["primaryCharged"] ~= nil)
    bHasSecondaryCharged = (ParamsTable["secondaryCharged"] ~= nil) 
    
    bFirePressed = false
    bAltFirePressed = false
    bReloadPressed = false
    bMeleePressed = false
    bHelloPressed = false
    
    local ammo = player:GetAmmoForWeapon(params)
    if player:IsLocalOperator() then
      if (ammo == 0) and bHasReload then bReloadPressed = true end
      
      if (player:GetCommandValue("plcmdFire") > 0) then bFirePressed = true 
      else bFireReleased = true end
      
      if (player:GetCommandValue("plcmdAltFire") > 0) then bAltFirePressed = true 
      else bAltFireReleased = true end      
      
      if (player:GetCommandValue("plcmdReload") > 0) and bHasReload then bReloadPressed = true end
      if (player:GetCommandValue("plcmdVoiceComm") > 0) then bHelloPressed = true end
      if (player:GetCommandValue(strMeleeCommand) > 0) then bMeleePressed = true end 
      
      for i,Params in pairs(AbilityParams) do 
        if (player:GetCommandValue(AbilityNumToCommand[i]) > 0) then
          --PLAY SOUND IF ABILITY UNAVAILABLE
          if not Params["pressed"] then
            if (Params["activeCooldown"] < Params["cooldown"]) and IsDeleted(enAbilityBlockedSound) then
              PlayAbilityBlockedSound(player)
            end            
          end
          
          Params["pressed"] = true
        else
          Params["releasedAfterLastActivation"] = true
          Params["pressed"] = false
        end
      end   
      
    end

    --REGULAR PRIMARY FIRE WHEN HELD DOWN FOR THE OPERATOR OF THE WEAPON
    if bFiringPrimary then
      
      if bHasPrimary then
        fFiringTimer = fFiringTimer + worldInfo:SimGetStep()
        if (fFiringTimer >= ParamsTable["primary"][2]) then
          fFiringTimer = fFiringTimer - ParamsTable["primary"][2]
          if bFirePressed and (ammo > 0) then
            bFiringPrimary = true
            bFreeToFire = false
            bFreeToAbility = false
            worldGlobals.OWFire(player,0)
            player:PlayCustomAnimOnWeapon(ParamsTable["primary"][1],0,false)
            worldGlobals.OWPlayingCustomAnim[player] = true
            SignalEvent(player,"ForcedNewAnim")
          else
            bFreeToFire = true
            bFreeToAbility = true
            bFiringPrimary = false          
            worldGlobals.OWFire(player,2)
            player:PlayCustomAnimOnWeapon(worldGlobals.OWCurrentWeaponParamsTable[player]["idle"],0.1,true)
            worldGlobals.OWPlayingCustomAnim[player] = false
            fFiringTimer = 0
          end
        end
      else
        bFiringPrimary = false
        bFreeToFire = true
        bFreeToAbility = true    
        return
      end
      
    end
    
    --CHARGING PRIMARY FOR EVERYONE
    if bChargingPrimary then

      if bHasPrimaryCharged then

        local bWasNotYetCharged = (worldGlobals.OWWeaponCharge[player] ~= 1)
        fFiringTimer = fFiringTimer + worldInfo:SimGetStep()
        worldGlobals.OWWeaponCharge[player] = mthMinF(fFiringTimer/ParamsTable["primaryCharged"][4],1)         
        local bNowCharged = (worldGlobals.OWWeaponCharge[player] == 1)
        
        if player:IsLocalOperator() then
          --HANZO UNDRAW STRING
          if bAltFirePressed and (ParamsTable["name"] == "Hanzo") then
            bChargingPrimary = false
            worldGlobals.OWWeaponPlayAnimClient(player,"UndrawString",0,false)
            worldGlobals.OWSignalEventClient(player,"OWStopSound"..ParamsTable["name"].."ChargingPrimary")
    
            local pay = Wait(Any(Delay(0.3),CustomEvent(player,"ForcedNewAnim")))
            if IsDeleted(player) then return end
            if (pay.any.signaledIndex == 1) and bActivated then
              if bFreeToAbility and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
                 worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
                 worldGlobals.OWPlayingCustomAnim[player] = false
              end
              bFreeToFire = true
              bFreeToAbility = true
            end
            
            return 
          end
          
          if bFirePressed then
            if bWasNotYetCharged and bNowCharged then
              worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["primaryCharged"][2],0.1,true)
            end
          else
            bChargingPrimary = false
            worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["primaryCharged"][3](worldGlobals.OWWeaponCharge[player]),0,false)
            worldGlobals.OWSignalEventClient(player,"OWStopSound"..ParamsTable["name"].."ChargingPrimary")
            
            local pay = Wait(Any(Delay(ParamsTable["primaryCharged"][6]),CustomEvent(player,"ForcedNewAnim")))
            if IsDeleted(player) then return end
            if (pay.any.signaledIndex == 1) and bActivated then
              if bFreeToAbility and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
                 worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
                 worldGlobals.OWPlayingCustomAnim[player] = false
              end            
              bFreeToFire = true
              bFreeToAbility = true
            end
          
            return
          end
          
        end
      else
        worldGlobals.OWWeaponCharge[player] = 0
        bChargingPrimary = false
        bFreeToFire = true
        bFreeToAbility = true    
        return        
      end
      
    else
      worldGlobals.OWWeaponCharge[player] = 0
    end
    
    --PRIMARY FIRE FOR NON-OPERATOR
    if not player:IsLocalOperator() and (player:GetPrimaryAmmo() ~= bPrimarySwitch) and bHasPrimary then
      if (player:GetPrimaryAmmo() > bPrimarySwitch) then      
        player:PlayCustomAnimOnWeapon(ParamsTable["primary"][1],0,false)
        SignalEvent(player,"ForcedNewAnim")
      elseif (timDifference(worldGlobals.OWLastForcedNewAnim[player],worldInfo:SimNow()) > ParamsTable["primary"][2]) then
        player:PlayCustomAnimOnWeapon(worldGlobals.OWCurrentWeaponParamsTable[player]["idle"],0.1,true)
      end
      bPrimarySwitch = player:GetPrimaryAmmo()
    end
    
    --REGULAR SECONDARY FIRE WHEN HELD DOWN FOR THE OPERATOR OF THE WEAPON
    if bFiringSecondary then
      fFiringTimer = fFiringTimer + worldInfo:SimGetStep()
      if (fFiringTimer >= ParamsTable["secondary"][2]) then
        fFiringTimer = fFiringTimer - ParamsTable["secondary"][2]
        bFreeToFire = true
        bFreeToAbility = true
        bFiringSecondary = false
        if bAltFirePressed and (ammo > 0)  then
          bFiringSecondary = true
          bFreeToFire = false
          bFreeToAbility = false
          
          worldGlobals.OWFire(player,1)
          player:PlayCustomAnimOnWeapon(ParamsTable["secondary"][1],0,false) 
          worldGlobals.OWPlayingCustomAnim[player] = true      
          SignalEvent(player,"ForcedNewAnim")
        else
          worldGlobals.OWFire(player,3)
          player:PlayCustomAnimOnWeapon(worldGlobals.OWCurrentWeaponParamsTable[player]["idle"],0.1,true)
          worldGlobals.OWPlayingCustomAnim[player] = false 
          fFiringTimer = 0       
          
        end
      end
      
    end
    
    --SECONDARY FOR NON-OPERATOR
    if not player:IsLocalOperator() and (player:GetSecondaryAmmo() ~= bSecondarySwitch) and bHasSecondary then
      if (player:GetSecondaryAmmo() > bSecondarySwitch) then         
        player:PlayCustomAnimOnWeapon(ParamsTable["secondary"][1],0,false)
        SignalEvent(player,"ForcedNewAnim")
      elseif (timDifference(worldGlobals.OWLastForcedNewAnim[player],worldInfo:SimNow()) > ParamsTable["secondary"][2]) then
        player:PlayCustomAnimOnWeapon(worldGlobals.OWCurrentWeaponParamsTable[player]["idle"],0,true)
      end
      bSecondarySwitch = player:GetSecondaryAmmo()
    end    
    
    --STARTING FIRE (WHEN BUTTON PRESSED) FOR THE OPERATOR
    if (ammo > 0) and player:IsLocalOperator() then
      
      --REGULAR PRIMARY
      if bFreeToFire and bFirePressed and bHasPrimary then
        bFiringPrimary = true
        bFireReleased = false
        worldGlobals.OWFire(player,0)
        bFreeToFire = false
        bFreeToAbility = false
        player:PlayCustomAnimOnWeapon(ParamsTable["primary"][1],0,false)
        worldGlobals.OWPlayingCustomAnim[player] = true
        SignalEvent(player,"ForcedNewAnim")
      end
      
      --CHARGING PRIMARY
      if bFreeToFire and bFirePressed and bHasPrimaryCharged and bFireReleased then
        bChargingPrimary = true
        bFireReleased = false
        bFreeToFire = false
        bFreeToAbility = false
        worldGlobals.OWPlayingCustomAnim[player] = true 
        worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["primaryCharged"][1],0,false)     
        worldGlobals.OWSignalAbilityClient(player,ParamsTable["name"].."ChargingPrimary")
      end
      
      --REGULAR SECONDARY
      if bFreeToFire and bAltFirePressed and bHasSecondary then
        bFiringSecondary = true
        bFireReleased = false
        worldGlobals.OWFire(player,1)
        bFreeToFire = false
        bFreeToAbility = false
        player:PlayCustomAnimOnWeapon(ParamsTable["secondary"][1],0,false)  
        worldGlobals.OWPlayingCustomAnim[player] = true  
        SignalEvent(player,"ForcedNewAnim")
      end    
    end
    
    --CLEARING ANIMS AS THE OPERATOR JUST IN CASE
    if not bFiringSecondary and not bFiringPrimary and not bChargingPrimary and not bChargingSecondary and player:IsLocalOperator() and (fFiringTimer ~= 0) then
      fFiringTimer = 0
      if (player:GetPrimaryAmmo() > 0) then worldGlobals.OWFire(player,2) end
      if (player:GetSecondaryAmmo() > 0) then worldGlobals.OWFire(player,3) end
    end
  
    --SPECIAL CASES (OPERATOR):
    if player:IsLocalOperator() then
      
      --HANZO ARROW SWITCH AND ABILITY BLOCK WHEN TRANSFORMED INTO 'STORM ARROW':
      if (string.find(path,"StormBow") ~= nil) then
        if not AbilityParams[2]["active"] and AbilityParams[1]["pressed"] and AbilityParams[1]["releasedAfterLastActivation"] then 
          AbilityParams[1]["releasedAfterLastActivation"] = false
          AbilityParams[1]["active"] = not AbilityParams[1]["active"]
          if AbilityParams[1]["active"] then
            worldGlobals.OWSignalEventClient(player,"HanzoSwitch1")
          else
            worldGlobals.OWSignalEventClient(player,"HanzoSwitch0")
          end
        end
        
        if AbilityParams[2]["active"] then bFreeToAbility = false end
      end
      
      --'HELLO' animations
      if bHelloPressed and not bHelloing then
        bHelloing = true
        worldGlobals.OWSignalAbilityClient(player,ParamsTable["name"].."Hello")
        
        RunAsync(function()
          Wait(Delay(1.5))
          bHelloing = false
        end)

        if not worldGlobals.OWPlayingCustomAnim[player] and bFreeToAbility then
          
          worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["hello"],0,false)
          worldGlobals.OWPlayingCustomAnim[player] = true
          RunAsync(function()
          
            local pay = Wait(Any(Delay(0.9),CustomEvent(player,"ForcedNewAnim")))
            if IsDeleted(player) then return end
            if (pay.any.signaledIndex == 1) and bActivated and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
              worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
              worldGlobals.OWPlayingCustomAnim[player] = false
            end

          end)        
        end
      end      
      
      --TRACER BLINK AND PHARAH JUMPJETS WITHOUT ANIMATION OVERRIDE:
      if (ParamsTable["name"] == "Tracer") or (ParamsTable["name"] == "Pharah") then
        if worldGlobals.OWPlayingCustomAnim[player] and AbilityParams[1]["pressed"] and AbilityParams[1]["releasedAfterLastActivation"] and not AbilityParams[1]["active"] and (AbilityParams[1]["activeCooldown"] >= AbilityParams[1]["cooldown"]) and ((ParamsTable["name"] ~= "Tracer") or not AbilityParams[2]["active"]) then 
          AbilityParams[1]["releasedAfterLastActivation"] = false
          AbilityParams[1]["active"] = true
          AbilityParams[1]["activeCooldown"] = AbilityParams[1]["activeCooldown"] - AbilityParams[1]["cooldown"] 
          worldGlobals.OWSendCooldownClient(player,i,AbilityParams[1]["activeCooldown"]) 
          worldGlobals.OWSignalAbilityClient(player,AbilityParams[1]["animation"](nil,nil))
          Wait(Any(Delay(AbilityParams[1]["animTime"]),CustomEvent(player,"ForcedNewAnim")))
          AbilityParams[1]["active"] = false
        end
      end
      
      --JUNKRAT BLOWING UP MINES WITHOUT ANIMATION OVERRIDE:
      if (ParamsTable["name"] == "Junkrat") then
        if worldGlobals.OWPlayingCustomAnim[player] and AbilityParams[0]["pressed"] and AbilityParams[0]["releasedAfterLastActivation"] and not AbilityParams[0]["active"] and (AbilityParams[0]["activeCooldown"] >= AbilityParams[0]["cooldown"]) then 
          AbilityParams[0]["releasedAfterLastActivation"] = false
          AbilityParams[0]["active"] = true
          AbilityParams[0]["activeCooldown"] = AbilityParams[0]["activeCooldown"] - AbilityParams[0]["cooldown"] 
          worldGlobals.OWSendCooldownClient(player,i,AbilityParams[0]["activeCooldown"]) 
          worldGlobals.OWSignalAbilityClient(player,AbilityParams[0]["animation"](nil,nil))
          Wait(Any(Delay(AbilityParams[1]["animTime"]),CustomEvent(player,"ForcedNewAnim")))
          AbilityParams[0]["active"] = false
        end
      end      

    end
    
    --CHECKING ABILITIES (OPERATOR)
    if bFreeToAbility and player:IsLocalOperator() then
    
      --MELEE
      if bMeleePressed and not bMeleeActive and (fMeleeCooldown == 1) then

        bFiringPrimary = false
        bFiringSecondary = false
        worldGlobals.OWFire(player,2)
        worldGlobals.OWFire(player,3)
       
        RunHandled(function()
          bMeleeActive = true
          bFreeToAbility = false
          bFreeToFire = false
          fMeleeCooldown = 0
           
          worldGlobals.OWPlayingCustomAnim[player] = true
          worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["melee"],0,false)
          worldGlobals.OWSignalAbilityClient(player,ParamsTable["name"].."Melee")
          
          local pay = Wait(Any(Delay(0.8),CustomEvent(player,"ForcedNewAnim")))
          if IsDeleted(player) then return end
          if (pay.any.signaledIndex == 1) and bActivated then
            if bFreeToFire and bFreeToAbility and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
              worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
              worldGlobals.OWPlayingCustomAnim[player] = false
            end            
            bFreeToFire = true
            bFreeToAbility = true
          end
          
          bMeleeActive = false
        end,
        
        On(Delay(0.5)),
        function()
          bFreeToFire = true
          bFreeToAbility = true
        end,
        
        OnEvery(CustomEvent("OnStep")),
        function()
          if IsDeleted(weapon) or IsDeleted(player) then return end
          
          if IsDeleted(weapon) or not bFreeToAbility or not bFreeToFire then
            SignalEvent(player,"Interrupted")
          end
        end)
        
        return        
      end    
      
      --OTHER ABILITIES
      for i,Params in pairs(AbilityParams) do 
      
        if Params["pressed"] and (Params["releasedAfterLastActivation"] or (Params["type"] == 8)) and not Params["active"] and (Params["activeCooldown"] >= Params["cooldown"]) then
            
          Params["releasedAfterLastActivation"] = false
        
          bFreeToFire = false
          bFreeToAbility = false
          bFiringPrimary = false
          bFiringSecondary = false
          worldGlobals.OWFire(player,2)
          worldGlobals.OWFire(player,3)           
          
          if (Params["type"] == 0) then
            --REGULAR ABILITY
            RunHandled(function()
              Params["active"] = true

              Params["activeCooldown"] = Params["activeCooldown"] - Params["cooldown"]
              
              worldGlobals.OWSendCooldownClient(player,i,Params["activeCooldown"])
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil))
              worldGlobals.OWPlayingCustomAnim[player] = true 
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon),0,false)   
              
              local pay = Wait(Any(Delay(Params["animTime"]),CustomEvent(player,"ForcedNewAnim")))
              if IsDeleted(player) then return end
              if (pay.any.signaledIndex == 1) and bActivated and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
                worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
                worldGlobals.OWPlayingCustomAnim[player] = false         
                bFreeToFire = true
                bFreeToAbility = true
              end
              
              Params["active"] = false
            end,
            
            On(CustomEvent(weapon,"Interruptible")),
            function()
              bFreeToAbility = true
              bFreeToFire = true
            end,
            
            OnEvery(CustomEvent("OnStep")),
            function()
              if IsDeleted(weapon) or IsDeleted(player) then return end

              if IsDeleted(weapon) then
                SignalEvent(player,"ForcedNewAnim")
              end
            end) 
            
            return         
          
          elseif (Params["type"] == 8) and (mthDotV3f(player:GetDesiredTempoAbs(), mthQuaternionToDirection(player:GetPlacement():GetQuat())) > 0.5) then
            --SPRINT ABILITY (SOLDIER)
            RunHandled(function()
              Params["active"] = true
              worldGlobals.OWSendAbilityStateClient(player,i,true)   
              
              worldGlobals.OWPlayingCustomAnim[player] = true 
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil))
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon),0.2,true)

              SignalEvent("StartedOWSprinting",{user = player})
              
              local pay = Wait(Any(Delay(Params["animTime"]),CustomEvent(weapon,"StopOWSprinting")))             
              
              SignalEvent("StoppedOWSprinting",{user = player})
              
              if IsDeleted(player) then return end
              
              worldGlobals.OWWeaponRemoveAnimClient(player,0.15)
              worldGlobals.OWPlayingCustomAnim[player] = false           

              bFreeToFire = true
              bFreeToAbility = true
              
              Params["active"] = false
              worldGlobals.OWSendAbilityStateClient(player,i,false)
            end,
            
            On(CustomEvent(weapon,"Interruptible")),
            function()
              bFreeToAbility = true
              bFreeToFire = true
            end,
            
            OnEvery(CustomEvent("OnStep")),
            function()
              if IsDeleted(weapon) or IsDeleted(player) then return end
              
              if not Params["pressed"] or (mthDotV3f(player:GetDesiredTempoAbs(), mthQuaternionToDirection(player:GetPlacement():GetQuat())) < 0.5) then
                SignalEvent(weapon,"StopOWSprinting")           
              end
              
            end)
            
            return 
            
          elseif (Params["type"] == 3) then
            --TRANSFORMATION ABILITY
            RunHandled(function()
              
              Params["active"] = true
              worldGlobals.OWSignalEventClient(player,"HanzoSwitch2")
              
              worldGlobals.OWPlayingCustomAnim[player] = true 
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil))
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon),0,false)
              
              local pay = Wait(Any(Delay(0.8),CustomEvent(player,"ForcedNewAnim")))
              
              if IsDeleted(player) then return end
              if (pay.any.signaledIndex == 1) and bActivated and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
                worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
                worldGlobals.OWPlayingCustomAnim[player] = false         
                bFreeToFire = true
                bFreeToAbility = true
              end
              
              Wait(CustomEvent(player,"DefaultArrows"))
              
              worldGlobals.OWSignalEventClient(player,"HanzoSwitch0")
              
              Params["active"] = false
              bFreeToAbility = true
              
              Params["activeCooldown"] = Params["activeCooldown"] - Params["cooldown"]
              worldGlobals.OWSendCooldownClient(player,i,Params["activeCooldown"])              

            end,
            
            On(CustomEvent(weapon,"Interruptible")),
            function()
              bFreeToAbility = true
              bFreeToFire = true
            end,
            
            On(Delay(Params["animTime"])),
            function()           
              worldGlobals.OWSignalEventClient(player,"DefaultArrows")
              worldGlobals.OWPlayingCustomAnim[player] = false
            end,
            
            OnEvery(CustomEvent("OnStep")),
            function()
              if (player:GetAmmoForWeapon(params) == 0) then
                local pay = Wait(Any(Delay(0.1),CustomEvent(player,"DefaultArrows")))
                if IsDeleted(player) then return end
                if (pay.any.signaledIndex == 1) then              
                  worldGlobals.OWSignalEventClient(player,"DefaultArrows")
                  worldGlobals.OWPlayingCustomAnim[player] = false
                end
              end           
            end)
        
            return                       

          elseif (Params["type"] == 4) then
            --TARGETING ABILITY
            
            local enTargetEffect = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName(ParamsTable["abilities"][i][6],worldInfo,player:GetPlacement())
            local bTargetEffectActive = false
            local vFinalTarget
            local bTargetFixed = false   
            worldInfo:AddLocalTextEffect(rightPromptTFX,"       'AltFire' to cancel")        
            
            RunHandled(function()
              
              Params["active"] = true
              worldGlobals.OWSendAbilityStateClient(player,i,true)
              
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil))
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon).."Start",0,false)
              
              Wait(Delay(0.4))
              if IsDeleted(player) or IsDeleted(weapon) then return end
              
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil).."Mid")
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon).."Mid",0.1,true)
              
              while not IsDeleted(player) and not IsDeleted(weapon) do
                if bAltFirePressed then break end
                if player:IsCommandPressed("plcmdFire") then 
                  if (vFinalTarget ~= nil) then
                    bTargetFixed = true                      
                    break
                  end
                end
                Wait(CustomEvent("OnStep"))
              end
              
              worldInfo:AddLocalTextEffect(leftPromptTFX,"")
              worldInfo:AddLocalTextEffect(rightPromptTFX,"")                             
              
              if IsDeleted(player) or IsDeleted(weapon) then return end
              
              if bAltFirePressed then 
                worldGlobals.OWWeaponRemoveAnimClient(player,0.1)     
                worldGlobals.OWSendAbilityStateClient(player,i,false)
                bFreeToFire = true
                bFreeToAbility = true  
                Params["active"] = false             
                return
              end
              
              worldGlobals.OWSignalAbilityClient(player,Params["animation"](nil,nil).."Act")
              
              Wait(Delay(Params["animTime"]))
              if IsDeleted(player) or IsDeleted(weapon) then return end
              worldGlobals.OWWeaponPlayAnimClient(player,Params["animation"](player,weapon).."End",0.1,false)
              
              local pay = Wait(Any(Delay(0.3),CustomEvent(player,"ForcedNewAnim")))
              
              if IsDeleted(player) or IsDeleted(weapon) then return end
              if (pay.any.signaledIndex == 1) and bActivated and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
                worldGlobals.OWWeaponRemoveAnimClient(player,0.1)     
                bFreeToFire = true
                bFreeToAbility = true
              end
              
              Params["active"] = false
              worldGlobals.OWSendAbilityStateClient(player,i,false)
              Params["activeCooldown"] = Params["activeCooldown"] - Params["cooldown"]
              worldGlobals.OWSendCooldownClient(player,i,Params["activeCooldown"])              

            end,
            
            --REAPER SPECIAL CASE
            On(CustomEvent(weapon,"ShadowstepAct")),
            function()
              if not player:IsLocalViewer() then return end
              
              local lookDir = player:GetLookDirEul()
              local qvLookTarget = player:GetLookOrigin()
              qvLookTarget:SetVect(qvLookTarget:GetVect()+100*mthEulerToDirectionVector(lookDir))
              local lookTarget = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName("LookTarget",worldInfo,qvLookTarget)      
              lookTarget:SetParent(player,"")
              player:SetLookTarget(lookTarget)
              player:SetPlacement(mthQuatVect(player:GetPlacement():GetQuat(),vFinalTarget))
            
              Wait(CustomEvent("OnStep"))
              if not IsDeleted(lookTarget) then lookTarget:Delete() end
            end,              
            
            On(CustomEvent(weapon,"Interruptible")),
            function()
              bFreeToAbility = true
              bFreeToFire = true
            end,       
            
            OnEvery(CustomEvent("OnStep")),
            function()
              if bTargetFixed or IsDeleted(weapon) or IsDeleted(player) or not Params["active"] then return end
              
              if IsDeleted(enTargetEffect) then
                enTargetEffect = worldGlobals.OWTemplates:SpawnEntityFromTemplateByName(ParamsTable["abilities"][i][6],worldInfo,player:GetPlacement())
                bTargetEffectActive = false
              end
              
              vFinalTarget = FindTargetForTargetingAbility(player)
              
              if (vFinalTarget ~= nil) then
                enTargetEffect:SetPlacement(mthQuatVect(qNullQuat,vFinalTarget))
                if not bTargetEffectActive then
                  bTargetEffectActive = true
                  enTargetEffect:Start()
                end
                worldInfo:AddLocalTextEffect(leftPromptTFX,"'Fire' to activate       ")
              elseif bTargetEffectActive then
                bTargetEffectActive = false
                enTargetEffect:Stop()  
                worldInfo:AddLocalTextEffect(leftPromptTFX,"")                            
              end
     
            end)
            
            if not IsDeleted(enTargetEffect) then enTargetEffect:Delete() end
            worldInfo:AddLocalTextEffect(leftPromptTFX,"")
            worldInfo:AddLocalTextEffect(rightPromptTFX,"")          
            
            return                       
                      
          end
          
          bFreeToFire = true
          bFreeToAbility = true          
        
        end
    
      end
      
      --RELOADING
      if bFreeToFire and bReloadPressed and not bReloading and (ammo < maxAmmo) then

        bFiringPrimary = false
        bFiringSecondary = false
        
        worldGlobals.OWFire(player,2)
        worldGlobals.OWFire(player,3)         
        
        bFreeToFire = false
        bFreeToAbility = true        
        
        bReloading = true
        
        worldGlobals.OWPlayingCustomAnim[player] = true
        worldGlobals.OWWeaponPlayAnimClient(player,ParamsTable["reload"][1],0.1,false)
        worldGlobals.OWSignalAbilityClient(player,ParamsTable["name"].."Reload")
        
        local pay = Wait(Any(Delay(ParamsTable["reload"][2]),CustomEvent(player,"ForcedNewAnim")))
        if IsDeleted(player) then return end
        if (pay.any.signaledIndex == 1) and bActivated and (worldGlobals.OWLastForcedNewAnim[player] ~= worldInfo:SimNow()) then
          worldGlobals.OWWeaponRemoveAnimClient(player,0.1)
          worldGlobals.OWPlayingCustomAnim[player] = false
          bFreeToFire = true
        end
        bReloading = false
        
        worldGlobals.OWSignalEventClient(player,"OWStopSound"..ParamsTable["name"].."Reload")
        
        return
      end      
      
    end
    
  end)
  
end)

end

--Main functions which catch and handle players/weapons

local IsHandled = {}

local HandlePlayer = function(player)
  RunAsync(function()
    while not IsDeleted(player) do
      
      if (worldGlobals.OWWeaponAbilityParams[player] ~= nil) then
        local weapon = player:GetRightHandWeapon()
        if weapon then
          local strHoldingWeaponPath = weapon:GetParams():GetFileName()
          for path, AbilityParams in pairs(worldGlobals.OWWeaponAbilityParams[player]) do
            if (path ~= strHoldingWeaponPath) then
              for i,Params in pairs(AbilityParams) do 
                Params["activeCooldown"] = mthMinF(Params["maxCooldown"], Params["activeCooldown"] + worldInfo:SimGetStep())
              end
            end
          end
        end
      end      
      
      local weapon = player:GetRightHandWeapon()
      if weapon then
        if not IsHandled[weapon] then
          IsHandled[weapon] = true
          local path = weapon:GetParams():GetFileName()
          if (worldGlobals.OWUsedScriptedGenericWeapons[path] ~= nil) then 
            HandleWeapon(player,weapon,worldGlobals.OWUsedScriptedGenericWeapons[path])
          end 
        end 
      end
      Wait(CustomEvent("OnStep"))
      
    end  
  end)
end

Wait(CustomEvent("OnStep"))

while true do
  local Players = worldInfo:GetAllPlayersInRange(worldInfo,10000)
  for i=1,#Players,1 do
    if not IsHandled[Players[i]] then
      IsHandled[Players[i]] = true
      HandlePlayer(Players[i])
    end
  end
  Wait(CustomEvent("OnStep"))
end