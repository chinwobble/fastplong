DIR_INC := ./benchmark/include
DIR_SRC := ./benchmark/src
DIR_OBJ := ./benchmark/obj
DIR_BIN := ./lib

SRC := $(filter-out %_test.cc, $(wildcard ${DIR_SRC}/*.cc))
OBJ := $(patsubst %.cc,${DIR_OBJ}/%.o,$(notdir ${SRC}))

TARGET := ${DIR_BIN}/libbenchmark.a

BIN_TARGET := ${TARGET}

CXX ?= g++
CXX_DEFINES = 
CXX_FLAGS = -O3 -DNDEBUG -std=c++17 -fPIC -fvisibility=hidden -fvisibility-inlines-hidden -Wno-builtin-macro-redefined -D__DATE__=\"redacted\" -D__TIMESTAMP__=\"redacted\" -D__TIME__=\"redacted\" -fmerge-all-constants -Wall -Wextra -Wvla -Wnon-virtual-dtor -Wcast-align -fmath-errno -fno-exceptions -Wno-psabi -Werror
CXX_INCLUDES = $(foreach includedir,$(DIR_INC),-I$(includedir))
LIBS := 
LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(LIBS) $(LD_FLAGS)

${BIN_TARGET}:${OBJ}
	@mkdir -p $(@D) 
	ar rcs ${BIN_TARGET} $(OBJ)

${DIR_OBJ}/%.o:${DIR_SRC}/%.cc
	@mkdir -p $(@D) 
	$(CXX) $(CXX_DEFINES) -c $< -o $@ $(CXX_FLAGS) $(CXX_INCLUDES)

.PHONY:clean
clean:
	@rm -rf $(DIR_OBJ)
	@rm -f $(TARGET)
	@rm -f $(TEST_TARGET)

