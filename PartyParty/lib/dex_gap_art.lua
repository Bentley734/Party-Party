-- The two absent native national sheets use the retained G9RP artwork.
return function(E,base)
  E.gapSheets={};E.missingNative={}
  for _,nat in ipairs({414,670})do
    if not base.Data.ATLAS.species[nat] then
      local A=base.Data.ATLAS;local sheet=#A.sheets/6+1
      local row={0,0,32,32,6,0}
      for _,value in ipairs(row)do A.sheets[#A.sheets+1]=value;E.Data.ATLAS.sheets[#E.Data.ATLAS.sheets+1]=value end
      A.species[nat]=sheet;E.Data.ATLAS.species[nat]=sheet
      E.gapSheets[sheet]=nat;E.missingNative[nat]=true
    end
  end
  local rawSheetFor=base.Gfx.sheetFor
  base.Gfx.sheetFor=function(species,female,shiny)
    if E.missingNative[species] and shiny then
      local A=base.Data.ATLAS;return A.SUBSTITUTE,A.sheets[A.SUBSTITUTE*6]
    end
    return rawSheetFor(species,female,shiny)
  end
  local rawDraw=base.Gfx.draw
  E.drawGap=function(sheet,frame,flip,row,sx,sy,white,alpha,xscale,mosaic,yscale)
    local nat=E.gapSheets[sheet]
    local f=frame%6
    local a={species=nat,nativeCore={},active=false,shiny=false,ballGfx=false,
      facing=f<2 and 'down' or f<4 and 'up' or flip and 'right' or 'left',
      anim={0,6,0,6},animT=f%2*6}
    return E.SpriteSets.draw(a,frame,flip,sx,sy,white,alpha,xscale,mosaic,yscale)
  end
  base.Gfx.draw=function(sheet,...)
    if E.gapSheets[sheet] then return E.drawGap(sheet,...) end
    return rawDraw(sheet,...)
  end
end
