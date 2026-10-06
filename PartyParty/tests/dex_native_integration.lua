local dexRoot=assert(arg[4]);local addonRoot=arg[3]
dofile('tests/dependency_integration.lua')
local f=partyPartyFixture;local base,E=f.base,f.E
local checks=0
local function eq(a,b,why)checks=checks+1;assert(a==b,why..': '..tostring(a)..' ~= '..tostring(b))end
local function upvalue(fn,wanted,seen)
 seen=seen or {};if seen[fn] then return end;seen[fn]=true
 for i=1,100 do
  local name,value=debug.getupvalue(fn,i);if not name then break end
  if name==wanted then return value end
  if type(value)=='function' then local found=upvalue(value,wanted,seen);if found~=nil then return found end end
 end
end
local speciesInfo=assert(upvalue(base.Owe.tick,'setSpeciesInfoForOWE'))
local spawn=assert(upvalue(base.Owe.tick,'spawnOWE'))
local info=assert(upvalue(spawn,'info'))
local battle=assert(upvalue(base.Owe.interact,'startWildBattleWithOWE'))
local roster=assert(loadfile(dexRoot..'/encounters/roster.lua'))()
local names,national={},{ }
for _,mon in ipairs(roster)do local sp=mon.id<=251 and mon.id or mon.id<=386 and mon.id+25 or mon.id+64;names[mon.name]=sp;national[sp]=mon.id end
local P=base.Pokemon
P.speciesFromName=function(name)return names[name]end
P.speciesFromNational=function(n)return names[roster[n].name]end
P.national=function(sp)return national[sp]end
P.keyName=function(sp)return national[sp] and roster[national[sp]].name end
P.gender=function()return 'M'end
local session=base.Runtime.getSession();session.map='FR_ROUTE_2';session.version='firered';session.party={}
base.mapId=function()return session.map end
session.engineOptions={firered=session.options}
package.loaded['src.core.GameVersion'].get=function()return session.version end
package.loaded['src.core.GameVersion'].generation=function()return 3 end
package.loaded['src.import.gba.map_catalog']={resolve=function(id)return id end}
package.loaded['src.core.game3.profile']={forSession=function(s)return {id=s.version}end}
package.loaded['src.core.game3.constants']={of=function()return {require=function()return 0x864 end}end}
package.loaded['src.core.game3.scripting.space'].isActive=function()return false end
package.loaded['src.core.game3.scripting.flags'].getFlag=function(s,_,id)return s and s.flags and s.flags[id]==true end
base.Encounters.tableFor=function()return {land={slots={{species=names.PIDGEY,minLevel=5,maxLevel=50}}},water={slots={{species=names.MAGIKARP,minLevel=5,maxLevel=50}}}}end
local dex=f.loadMod('1025dex',dexRoot..'/encounters',{})
local nativeCalls=0;base.Owe.tick=function()nativeCalls=nativeCalls+1 end
f.include('lib/dex_compat.lua')(base,E,f.mods.wildfollowers,f.include)
local terrain='land';base.encounterKind=function()return terrain end
local captured
base.Battle.startWild=function(_,_,foe,opts)captured={foe=foe,opts=opts};return captured end
local Policy=assert(loadfile(dexRoot..'/encounters/policy.lua'))()
math.randomseed(310)
for _,game in ipairs({'firered','leafgreen','emerald'})do
 session.version=game;session.map=game=='emerald' and 'EM_ROUTE_102' or 'FR_ROUTE_22'
 for choice=1,#Policy.choices do
  session.options.fireredGenEncounterPool=choice
  for _,kind in ipairs({'land','water'})do
   terrain=kind
   for sample=1,4 do
    base.Owe.tick()
    info.category=base.Owe.CAT.WILD
    assert(speciesInfo(info,8,8),'actual UA species generation '..game..' '..choice..' '..kind)
    local nat=P.national(info.engineSpecies)
    eq(nat>=Policy.choices[choice].first and nat<=Policy.choices[choice].last,true,'selected generation')
    eq(info.species,base.expansionSpecies(info.engineSpecies,info.personality),'correct UA atlas ID')
    local actor=base.actors[2];spawn(actor,8,8)
    eq(actor.engineSpecies,info.engineSpecies,'spawn engine species preserved')
    eq(actor.personality,info.personality,'spawn personality preserved')
    assert(battle(actor),'actual UA battle starts')
    eq(captured.foe.species,actor.engineSpecies,'battle species matches visible actor')
    eq(captured.foe.level,actor.level,'battle level matches visible actor')
    eq(captured.foe.personality,actor.personality,'battle personality matches visible actor')
    eq(captured.opts.__completeDexExact,true,'second Dex roll bypassed')
    actor.active=false
   end
  end
 end
end
eq(nativeCalls,408,'compat tick delegates once per native frame')
eq(#base.actors,5,'native wild pool capacity retained')
print('Party Party actual UA spawn / Dex policy / exact battle integration checks',checks)
