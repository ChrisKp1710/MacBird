#include <iostream>
#import <Cocoa/Cocoa.h>
#include "Platform/macOS/AppDelegate.h"

int main(int argc, char* argv[]) {
    std::cout << "🚀 MacBird Browser Starting..." << std::endl;
    
    @autoreleasepool {
        NSApplication* app = [NSApplication sharedApplication];
        
        AppDelegate* delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        
        [app run];
    }
    
    return 0;
}
