LUALIB:=`pkgconf lua --libs`
LUAINC:=`pkgconf lua --cflags`

YOGASRC:=$(wildcard yoga/yoga/*.cpp $(addsuffix *.cpp,$(wildcard yoga/yoga/*/)))
CFLAGS=-Wall -O2

all : layout.dll

yoga.o : yogaone.cpp $(YOGASRC)
	g++ --std=c++20 -c -o $@ $< -Iyoga $(CFLAGS)

luayoga.o : luayoga.c
	gcc -c -o $@ $< $(CFLAGS) $(LUAINC) -Iyoga
	
layout.dll : yoga.o luayoga.o
	gcc --shared -o $@ $^  $(LUALIB) -lstdc++
	
clean :
	rm -f *.dll *.o
	
	
