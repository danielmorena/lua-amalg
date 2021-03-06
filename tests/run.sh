#!/bin/bash -e

LUAV=$1
if [ x"$1" != x5.1 -a x"$1" != x5.2 -a x"$1" != x5.3 -a x"$1" != x5.4 ]; then
  LUAV=5.1
fi

if [ "$LUAV" == 5.4 ]; then
  INC=/home/siffiejoe/.self/programs/lua$LUAV
else
  INC=/usr/include/lua$LUAV
fi

gcc -Wall -Wextra -Os -fpic -I"$INC" -shared -o cmod.so cmod.c
gcc -Wall -Wextra -Os -fpic -I"$INC" -shared -o aiomod.so aiomod.c

echo "Using Lua $LUAV ..."
luac$LUAV -o module1.luac module1.lua
luac$LUAV -o module2.luac module2.lua

echo -n "amalgamate modules only ... "
lua$LUAV ../src/amalg.lua -o modules.lua module1 module2
lua$LUAV -l modules main.lua

echo -n "amalgamate modules as fallbacks(1) ... "
lua$LUAV ../src/amalg.lua -f -o fallbacks.lua module1 module2
lua$LUAV -l fallbacks main.lua
echo -n "amalgamate modules as fallbacks(2) ... "
lua$LUAV -l fallbacks -e "package.path=''" main.lua

echo -n "amalgamate modules and script in text form ... "
lua$LUAV ../src/amalg.lua -o textout.lua -s main.lua module1 module2
lua$LUAV textout.lua

echo -n "amalgamate modules and script in binary form ... "
lua$LUAV -e 'package.path = "./?.luac;"..package.path' ../src/amalg.lua -o binout.lua -s main.lua module1 module2
lua$LUAV binout.lua

echo -n "amalgamate modules and script without arg fix ... "
lua$LUAV ../src/amalg.lua -o afixout.lua -a -s main.lua module1 module2
lua$LUAV afixout.lua

echo -n "amalgamate modules and script with debug info ... "
lua$LUAV ../src/amalg.lua -o debugout.lua -d -s main.lua module1 module2
lua$LUAV debugout.lua

echo -n "collect module names using amalg.lua as a module ... "
lua$LUAV -e 'package.path = "../src/?.lua;"..package.path' -l amalg main.lua
echo -n "amalgamate modules and script using amalg.cache ... "
lua$LUAV ../src/amalg.lua -o cacheout.lua -s main.lua -c
lua$LUAV cacheout.lua

echo -n "amalgamate Lua modules, Lua script and C modules ... "
lua$LUAV ../src/amalg.lua -o cmodout.lua -s main.lua -c -x
lua$LUAV -e 'package.cpath = ""' cmodout.lua

echo -n "amalgamate Lua modules, but ignore C modules ... "
lua$LUAV ../src/amalg.lua -o ignout.lua -s main.lua -c -x -i '^cmod' -i '^aiomod'
lua$LUAV ignout.lua

exit 0

rm -f module1.luac module2.luac modules.lua fallbacks.lua textout.lua binout.lua afixout.lua debugout.lua cacheout.lua cmodout.lua ignout.lua amalg.cache cmod.so aiomod.so

