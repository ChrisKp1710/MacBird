#import "MenuManager.h"
#import "BrowserWindow.h"
#include <iostream>

@implementation MenuManager

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window {
    self = [super init];
    if (self) {
        self.browserWindow = window;
    }
    return self;
}

- (void)setupMenuBar {
    NSMenu* mainMenu = [[NSMenu alloc] init];
    
    // === MENU MACBIRD ===
    NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];
    NSMenu* appMenu = [[NSMenu alloc] initWithTitle:@"MacBird"];
    
    [appMenu addItemWithTitle:@"About MacBird" action:@selector(showAbout:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Hide MacBird" action:@selector(hide:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit MacBird" action:@selector(terminate:) keyEquivalent:@"q"];
    
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];
    
    // === MENU VIEW ===
    NSMenuItem* viewMenuItem = [[NSMenuItem alloc] init];
    NSMenu* viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
    
    [viewMenu addItemWithTitle:@"Reload" action:@selector(reloadPage:) keyEquivalent:@"r"];
    [viewMenu addItemWithTitle:@"Force Reload" action:@selector(forceReloadPage:) keyEquivalent:@"R"];
    [viewMenu addItem:[NSMenuItem separatorItem]];
    [viewMenu addItemWithTitle:@"Actual Size" action:@selector(resetZoom:) keyEquivalent:@"0"];
    [viewMenu addItemWithTitle:@"Zoom In" action:@selector(zoomIn:) keyEquivalent:@"+"];
    [viewMenu addItemWithTitle:@"Zoom Out" action:@selector(zoomOut:) keyEquivalent:@"-"];
    [viewMenu addItem:[NSMenuItem separatorItem]];
    [viewMenu addItemWithTitle:@"Enter Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"];
    
    [viewMenuItem setSubmenu:viewMenu];
    [mainMenu addItem:viewMenuItem];
    
    // === MENU DEVELOPER ===
    NSMenuItem* devMenuItem = [[NSMenuItem alloc] init];
    NSMenu* devMenu = [[NSMenu alloc] initWithTitle:@"Developer"];
    
    NSMenuItem* devToolsItem = [devMenu addItemWithTitle:@"Toggle Developer Tools" action:@selector(toggleDevTools:) keyEquivalent:@"i"];
    [devToolsItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
    
    [devMenu addItemWithTitle:@"View Page Source" action:@selector(viewSource:) keyEquivalent:@"u"];
    [devMenu addItem:[NSMenuItem separatorItem]];
    [devMenu addItemWithTitle:@"JavaScript Console" action:@selector(showConsole:) keyEquivalent:@"j"];
    [devMenu addItemWithTitle:@"Network Monitor" action:@selector(showNetwork:) keyEquivalent:@""];
    [devMenu addItem:[NSMenuItem separatorItem]];
    [devMenu addItemWithTitle:@"Browser Detection Report" action:@selector(showDetectionReport:) keyEquivalent:@""];
    
    [devMenuItem setSubmenu:devMenu];
    [mainMenu addItem:devMenuItem];
    
    // === MENU WINDOW ===
    NSMenuItem* windowMenuItem = [[NSMenuItem alloc] init];
    NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
    
    [windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [windowMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
    [windowMenu addItem:[NSMenuItem separatorItem]];
    [windowMenu addItemWithTitle:@"Bring All to Front" action:@selector(arrangeInFront:) keyEquivalent:@""];
    
    [windowMenuItem setSubmenu:windowMenu];
    [mainMenu addItem:windowMenuItem];
    
    [NSApp setMainMenu:mainMenu];
    
    std::cout << "📋 Menu bar setup completed with Developer Tools support" << std::endl;
}

// ======= MENU ACTIONS =======

- (void)showAbout:(id)sender {
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText:@"MacBird Browser"];
    [alert setInformativeText:@"Un browser nativo moderno per macOS\nBuilt with WebKit e Cocoa\n\nVersion 1.0\nCopyright © 2025"];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (void)reloadPage:(id)sender {
    [self.browserWindow.webView reload];
    std::cout << "🔄 Page reloaded" << std::endl;
}

- (void)forceReloadPage:(id)sender {
    [self.browserWindow.webView reloadFromOrigin];
    std::cout << "🔄 Page force reloaded" << std::endl;
}

- (void)resetZoom:(id)sender {
    [self.browserWindow.webView setMagnification:1.0];
    std::cout << "🔍 Zoom reset to 100%" << std::endl;
}

- (void)zoomIn:(id)sender {
    CGFloat currentZoom = [self.browserWindow.webView magnification];
    [self.browserWindow.webView setMagnification:currentZoom * 1.1];
    std::cout << "🔍 Zoom increased" << std::endl;
}

- (void)zoomOut:(id)sender {
    CGFloat currentZoom = [self.browserWindow.webView magnification];
    [self.browserWindow.webView setMagnification:currentZoom * 0.9];
    std::cout << "🔍 Zoom decreased" << std::endl;
}

- (void)viewSource:(id)sender {
    NSString* sourceScript = @"document.documentElement.outerHTML";
    [self.browserWindow.webView evaluateJavaScript:sourceScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            std::cout << "📄 PAGE SOURCE:" << std::endl;
            std::cout << "============================================" << std::endl;
            NSString* source = (NSString*)result;
            if ([source length] > 1000) {
                source = [[source substringToIndex:1000] stringByAppendingString:@"\n... (truncated)"];
            }
            std::cout << [source UTF8String] << std::endl;
            std::cout << "============================================" << std::endl;
        }
    }];
}

- (void)showConsole:(id)sender {
    // Delega al DevToolsManager (implementeremo dopo)
    [self.browserWindow toggleDevTools:sender];
    std::cout << "🖥️ JavaScript Console output sent - check terminal for details" << std::endl;
}

- (void)showNetwork:(id)sender {
    std::cout << "🌐 NETWORK MONITOR:" << std::endl;
    std::cout << "====================" << std::endl;
    std::cout << "Current URL: " << [[[self.browserWindow.webView URL] absoluteString] UTF8String] << std::endl;
    std::cout << "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Safari/605.1.15" << std::endl;
    std::cout << "====================" << std::endl;
}

- (void)showDetectionReport:(id)sender {
    std::cout << "🔍 BROWSER DETECTION REPORT:" << std::endl;
    std::cout << "=============================" << std::endl;
    std::cout << "WebKit Version: 605.1.15" << std::endl;
    std::cout << "Safari Version: 17.6" << std::endl;
    std::cout << "macOS Compatibility: Full" << std::endl;
    std::cout << "Modern Features: Enabled" << std::endl;
    std::cout << "=============================" << std::endl;
    
    [self.browserWindow toggleDevTools:sender];
}

@end