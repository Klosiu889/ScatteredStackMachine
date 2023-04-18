cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

set(NASM_FLAGS "-DN=2 -f elf64 -w+all -w+error")

enable_language(ASM_NASM)
if (CMAKE_ASM_NASM_COMPILER_LOADED)
    set(CAN_USE_ASSEMBLER TRUE)
    set(my_tests core.asm tests/my_tests.c)
    #set(mimuw_tests core.asm tests/mimuw_tests.c)
    set(example_tests core.asm tests/example.c)
endif (CMAKE_ASM_NASM_COMPILER_LOADED)

set (cmake_asm_nasm_flags "${cmake_asm_nasm_flags}-DN=12")

add_executable(my_tests ${my_tests})
#add_executable(mimuw_tests ${mimuw_tests})
add_executable(example_tests ${example_tests})

target_link_libraries(my_tests pthread)
