cmake_minimum_required(VERSION 3.18)
project(ScatteredStackMachine)

set(CMAKE_CXX_STANDARD 14)

find_package(Threads REQUIRED)

function(add_test_executable test_file)
    enable_language(ASM_NASM)
    if (CMAKE_ASM_NASM_COMPILER_LOADED)
        set(CAN_USE_ASSEMBLER TRUE)
        set(name core.asm tests/${test_file}.c)
    endif (CMAKE_ASM_NASM_COMPILER_LOADED)
    add_executable(${test_file} ${name})
    target_link_libraries(${test_file} pthread)
endfunction()

add_test_executable(my_tests)