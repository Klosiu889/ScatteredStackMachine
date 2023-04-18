cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

enable_language(ASM_NASM)
if (CMAKE_ASM_NASM_COMPILER_LOADED)
    set(CAN_USE_ASSEMBLER TRUE)
    set(CMAKE_ASM_NASM_FLAGS "-DN=2 -f elf64 -w+all -w+error")
    add_library(core.asm OBJECT core.asm)
    set(my_tests tests/my_tests.c)
    target_link_libraries(my_tests core pthread)
endif (CMAKE_ASM_NASM_COMPILER_LOADED)

add_executable(my_tests ${my_tests})