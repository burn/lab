#!/usr/bin/env lua
local l,eg,the = {},{},{
   file ="../tests4mop/misc/auto93.csv",
   decimals = 3
}

local NUM, SYM, COLS, DATA     = {},{},{},{}
local BIG, PI, E, R            = 1E30, math.pi, math.exp(1), math.random
local max,min,abs,log,cos,sqrt = math.max,math.min,math.abs,math.log,math.cos,math.sqrt
----------------------------------------------------------------------------------------------------
function NUM:init(str,int)  --> NUM.
  return {at=int,txt=str,n=0,mu=0,m2=0,lo=-BIG,hi=BIG,
          heaven=(str or " "):find"-$" and 0 or 1} end

function NUM:add(num,    d) --> nil.
  if num~="?" then
    self.n  = 1 + self.n 
    self.lo = min(num, self.lo)
    self.hi = max(num, self.hi)
    d       = num - self.mu
    self.mu = self.mu + d/self.n 
    self.m2 = self.m2 + d*(num - self.mu) 
    self.sd = self.n<2 and 0 or (self.m2/(self.n - 1))^.5 end end

function NUM:mid() return self.mu end
function NUM:div() return self.sd end

function NUM:cdf(num,    z) --> float. Uses an approximation from S. Bowling JIEM 2009
  z = (num - self.mu)/(self.sd + 1/BIG); return 1/(1 + E^(-1.65451*z)) end
----------------------------------------------------------------------------------------------------
function SYM:init(str,int) --> SYM.
  return {at=int,txt=str,n=0,has={}} end

function SYM:add(x,   n) --> nil.
  if x~="?" then
    n           = n or 1
    self.n      = n + self.n 
    self.has[x] = n + (self.has[x] or 0) end end

function SYM:mid() --> x.
  return l.mode(self.has) end

function SYM:div() --> n. 
  return l.entropy(self.has) end
----------------------------------------------------------------------------------------------------
function COLS:init(strs,    all) -->  COLS.
  all = l.kap(strs, function(int,str) return (str:find"^[A-Z]" and NUM or SYM)(str,int) end)
  self.names, self.x, self.y , self.all = strs, {}, {}, all
  self:categorized() end

function COLS:catergorized(     t) --> COLS. Places columns   in their relevant categories..
  for _,col in pairs(self.all) do
    if not col.txt:find"X$" then
      t = col.txt:find"[!-+]$" and self.y or self.x
      t[1+#t] = col end end  
  return self end

function COLS:add(t) --> t. Summaries the contents of `t`  within `self`.
  for _,cols in pairs{self.x, self.y} do
    for _,col in pairs(cols) do
      col:add( t[col.at] ) end end
  return t end
----------------------------------------------------------------------------------------------------
function DATA:init(src,  isOrdered,    self) --> DATA
  self.rows, self.cols = {}, nil
  for t in src do self:add(t) end
  if isOrdered then self.sort() end end

function DATA:add(t)
  if   self.cols 
  then self.rows[1+#self.rows] = self.cols:add(t) 
  else self.cols = COLS(t) end end

function DATA:sort()
  return l.keysort(self.rows, function(r) return self:d2h(r) end) end

function DATA:d2h(row,     n,d)
  n,d = 0,0
  for _,col in pairs(self.cols.y) do
    n = n + 1
    d = d + abs(col:norm(row[col.at]) - col.heaven)^2 end
  return (d/n)^.5 end
----------------------------------------------------------------------------------------------------
function l.entropy(t,    e,N) --> n.
  N=0; for _,n in pairs(t) do N = N+n end
  e=0; for _,n in pairs(t) do if n>0 then e = e - n/N*log(n/N,2) end end
  return e,N end

function l.mode(t,     x,n)
  x,n=0,0; for x1,n1 in pairs(t) do if n1>n then x,n = x1,n1 end end; return x end

function l.init(t) --> fun. Fun calls `t.init` with a thing of class t. Returns thing of same class.
  return function(_,...)
    local i = setmetatable({},t)
    return setmetatable(t.init(i,...) or i,t) end  end

function l.klassify(ts) --> nil. Enable methods. Let classes print themselves and init themselves.
  for str,t in pairs(ts) do 
     t.__index   = t 
     t.__tostring= function(...) return str..l.kat(...) end 
     setmetatable(t, {__call = l.init(t)}) end end

l.fmt = string.format

function l.sort(t,fun) table.sort(t,fun); return t end

function l.map(t,fun,    u) u={}; for _,v in pairs(t) do u[1+#u] = fun(v)   end; return u end
function l.kap(t,fun,    u) u={}; for k,v in pairs(t) do u[1+#u] = fun(k,v) end; return u end

-- Show `t`'s print strung
function l.cat(t) --> t  
  print(#t == 0 and l.kat(t) or l.dat(t)) end

function l.dat(t) --> str of a tables with numeric indexes
  return '{' .. table.concat(l.map(t,tostring), ", ") .. '}' end

function l.kat(t) --> str of a table with keys, sorted by keys
  return l.dat(l.sort(l.kap(t, function (k,v) return l.fmt("%s=%s",k, l.rnd(v)) end))) end

function l.rnd(x, nDecs,    mult) --> num rounded to `nDec`imal places
  if type(x) ~= "number" then return x end
  if math.floor(x) == x  then return x end
  mult = 10^(nDecs or the.decimals)
  return math.floor(x * mult + 0.5) / mult end

function l.items(t,    i,hi)
  i,hi = 0,#t
  return function() if i < hi then i=i+1; return t[i] end end end 

function l.coerce(s)
  return math.tointeger(s) or tonumber(s) or s=="true" or (s~="false" and s) end

function l.words(s,fun,    t) --> t.
  t={}; for s1 in s:gsub("%s+", ""):gmatch("([^,]+)") do t[1+#t] = fun(s1) end 
  return t end 

function l.csv(src) --> fun. Iterator to generate rows in a csv file.
  src = src=="-" and io.stdin or io.input(src)
  return function(      s)
    s = io.read()
    if s then return l.words(s, l.coerce) else io.close(src) end end end
----------------------------------------------------------------------------------------------------
function eg.num(   n) 
  n=NUM"fred"
  for j=1,10000 do n:add(R()^2) end 
  print(n) end

function eg.norm(  n)
  n=NUM()
  for j=1,10000 do n:add( (0 + 1 * sqrt(-2*log(R())) * cos(2*PI*R()))) end
  for j=-3.5,0,.1 do print(j, n:cdf(j)) end end

function eg.items()
  for x in l.items{10,20,30,40} do print(x) end end
----------------------------------------------------------------------------------------------------
l.klassify{NUM=NUM, SYM=SYM, COLS=COLS, DATA=DATA}

if arg[1] then eg[arg[1]]() end 
