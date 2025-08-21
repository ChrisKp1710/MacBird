#import "DevToolsManager.h"
#import "Platform/macOS/BrowserWindow.h"
#import "Console/ConsoleTab.h"
#import "Elements/ElementsTab.h"
#import "Network/NetworkTab.h"
#import "Common/DevToolsStyles.h"
#include <iostream>

@implementation DevToolsManager

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.devToolsWindow = nil;
    }
    return self;
}

- (void)toggleDevTools {
    if (self.devToolsWindow && [self.devToolsWindow isVisible] && !self.devToolsWindow.isMiniaturized) {
        [self closeDevTools];
    } else {
        [self openDevTools];
    }
}

- (void)openDevTools {
    // Se la finestra esiste ma è chiusa/minimizzata, riportala in primo piano
    if (self.devToolsWindow) {
        [self.devToolsWindow makeKeyAndOrderFront:nil];
        [self.devToolsWindow deminiaturize:nil];
        return;
    }
    
    // Crea finestra DevTools (80% larghezza dello schermo, 500px altezza)
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    NSRect devToolsFrame = NSMakeRect(
        screenFrame.size.width * 0.1,
        80,
        screenFrame.size.width * 0.8,
        500
    );
    
    self.devToolsWindow = [[NSWindow alloc] initWithContentRect:devToolsFrame
                                                      styleMask:(NSWindowStyleMaskTitled |
                                                               NSWindowStyleMaskClosable |
                                                               NSWindowStyleMaskResizable)
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    
    [self.devToolsWindow setTitle:@"MacBird Developer Tools"];
    [self.devToolsWindow setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.devToolsWindow setTitlebarAppearsTransparent:YES];
    
    [self setupDevToolsUI];
    [self.devToolsWindow makeKeyAndOrderFront:nil];
    
    // Auto-run detection quando si aprono i DevTools
    [self runDetectionAnalysis];
    
    std::cout << "🛠️ MacBird DevTools opened (modular architecture)" << std::endl;
}

- (void)setupDevToolsUI {
    NSView* contentView = [self.devToolsWindow contentView];
    NSRect contentFrame = [contentView bounds];
    
    // === TAB VIEW CON TEMA SCURO CHROME DEVTOOLS ===
    self.tabView = [[NSTabView alloc] initWithFrame:contentFrame];
    [self.tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.tabView setTabViewType:NSTopTabsBezelBorder];
    [self.tabView setWantsLayer:YES];
    [self.tabView.layer setBackgroundColor:[DevToolsStyles tabViewBackgroundColor].CGColor];
    
    // === CREA TUTTI I TAB MODULARI ===
    
    // Console Tab
    self.consoleTab = [[ConsoleTab alloc] initWithBrowserWindow:self.browserWindow frame:contentFrame];
    NSTabViewItem* consoleTabItem = [[NSTabViewItem alloc] initWithIdentifier:@"console"];
    [consoleTabItem setLabel:@"Console"];
    [consoleTabItem setView:self.consoleTab.containerView];
    [self.tabView addTabViewItem:consoleTabItem];
    
    // Elements Tab
    self.elementsTab = [[ElementsTab alloc] initWithBrowserWindow:self.browserWindow frame:contentFrame];
    NSTabViewItem* elementsTabItem = [[NSTabViewItem alloc] initWithIdentifier:@"elements"];
    [elementsTabItem setLabel:@"Elements"];
    [elementsTabItem setView:self.elementsTab.containerView];
    [self.tabView addTabViewItem:elementsTabItem];
    
    // Network Tab
    self.networkTab = [[NetworkTab alloc] initWithBrowserWindow:self.browserWindow frame:contentFrame];
    NSTabViewItem* networkTabItem = [[NSTabViewItem alloc] initWithIdentifier:@"network"];
    [networkTabItem setLabel:@"Network"];
    [networkTabItem setView:self.networkTab.containerView];
    [self.tabView addTabViewItem:networkTabItem];
    
    // Aggiungi tab view alla finestra
    [contentView addSubview:self.tabView];
    
    // Forza refresh
    [self.devToolsWindow displayIfNeeded];
    [self.tabView setNeedsDisplay:YES];
    
    std::cout << "🎨 Modular DevTools UI setup completed" << std::endl;
}

- (void)closeDevTools {
    if (self.devToolsWindow) {
        [self.devToolsWindow close];
        self.devToolsWindow = nil;
        
        // Cleanup dei componenti
        self.consoleTab = nil;
        self.elementsTab = nil;
        self.networkTab = nil;
        
        std::cout << "🛠️ MacBird DevTools closed" << std::endl;
    }
}

// === PUBLIC METHODS FOR EXTERNAL ACCESS ===

- (void)logToConsole:(NSString*)message {
    [self logToConsole:message withColor:nil];
}

- (void)logToConsole:(NSString*)message withColor:(NSColor*)color {
    if (self.consoleTab) {
        [self.consoleTab logToConsole:message withColor:color];
    }
}

- (void)runDetectionAnalysis {
    if (self.consoleTab) {
        [self.consoleTab runDetectionAnalysis];
    }
    
    // Auto-refresh HTML source quando si fa l'analisi
    if (self.elementsTab) {
        [self.elementsTab refreshHTMLSource];
    }
}

@end