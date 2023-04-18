cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

function(add_test_executable name)
    enable_language(ASM_NASM)
    if (CMAKE_ASM_NASM_COMPILER_LOADED)
        set(CMAKE_ASM_NASM_COMPILE_OBJECT "<CMAKE_ASM_NASM_COMPILER> <INCLUDES> <FLAGS> -o <OBJECT> <SOURCE>")
        set(CAN_USE_ASSEMBLER TRUE)
        add_library(core.asm OBJECT core.asm)
    endif (CMAKE_ASM_NASM_COMPILER_LOADED)
    add_executable(${name} tests/${name}.c)
    target_link_libraries(${name} core pthread)
endfunction()

add_test_executable(my_tests)