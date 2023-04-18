cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

set(THREADS_NUM 10)

enable_language(ASM_NASM)
if (CMAKE_ASM_NASM_COMPILER_LOADED)
    set(CAN_USE_ASSEMBLER TRUE)
    set(my_tests core.asm tests/my_tests.c)
    set_source_files_properties(core.asm PROPERTIES COMPILE_FLAGS "-DN=${THREADS_NUM}")
endif (CMAKE_ASM_NASM_COMPILER_LOADED)

add_executable(my_tests ${my_tests})
target_link_libraries(my_tests pthread)
set_target_properties(my_tests PROPERTIES COMPILE_FLAGS "-DN=${THREADS_NUM}")