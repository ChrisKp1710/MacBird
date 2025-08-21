cmake_minimum_required(VERSION 3.20)
project(MacBird)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Trova i framework macOS necessari
find_library(COCOA_LIBRARY Cocoa)
find_library(WEBKIT_LIBRARY WebKit)

# File sorgenti (per ora solo main)
set(SOURCES
    Source/main.cpp
    Source/Platform/macOS/AppDelegate.mm
    Source/Platform/macOS/BrowserWindow.mm
)

# Crea l'eseguibile
add_executable(MacBird ${SOURCES})

# Link i framework
target_link_libraries(MacBird ${COCOA_LIBRARY} ${WEBKIT_LIBRARY})

# Include directories
target_include_directories(MacBird PRIVATE Source)
