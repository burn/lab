local l,m,the = {},{},{
  file ="../tests4mop/misc/auto93.csv"
}
local big=1E30
function m.NUM(s,at) return {at=at,txt=s,n=0,lo=-big,hi=big} end
function m.SYM(s,at) return {at=at,txt=s,n=0,mu=0,
function m.COLS(row)
  

function m.DATA(src     data)
  data = {rows={},cols=nil}
  for row in src do
    if data.cols t[1+#t] = row end
 
function l.items(t,    n)
  i,max = 0,#t
  return function() if i < max then i=i+1; return t[i] end end end 

function l.coerce(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

function l.csv(src)
  src = src=="-" and io.stdin or io.input(src)
  return function(      s,t)
    s=io.read()
    if   s
    then t={}; for s1 in s:gsub("%s+", ""):gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end
         return t
    else io.close(src) end end end

0.43, -0.67, -0.84, -0.97, -1.07, -1.15, -1.22, -1.28
0.43,     0, -0.25, -0.43, -0.57, -0.67, -0.76, -0.84
 , ,   0.67, 0.25, 0, -0.18, -0.32, -0.43, -0.52
   , , ,               , 0.84, 0.43, 0.18, 0, -0.14, -0.25
      , , , ,               , 0.97, 0.57, 0.32, 0.14, 0
                , , , , ,           , 1.07, 0.67, 0.43, 0.25
          , , , , , ,                      , 1.15, 0.76, 0.52
                   , , , , , , ,                 , 1.22, 0.84
               , , , , , , , , ,    ,  1.28
