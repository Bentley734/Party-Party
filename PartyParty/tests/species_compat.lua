local uaRoot=arg[1]
local function include(path)return assert(loadfile(path))()end
local D=assert(loadfile(uaRoot..'/data.lua'))()
local original=assert(loadfile(uaRoot..'/data.lua'))().ATLAS
local checks=0
local function eq(a,b,why)checks=checks+1;assert(a==b,(why or '')..': '..tostring(a)..' ~= '..tostring(b))end
local source=assert(io.open(uaRoot..'/main.lua','rb')):read('*a')
local first=assert(source:find('  function Gfx.sheetFor(',1,true))
local last=assert(source:find('  -- white:',first,true))
local G={};local base={Data=D,C={OW_SUBSTITUTE_PLACEHOLDER=true},Gfx=G,FOLLOWER={}}
assert(load('return function(E,C,Gfx)\n'..source:sub(first,last-1)..'\nend'))()(base,base.C,G)
local P={national=function(id)return id<=251 and id or id<=411 and id-25 or id-64 end,
 speciesOf=function(m)return m.species end,isEgg=function(m)return m.egg end,
 isShiny=function(m)return m.shiny end,unownLetter=function(p)return p%28 end}
base.Pokemon=P;package.loaded['src.core.game3.pokemon']=P
local E=include('adapter.lua')(base,{},include)
include('lib/dex_compat.lua')(base,E,{find=function()end},include)
include('lib/dex_gap_art.lua')(E,base)
local expected={}
local file=assert(io.open('tests/national-species.tsv','rb'))
for nat,name,id in file:read('*a'):gmatch('(%d+)\t([A-Z0-9_]+)\t(%d+)')do expected[tonumber(nat)]=tonumber(id)end;file:close()
for nat=1,1025 do
 local sp=nat<=251 and nat or nat<=386 and nat+25 or nat+64
 eq(base.expansionSpecies(sp),expected[nat],'wild atlas ID '..nat)
 for _,female in ipairs({false,true})do for _,shiny in ipairs({false,true})do
  local n,s,f=E.monInfo({species=sp,gender=female and 'F' or 'M',shiny=shiny})
  eq(n,nat,'follower national identity');eq(s,shiny,'shininess');eq(f,female,'gender')
  local sheet,row=E.Gfx.sheetFor(nat,female,shiny)
  if original.species[expected[nat]] then
   local wanted=female and original.female[expected[nat]] or original.species[expected[nat]]
   eq(sheet,wanted,'native sheet');eq(row,shiny and original.shinyPal[expected[nat]] or original.sheets[wanted*6],'native palette')
  else
   eq(E.missingNative[nat],true,'known missing art fallback')
   eq(sheet,shiny and original.SUBSTITUTE or D.ATLAS.species[nat],'gap/shiny fallback')
  end
 end end
 assert(io.open(string.format('assets/g9rpsprites/%03d-normal.png',nat),'rb')):close()
end
for letter=1,27 do
 eq(base.expansionSpecies(201,letter),1023+letter,'native Unown letter')
 local nat=E.monInfo({species=201,personality=letter})
 eq(nat,2047+letter,'follower Unown letter')
 eq(E.Data.ATLAS.species[nat],original.species[1023+letter],'Unown art')
end
eq(E.Data.ATLAS.female[999],nil,'no Hisuian metadata leaks into Gimmighoul')
local spriteSets=include('lib/sprite_sets.lua')(E,{},include('lib/sprite_sets_data.lua'))
E.C.follower_sprite_set='untamed'
for _,nat in ipairs({414,670})do eq(spriteSets.selection({species=nat,nativeCore={}}),'g9rp','default gap art')end
local drawn
E.SpriteSets={draw=function(a,frame,flip,sx,sy,white,alpha,xs,mosaic,ys)drawn={a=a,ys=ys};return true end}
for sheet,nat in pairs(E.gapSheets)do
 eq(E.Gfx.draw(sheet,5,true,0,10,20,0,1,1,1,.75),true,'gap render routes before native page lookup')
 eq(drawn.a.species,nat,'correct gap species');eq(drawn.a.facing,'right','native facing decoded')
 eq(drawn.ys,.75,'gap pulse scale retained')
 eq(base.Gfx.draw(sheet,0,false,0,10,20),true,'native wild gap renderer')
end
print('Party Party all 1025 species / Gen 9 / Unown compatibility checks',checks)
