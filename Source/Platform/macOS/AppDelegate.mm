#import "AppDelegate.h"
#import "BrowserWindow.h"
#include <iostream>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    std::cout << "📱 App finished launching" << std::endl;
    
    // Crea la finestra principale
    self.mainWindow = [[BrowserWindow alloc] init];
    [self.mainWindow makeKeyAndOrderFront:nil];
    
    std::cout << "🪟 Main window created and shown" << std::endl;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;  // Chiude l'app quando si chiude l'ultima finestra
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    std::cout << "👋 MacBird shutting down..." << std::endl;
}

@end
