-- Adapt Untamed's exported seams to the installed Dex; keep its own OWE core.
return function(base,E,mod,include)
  local atlasIds=include('lib/atlas_species.lua')
  function base.expansionSpecies(species,personality)
    local nat=base.Pokemon.national(species)
    if not nat then return end
    if nat==201 and personality then
      local letter=base.Pokemon.unownLetter(personality)
      if letter>0 then return 1024+letter-1 end
    end
    return atlasIds[nat] or nat
  end
  local dex=mod:find('1025dex') or mod:find('firered_complete_dex')
  if not (dex and dex.exports and dex.exports.dexnavEncounters and dex.exports.chooseWildEncounter) then return end
  local api=include('lib/dex_policy.lua')(base,mod)
  local serial=0
  local nativeTick=base.Owe.tick
  base.Owe.tick=function(...)
    serial=serial+1
    return nativeTick(...)
  end
  local nativeArea=base.wildArea
  local cache=setmetatable({},{__mode='k'})
  base.wildArea=function(header,kind)
    local original=nativeArea(header,kind)
    if not original then return end
    if #original==0 then return original end
    -- A Dex header is identified by its live API; unknown maps remain native.
    local id=base.dexPolicyHeaders[header]
    if not id then return original end
    local byKind=cache[header]
    if not byKind then byKind={};cache[header]=byKind end
    if byKind[kind] then return byKind[kind] end
    -- UA chooses among 12 grass / 5 water indices. Lazy policy samples occupy
    -- those indices, followed by the complete roster for ability/chain checks.
    local slots={};local samples=kind=='water' and 5 or 12
    for i=1,samples do
      local sample,stamp
      slots[i]=setmetatable({}, {__index=function(_,key)
        if stamp~=serial then
          stamp=serial
          local _,sp,lv=api.chooseWildEncounter(id,kind)
          sample=sp and {species=sp,minLevel=lv,maxLevel=lv} or original[(i-1)%#original+1]
        end
        return sample and sample[key]
      end})
    end
    for _,row in ipairs(original)do slots[#slots+1]=row end
    byKind[kind]=slots
    return slots
  end
  local nativeLocal=base.localWildMon
  base.localWildMon=function()
    local id=base.mapId();local h=api.dexnavEncounters(id)
    if not h then return nativeLocal() end
    local land=h.land and #h.land.slots>0
    local water=h.water and #h.water.slots>0
    if not land and not water then return end
    local isWater=not land or water and base.random()%100>=80
    local _,sp=api.chooseWildEncounter(id,isWater and 'water' or 'land')
    if sp then return base.expansionSpecies(sp),isWater,sp end
  end
  function base.startWildBattle(foe,roamer,done)
    local ok,result=pcall(base.Battle.startWild,mod,base.Field._game,foe,
      {roamer=roamer or nil,done=done,__completeDexExact=true})
    return ok and result~=nil
  end
  mod.exports.dexCompatibility=true
end
