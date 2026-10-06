local dexRoot=assert(arg[1],'Pass extracted 1025Dex 1.2.1 path')
local wildRoot=arg[2] or '.'
local function read(path) local f=assert(io.open(path,'rb'));local t=f:read('*a');f:close();return t end
local function data(path) return assert(loadfile(dexRoot..'/'..path))() end
local checks=0
local function eq(a,b,why) checks=checks+1;assert(a==b,(why or '')..': '..tostring(a)..' ~= '..tostring(b)) end
local version,session,store,map='firered',nil,nil,nil
local rawBattle,clears,headerCalls=0,0,0
local roster=data('encounters/roster.lua')
local nativeProfiles=data('encounters/native.lua')
local names,toNat,toSlot={},{},{}
for _,mon in ipairs(roster) do
 local slot=mon.id<=251 and mon.id or mon.id<=386 and mon.id+25 or mon.id+64
 names[mon.name]=slot;toNat[slot]=mon.id;toSlot[mon.id]=slot
end
local P={speciesFromName=function(n)return names[n]end,keyName=function(n)return toNat[n] and roster[toNat[n]].name end,
 national=function(n)return toNat[n]end,speciesFromNational=function(n)return toSlot[n]end,_speciesMeta={}}
local native={land={slots={{species=names.PIDGEY,minLevel=5,maxLevel=12}}},water={slots={{species=names.MAGIKARP,minLevel=5,maxLevel=12}}}}
local Runtime={getSession=function()return session end}
local Options={block=function(o)return o end}
local Bridge={start=function(_,_,foe,opts)rawBattle=rawBattle+1;return {foe=foe,opts=opts} end}
local Encounters={tableFor=function()return native end,onStep=function(_,kind)return {species=names.PIDGEY,level=5}end,
 rollFishing=function()return {species=names.MAGIKARP,level=5}end,rollRocks=function()return {species=names.GEODUDE,level=5}end}
local modules={['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end},
 ['src.core.game3.options']=Options,['src.core.game3.runtime']=Runtime,['src.core.game3.pokemon']=P,
 ['src.core.game3.encounters']=Encounters,['src.core.game3.battle_bridge']=Bridge,
 ['src.core.game3.profile']={forSession=function()return {id=version}end},
 ['src.core.game3.constants']={of=function()return {require=function()return 0x864 end}end},
 ['src.core.game3.scripting.space']={isActive=function()return store~=nil end,getStore=function()return store end},
 ['src.core.game3.scripting.flags']={getFlag=function(s,_,id)return s and s.flags and s.flags[id]==true end},
 ['src.import.gba.map_catalog']={resolve=function(id)return id end}}
for name,value in pairs(modules)do package.loaded[name]=value end
local dex={exports={},read=function(_,path)return read(dexRoot..'/encounters/'..path)end,log={warn=function()end,info=function()end}}
assert(loadfile(dexRoot..'/encounters/main.lua'))()(dex)
local shape=data('dex/src/gen3shape.lua')
for nat=387,1025 do eq(shape.slot(nat),nat+64,'Actual 1.2.1 species adapter') end
local E={Runtime=Runtime,Pokemon=P,C={},FOLLOWER_SLOTS=6,actors={},Follower={followers={}},
 mapId=function()return map end,wildHeader=function()return native end,Encounters=Encounters,
 Owe={despawnAll=function()clears=clears+1 end},encounterKind=function()return 'land' end}
local mod={exports={},find=function(_,id)if id=='1025dex' then return dex end end}
local originalHeader=dex.exports.dexnavEncounters
dex.exports.dexnavEncounters=function(id)headerCalls=headerCalls+1;return originalHeader(id)end
assert(loadfile(wildRoot..'/lib/dex_policy.lua'))()(E,mod)
local Policy=data('encounters/policy.lua')
local locations=data('encounters/locations.lua');for _,loc in ipairs(data('encounters/hoenn_locations.lua'))do locations[#locations+1]=loc end
local tested=0
math.randomseed(121)
for _,game in ipairs({'firered','leafgreen','emerald'})do
 version=game;session={engineOptions={fireredGenEncounterPool=17},flags={}}
 for _,loc in ipairs(locations)do
  if (game=='emerald')==(loc.hoenn==true)then
   map=loc.map
   for selection=1,#Policy.choices do
    session.engineOptions.fireredGenEncounterPool=selection
    local header=E.wildHeader()
    eq(type(header),'table','Policy header')
    local choice=Policy.choices[selection]
    for _,terrain in ipairs({'land','water'})do
     for sample=1,3 do
      local sp,level=E.chooseVisibleEncounter(2,3,terrain,loc.lo)
      if sp then
       local nat=P.national(sp);local mon=roster[nat]
       local residents=nativeProfiles[game][map]
       local resident=residents and residents[terrain] and residents[terrain][nat]~=nil
       eq(resident or Policy.allows(mon,terrain),true,'Terrain policy '..game..' '..map..' '..selection..' '..nat..' '..terrain)
       local route1=map=='FR_ROUTE_1' and terrain=='land' and (nat==1 or nat==4 or nat==7 or nat==25)
       local diglett=map=='FR_DIGLETTS_CAVE_B1F' and terrain=='land' and (nat==50 or nat==51)
       eq(route1 or diglett or nat>=choice.first and nat<=choice.last,true,'Generation policy')
       eq(mon.special,false,'Pre-League special gate')
       local slots=header[terrain] and header[terrain].slots or {};local found=false
       for _,slot in ipairs(slots)do if slot.species==sp then found=true end end
       eq(found,true,'Visible choice belongs to chaining header')
       local foe={species=sp,level=level,personality=0x12345678,__completeDexTerrain=terrain}
       local result=Bridge.start(mod,{},foe,{wild=true,__completeDexExact=true})
       eq(result.foe,foe,'Exact battle identity/personality/level')
       tested=tested+1
      end
     end
    end
   end
  end
 end
end
-- Same-map progression changes must refresh the chained roster immediately.
version='firered';map='FR_CERULEAN_CAVE_2F';session={engineOptions={fireredGenEncounterPool=17},flags={}}
local function specials(header)
 local n=0
 for _,area in pairs(header)do for _,slot in ipairs(area.slots or {})do if roster[P.national(slot.species)].special then n=n+1 end end end
 return n
end
local before=E.wildHeader();eq(specials(before),0,'Pre-League cached header')
local c=clears;session.flags.FLAG_SYS_GAME_CLEAR=true
local after=E.wildHeader();eq(after~=before,true,'Post-League header invalidated');eq(specials(after)>0,true,'Latest special pools available');eq(clears,c,'Progression preserves population')
store={flags={}}
eq(specials(E.wildHeader()),0,'Active script store takes precedence')
store.flags[0x864]=true;eq(specials(E.wildHeader())>0,true,'Numeric live League flag')
store=nil;session={options={fireredGenEncounterPool=9},flags={}}
local gen9=E.wildHeader();eq(specials(gen9),0,'New save session clears old progression')
local sp=E.chooseVisibleEncounter(0,0,'land',50);if sp then eq(P.national(sp)>=906,true,'Legacy options selection')end
local h=headerCalls;E.wildHeader();eq(headerCalls,h,'Stable header cached')
session.options.fireredGenEncounterPool=1;E.wildHeader();eq(clears,c+1,'Legacy generation switch refreshes wilds')
map='UNLISTED_MAP';eq(E.wildHeader(),native,'Unknown map native fallback')
print(('PASS: %d assertions; %d actual-policy encounters across FR/LG/Emerald and all 17 selections; cache progression/save cases.'):format(checks,tested))
