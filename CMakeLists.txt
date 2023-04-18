cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

function(add_test_executable name)
    enable_language(ASM_NASM)
    set(CMAKE_ASM_NASM_COMPILE_OBJECT "<CMAKE_ASM_NASM_COMPILER> <INCLUDES> <FLAGS> -o <OBJECT> <SOURCE>")
    add_compile_options(
            "$<$<COMPILE_LANGUAGE:ASM_NASM>:-f $<IF:$<BOOL:$<TARGET_PROPERTY:NASM_OBJ_FORMAT>>, \
    $<TARGET_PROPERTY:NASM_OBJ_FORMAT>, ${CMAKE_ASM_NASM_OBJECT_FORMAT}>>"
    )
    add_executable(core core.asm)
    set_target_properties(core PROPERTIES NASM_OBJ_FORMAT elf64)
endfunction()

add_test_executable(my_tests)