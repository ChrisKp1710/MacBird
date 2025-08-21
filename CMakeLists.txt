cmake_minimum_required(VERSION 3.20)
project(MacBird)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Trova i framework macOS necessari
find_library(COCOA_LIBRARY Cocoa)
find_library(WEBKIT_LIBRARY WebKit)

# File sorgenti (ora con DevToolsManager incluso!)
set(SOURCES
    Source/main.mm
    Source/Platform/macOS/AppDelegate.mm
    Source/Platform/macOS/BrowserWindow.mm
    Source/Platform/macOS/MenuManager.mm
    Source/Platform/macOS/DevToolsManager.mm
    Source/Core/Network/HTTPClient.mm
    Source/Core/HTML/HTMLParser.mm
    Source/Core/CSS/CSSParser.mm
)

# Crea l'eseguibile
add_executable(MacBird ${SOURCES})

# Link i framework
target_link_libraries(MacBird ${COCOA_LIBRARY} ${WEBKIT_LIBRARY})

# Include directories
target_include_directories(MacBird PRIVATE Source)
