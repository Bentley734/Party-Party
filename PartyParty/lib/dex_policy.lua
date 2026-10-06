-- Resolve the installed Dex once, then use its public policy only at spawn time.
return function(E,mod)
 local dex=mod.find and (mod:find('1025dex') or mod:find('firered_complete_dex'))
 local api=dex and dex.exports
 local bill=mod.find and mod:find('bills_backyard_mew_frlg')
 local fixed=bill and bill.exports and bill.exports.fixedEncounterAt
 E.chooseVisibleEncounter=function(x,y,kind,level,mapId)
  mapId=mapId or E.mapId()
  if not fixed then
   bill=mod.find and mod:find('bills_backyard_mew_frlg')
   fixed=bill and bill.exports and bill.exports.fixedEncounterAt
  end
  local exact=type(fixed)=='function' and fixed(mapId,x,y)
  if exact then return exact.species,exact.level end
  if api and api.chooseWildEncounter then
   local _,sp,lv=api.chooseWildEncounter(mapId,kind,level)
   return sp,lv
  end
 end
 -- Chaining must see the same species roster as the Dex selection policy.
 local native=E.wildHeader
 E.dexPolicyHeaders=setmetatable({},{__mode='k'})
 local map,selection,cached,session,postgame,revision
 local Options=require('src.core.game3.options')
 -- 1025Dex 1.2.1 unlocks special pools from the native League-clear flag.
 -- Use the same live script store as the Dex, including imported saves.
 local function leagueCleared(s)
  if not s then return false end
  local ok,cleared=pcall(function()
   local Profile=require('src.core.game3.profile')
   local K=require('src.core.game3.constants').of(Profile.forSession(s).id)
   local id=K:require('flags','FLAG_SYS_GAME_CLEAR')
   local Space=require('src.core.game3.scripting.space')
   local active=Space.isActive and Space.isActive() and Space.getStore() or s
   return (active and active.flags and active.flags.FLAG_SYS_GAME_CLEAR==true)
    or require('src.core.game3.scripting.flags').getFlag(active,nil,id)==true
  end)
  return ok and cleared==true
 end
 E.wildHeader=function(mapId)
  if mapId and mapId~=E.mapId() then
   local header=api and api.dexnavEncounters and api.dexnavEncounters(mapId)
   if header then E.dexPolicyHeaders[header]=mapId end
   return header or native(mapId)
  end
  if not (api and api.dexnavEncounters) then return native() end
  local s=E.Runtime.getSession();local opts=s and s.engineOptions and Options.block(s.engineOptions)
  local chosen=opts and opts.fireredGenEncounterPool
  if chosen==nil and s and s.options then chosen=s.options.fireredGenEncounterPool end
  local cleared=leagueCleared(s)
  local poolRevision=api.encounterPoolRevision and api.encounterPoolRevision() or 'legacy' 
  local id=E.mapId()
  if map~=id or selection~=chosen or session~=s or postgame~=cleared or revision~=poolRevision then
   local changed=map~=nil and session==s and (selection~=chosen or revision~=poolRevision)
   map,selection,session,postgame,revision=id,chosen,s,cleared,poolRevision
   local header=api.dexnavEncounters(id)
   if header then E.dexPolicyHeaders[header]=id end
   cached=header or native()
   if changed and E.Owe then
    if E.Owe.refreshEncounterPools then E.Owe.refreshEncounterPools()
    else E.Owe.despawnAll('generated',false) end
   end
  end
  return cached
 end
 mod.exports.dexnavEncounters=function(id)
  return api and api.dexnavEncounters and api.dexnavEncounters(id) or E.Encounters.tableFor(id)
 end
 return api
end
