#!/usr/bin/env lua
local l,eg,the = {},{},{
   file ="../tests4mop/misc/auto93.csv",
:  decimals = 3
}

local NUM, SYM, COLS, DATA     = {},{},{},{}
local BIG, PI, E, R            = 1E30, math.pi, math.exp(1), math.random
local max,min,abs,log,cos,sqrt = math.max,math.min,math.abs,math.log,math.cos,math.sqrt
----------------------------------------------------------------------------------------------------
local function COL(int,str) return (str:find"^[A-Z]" and NUM or SYM)(str,int) end

function NUM.new(str,int)  --> NUM
  return l.is(NUM, {at=int,txt=str,n=0,mu=0,m2=0,lo=-BIG,hi=BIG,
                     heaven=(s or " "):find"-$" and 0 or 1}) end

function NUM:add(num,    d) --> nil
  if num~="?" then
    self.n  = self.n + 1
    self.lo = min(num, self.lo)
    self.hi = max(num, self.hi)
    d       = num - self.mu
    self.mu = self.mu + d/self.n 
    self.m2 = self.m2 + d*(num - self.mu) 
    self.sd = self.n<2 and 0 or (self.m2/(self.n - 1))^.5 end end

function NUM:cdf(num,    z) --> float, found via the approximation from S. Bowling JIEM 2009
  z = (x - self.mu)/(self.sd + 1/BIG); return 1/(1 + E^(-1.702*z)) end
----------------------------------------------------------------------------------------------------
function SYM.new(str,int) --> SYM
  return l.is(SYM, {at=int,txt=str,n=0,mu=0}) end
----------------------------------------------------------------------------------------------------
function COLS.new(strs) -->  COLS
  return l.is(COLS, {names=t, x={}, y={}, all = kap(strs, COL)}):categorized() end

function COLS:catergorized(     t) --> COLS, with columns  placed in relevant categroies
  for _,col in pairs(self.all) do
    if not col.txt:find"X$" then
      t = col.txt:find"[!-+]$" and self.y or self.x
      t[1+#t] = tmp end end  
  return self end

function COLS:add(t) --> t, with contents of `t` summarized in `self`
  for _,cols in pairs{i.x, i.y} do
    for _,col in pairs(cols) do
      col:add( t[col.at] ) end end
  return t end
----------------------------------------------------------------------------------------------------
function DATA.new(src,  isOrdered,    self) --> DATA
  self = l.is(DATA, {rows={},cols=nil}) 
  for t in src do self:add(t) end
  if isOrdered then self.sort() end
  return self end

function DATA:add(t)
  if   self.cols 
  then self.rows[1+#self.rows] = self.cols:add(t) 
  else self.cols = COLS.new(t) end end

function DATA:sort()
  l.keysort(i.rows, function(r) return self:d2h(r) end) end

function DATA:d2h(row,     n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.y) do
    n = n + 1
    d = d + abs(col:norm(row[i]) - col.heaven)^2 end
  return (d/n)^.5 end
----------------------------------------------------------------------------------------------------
function l.is(t,klass) --> t 
  return setmetatable(klass,t) end

function l.klassify(ts) --> nil
  for str,t in pairs(ts) do t.a=str; t.__index=t end end

l.fmt = string.format 

function l.sort(t,fun) table.sort(t,fun); return t end

function l.map(t,fun,    u) u={}; for _,v in pairs(t) do u[1+#u] = fun(v)   end; return u end
function l.kap(t,fun,    u) u={}; for k,v in pairs(t) do u[1+#u] = fun(k,v) end; return u end

-- Show `t`'s print strung
function l.cat(t) --> t  
  print(l.as(t)); return t end

function l.as(x) --> str representing `x`
  return toString((type(x)=="table" and (#x==0 and l.kat(x) or l.dat(x))) or l.rnd(x)) end

function l.dat(t) --> str of a tables with numeric indexes
  return (t.a or "") .. '{' .. table.concat(l.map(t,l.as), ", ") .. '}' end

function l.kat(t) --> str of a table with keys, sorted by keys
  return l.dat(l.sort(l.kap(t, function (k,v) return l.fmt("%s=%s",k,l.as(v)) end))) end

function l.rnd(x, nDecs) --> num rounded to `nDec`imal places
  if type(x) ~= "number" then return x end
  if math.floor(x) == x  then return x end
  mult = 10^(nDecs or the.decimals)
  return math.floor(x * mult + 0.5) / mult end

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
l.klassify{NUM=NUM, SYM=SYM, COLS=COLS, DATA=DATA}

if arg[1] then eg[arg[1]]() end 
