DIR_INC := ./inc
DIR_SRC := ./src
DIR_OBJ := ./obj
DIR_TEST := ./test
DIR_BENCHMARKS := ./benchmarks

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
INCLUDE_DIRS ?= vendor/highway vendor/benchmark/include
LIBRARY_DIRS ?= vendor/lib

SRC := $(wildcard ${DIR_SRC}/*.cpp)
TEST := $(wildcard ${DIR_TEST}/*.cpp)
BENCHMARK := $(wildcard ${DIR_BENCHMARKS}/*.cpp)
OBJ := $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${SRC}))
TEST_OBJ := $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${TEST}))
BENCHMARK_OBJ := $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${BENCHMARK}))

TARGET := fastplong

BIN_TARGET := ${TARGET}
TEST_TARGET := bin/fastplong_unittest
BENCHMARK_TARGET := bin/fastplong_benchmarks

CXX ?= g++
CXXFLAGS := -std=c++14 -pthread -g -O3 -MP -MD -I${DIR_INC} -I${DIR_SRC} $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir)) ${CXXFLAGS}
LIBS := -lisal -ldeflate -lpthread -lhwy
STATIC_FLAGS := -static -Wl,--no-as-needed -pthread
LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(LIBS) $(LD_FLAGS)
STATIC_LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(STATIC_FLAGS) $(LIBS) $(STATIC_LD_FLAGS)

${BIN_TARGET}:${OBJ} vendor/lib/libhwy.a vendor/lib/libbenchmark.a
	$(CXX) $(OBJ) -o $@ $(LD_FLAGS)

vendor/lib/libhwy.a:
	make -f highway.make -C vendor

vendor/lib/libbenchmark.a:
	make -f benchmark.make -C vendor

static:${OBJ}
	$(CXX) $(OBJ) -o ${BIN_TARGET} $(STATIC_LD_FLAGS)

${DIR_OBJ}/%.o:${DIR_SRC}/%.cpp
	@mkdir -p $(@D) 
	$(CXX) -c $< -o $@ $(CXXFLAGS)

.PHONY:clean
.PHONY:static
clean:
	@rm -rf $(DIR_OBJ)
	@rm -f $(TARGET)
	@rm -f $(TEST_TARGET)

install:
	install $(TARGET) $(BINDIR)/$(TARGET)
	@echo "Installed."

${DIR_OBJ}/%.o:${DIR_TEST}/%.cpp
	@mkdir -p $(@D) 
	$(CXX) -c $< -o $@ $(CXXFLAGS)

test-static: ${TEST_OBJ} ${OBJ}
	@mkdir -p bin
	$(CXX) $(TEST_OBJ) ${OBJ:./obj/main.o=} -o ${TEST_TARGET} $(STATIC_LD_FLAGS) -lgtest -lgtest_main
	./${TEST_TARGET}

test:${TEST_OBJ} ${OBJ:./obj/main.o=}
	@mkdir -p bin
	$(CXX) $(TEST_OBJ) ${OBJ:./obj/main.o=} -o ${TEST_TARGET} $(LD_FLAGS) -lgtest -lgtest_main
	./${TEST_TARGET}

${DIR_OBJ}/%.o:${DIR_BENCHMARKS}/%.cpp
	@mkdir -p $(@D)
	$(CXX) -c $< -o $@ $(CXXFLAGS)

benchmark:${BENCHMARK_OBJ} ${OBJ} test/globals.o
	@mkdir -p bin
	$(CXX) test/globals.cpp $(BENCHMARK_OBJ) ${OBJ:./obj/main.o=} -o ${BENCHMARK_TARGET} $(LD_FLAGS) -lbenchmark
	./${BENCHMARK_TARGET}

-include $(OBJ:.o=.d)
