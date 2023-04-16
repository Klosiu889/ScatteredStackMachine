cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

enable_language(ASM_NASM)
if (CMAKE_ASM_NASM_COMPILER_LOADED)
    set(CAN_USE_ASSEMBLER TRUE)
    set(my_tests core.asm tests/my_tests.c)
    set(mimuw_tests core.asm tests/mimuw_tests.c)
endif (CMAKE_ASM_NASM_COMPILER_LOADED)

add_executable(my_tests ${my_tests})
add_executable(mimuw_tests ${mimuw_tests})