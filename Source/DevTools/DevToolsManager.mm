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
    std::cout << "🔧 DEBUG: toggleDevTools called" << std::endl;
    std::cout << "🔧 DEBUG: devToolsWindow exists: " << (self.devToolsWindow ? "YES" : "NO") << std::endl;
    
    if (self.devToolsWindow) {
        BOOL isVisible = [self.devToolsWindow isVisible];
        BOOL isMiniaturized = [self.devToolsWindow isMiniaturized];
        std::cout << "🔧 DEBUG: Window isVisible: " << (isVisible ? "YES" : "NO") << std::endl;
        std::cout << "🔧 DEBUG: Window isMiniaturized: " << (isMiniaturized ? "YES" : "NO") << std::endl;
        
        if (isVisible && !isMiniaturized) {
            // Finestra aperta e visibile → la chiudiamo
            std::cout << "🔧 DEBUG: Closing visible window" << std::endl;
            [self closeDevTools];
        } else {
            // 🔧 FIX: QUANDO LA FINESTRA È STATA CHIUSA CON X, RICREALA COMPLETAMENTE
            std::cout << "🔧 DEBUG: Window was closed with X button - recreating completely" << std::endl;
            
            // Cleanup della finestra vecchia
            [self.devToolsWindow close];
            self.devToolsWindow = nil;
            self.consoleTab = nil;
            self.elementsTab = nil;
            self.networkTab = nil;
            self.tabView = nil;
            
            // Ricrea completamente
            [self openDevTools];
        }
    } else {
        // Nessuna finestra esistente → la creiamo
        std::cout << "🔧 DEBUG: Creating new DevTools window" << std::endl;
        [self openDevTools];
    }
}

- (void)openDevTools {
    // ✅ LOGICA SEMPLIFICATA: Se la finestra esiste già, riutilizzala
    if (self.devToolsWindow) {
        [self.devToolsWindow makeKeyAndOrderFront:nil];
        [self.devToolsWindow deminiaturize:nil];
        std::cout << "🛠️ MacBird DevTools brought to front" << std::endl;
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
    
    // ✅ DELEGATE PER GESTIRE LA CHIUSURA DELLA FINESTRA
    [self.devToolsWindow setDelegate:self];
    
    [self setupDevToolsUI];
    [self.devToolsWindow makeKeyAndOrderFront:nil];
    
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
    std::cout << "🔧 DEBUG: closeDevTools called" << std::endl;
    std::cout << "🔧 DEBUG: devToolsWindow exists: " << (self.devToolsWindow ? "YES" : "NO") << std::endl;
    
    if (self.devToolsWindow) {
        BOOL isVisible = [self.devToolsWindow isVisible];
        std::cout << "🔧 DEBUG: Window isVisible before close: " << (isVisible ? "YES" : "NO") << std::endl;
        
        if (isVisible) {
            // ✅ CHIUSURA SOFT: Nascondi la finestra invece di distruggerla
            [self.devToolsWindow orderOut:nil];
            
            // Verifica che sia davvero nascosta
            BOOL stillVisible = [self.devToolsWindow isVisible];
            std::cout << "🔧 DEBUG: Window still visible after orderOut: " << (stillVisible ? "YES" : "NO") << std::endl;
            std::cout << "🛠️ MacBird DevTools hidden" << std::endl;
        } else {
            std::cout << "🔧 DEBUG: Window already not visible, nothing to do" << std::endl;
        }
    } else {
        std::cout << "🔧 DEBUG: No window to close" << std::endl;
    }
}

// ✅ NUOVO: Window Delegate per gestire la chiusura dall'utente
- (void)windowWillClose:(NSNotification*)notification {
    if (notification.object == self.devToolsWindow) {
        // L'utente ha chiuso la finestra cliccando la X
        std::cout << "🔧 DEBUG: windowWillClose called - user closed window with X button" << std::endl;
        std::cout << "🔧 DEBUG: NOT setting devToolsWindow to nil to allow reopening" << std::endl;
        std::cout << "🛠️ MacBird DevTools closed by user" << std::endl;
    }
}

// ✅ NUOVO: Metodo per cleanup completo (solo quando l'app si chiude)
- (void)cleanupDevTools {
    if (self.devToolsWindow) {
        [self.devToolsWindow close];
        self.devToolsWindow = nil;
        
        // Cleanup dei componenti solo nel cleanup finale
        self.consoleTab = nil;
        self.elementsTab = nil;
        self.networkTab = nil;
        
        std::cout << "🛠️ MacBird DevTools completely cleaned up" << std::endl;
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