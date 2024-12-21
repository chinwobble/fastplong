DIR_INC := ./highway
DIR_SRC := ./highway/hwy
DIR_OBJ := ./highway/obj
DIR_BIN := ./lib

SRC := $(filter-out %_test.cc, $(wildcard ${DIR_SRC}/*.cc))
OBJ := $(patsubst %.cc,${DIR_OBJ}/%.o,$(notdir ${SRC}))

TARGET := ${DIR_BIN}/libhwy.a

BIN_TARGET := ${TARGET}

CXX ?= g++
CXX_DEFINES = -DHWY_STATIC_DEFINE -DTOOLCHAIN_MISS_ASM_HWCAP_H
CXX_FLAGS = -O3 -DNDEBUG -std=c++17 -fPIC -fvisibility=hidden -fvisibility-inlines-hidden -Wno-builtin-macro-redefined -D__DATE__=\"redacted\" -D__TIMESTAMP__=\"redacted\" -D__TIME__=\"redacted\" -fmerge-all-constants -Wall -Wextra -Wvla -Wnon-virtual-dtor -Wcast-align -fmath-errno -fno-exceptions -Wno-psabi -Werror -I$(CURDIR)
CXX_INCLUDES = $(foreach includedir,$(DIR_INC),-I$(includedir))
LIBS := -lisal -ldeflate -lpthread
STATIC_FLAGS := -static -Wl,--no-as-needed -pthread
LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(LIBS) $(LD_FLAGS)

${BIN_TARGET}:${OBJ}
	ar rcs ${BIN_TARGET} $(OBJ)

${DIR_OBJ}/%.o:${DIR_SRC}/%.cc
	@mkdir -p $(@D) 
	$(CXX) $(CXX_DEFINES) -c $< -o $@ $(CXX_FLAGS)

.PHONY:clean
clean:
	@rm -rf $(DIR_OBJ)
	@rm -f $(TARGET)
	@rm -f $(TEST_TARGET)

-include $(OBJ:.o=.d)
