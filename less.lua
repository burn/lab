#!/usr/bin/env lua
local big,l,eg,the = 1E30,{},{},{
  file ="../tests4mop/misc/auto93.csv",
  decimals = 3
}

local max, min, abs, log, cos, sqrt = math.max, math.min, math.abs, math.log, math.cos, math.sqrt
local PI, R,E = 3.141593, math.random,math.exp(1)
local function isa(x,y) x.__index=x; return setmetatable(y,x) end
----------------------------------------------------------------------------------------------------
local NUM,SYM,COLS,DATA = {},{},{},{}
----------------------------------------------------------------------------------------------------

function NUM.new(s,at)  
  return isa(NUM, {at=at,txt=s,n=0,mu=0,m2=0,lo=-big,hi=big,
                   heaven=(s or " "):find"-$" and 0 or 1}) end

function NUM.add(i,x,    d)
  if x~="?" then
    i.n  = i.n + 1
    i.lo = min(x, i.lo)
    i.hi = max(x, i.hi)
    d    = x - i.mu
    i.mu = i.mu + d/i.n 
    i.m2 = i.m2 + d*(x - i.mu) 
    i.sd = i.n<2 and 0 or (i.m2/(i.n - 1))^.5 end end

function NUM.cdf(i,x)
  x = (x - i.mu)/(i.sd + 1/big); return 1/(1 + E^(-1.65451*x)) end
----------------------------------------------------------------------------------------------------
function SYM.new(s,at) 
  return isa(SYM, {at=at,txt=s,n=0,mu=0}) end
----------------------------------------------------------------------------------------------------
function COLS.new(t,    col,f,t,i,xy) 
  function f(at,s) return (s:find"^[A-Z]" and NUM or SYM)(s,at) end
  i = isa(COLS, {all=kap(t,f), names=t, x={}, y={}})
  for _,col in pairs(i.all) do
    if not col.txt:find"X$" then
      xy = col.txt:find"[!-+]$" and i.y or i.x
      xy[1+#xy] = col end end 
  return i end

----------------------------------------------------------------------------------------------------
function DATA.new(src,  order,    i)
  i = isa(DATA,{rows={},cols=nil}) 
  for row in src do i:add(row) end
  if order then i.sort() end
  return i end

function DATA.add(i, row)
  if   i.cols 
  then i.rows[1+#i.rows] = i.cols.add(row) 
  else i.cols = COLS.new(row) end end

function DATA.sort(i)
  l.keysort(i.rows, function(r) return i:d2h(r) end) end

function DATA.d2h(i,row,     n,d)
  n,d = 0,0
  for _,col in pairs(i.cols.y) do
    n = n + 1
    d = d + abs(col:norm(row[i]) - col.heaven)^2 end
  return (d/n)^.5 end
----------------------------------------------------------------------------------------------------
l.fmt = string.format 

function l.sort(t,fun) table.sort(t,fun); return t end

function l.map(t,fun,    u) u={}; for _,v in pairs(t) do u[1+#u] = fun(v)   end; return u end
function l.kap(t,fun,    u) u={}; for k,v in pairs(t) do u[1+#u] = fun(k,v) end; return u end

function l.cat(t,  n) 
  print(#t==0 and l.kat(t,n) or l.dat(t)) end

function l.dat(t)     
  return '{' .. table.concat(l.map(t,tostring), ", ") .. '}' end

function l.kat(t,  n,    fun)
  function fun(k,v) return l.fmt("%s=%s",k,l.rnd(v,n)) end
  return l.dat(l.sort(l.kap(t,fun))) end

function l.rnd(n, ndecs,     mult)
  if type(n) ~= "number" then return n end
  if math.floor(n) == n  then return n end
  mult = 10^(ndecs or the.decimals)
  return math.floor(n * mult + 0.5) / mult end

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
----------------------------------------------------------------------------------------------------
function eg.num(   n) 
  n=NUM.new()
  for j=1,10000 do n:add(R()^2) end 
  l.cat(n) end

function eg.norm(  n)
  n=NUM.new()
  for j=1,10000 do n:add( (10 + 2 * sqrt(-2*log(R())) * cos(2*PI*R()))) end
  for j=8,12,.25 do print(j, n:cdf(j)) end end

function eg.items()
  for x in l.items{10,20,30,40} do print(x) end end
----------------------------------------------------------------------------------------------------
if arg[1] then eg[arg[1]]() end 


