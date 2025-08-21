#include <iostream>
#import <Cocoa/Cocoa.h>
#include "Platform/macOS/AppDelegate.h"

int main(int argc, char* argv[]) {
    std::cout << "🚀 MacBird Browser Starting..." << std::endl;
    
    @autoreleasepool {
        NSApplication* app = [NSApplication sharedApplication];
        
        // Imposta il tipo di attivazione per far apparire l'app nel dock
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        
        AppDelegate* delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        
        // Attiva l'applicazione e porta in primo piano
        [app activateIgnoringOtherApps:YES];
        
        [app run];
    }
    
    return 0;
}
