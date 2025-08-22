#import "BrowserWindow.h"
#import "MenuManager.h"
#import "DevTools/DevToolsManager.h"
#import "TabManager.h"  // ✨ AGGIUNGI QUESTO IMPORT
#import <WebKit/WebKit.h>
#include <iostream>

@implementation BrowserWindow

- (instancetype)init {
    // Finestra più moderna - 1400x900 con aspect ratio migliore
    NSRect windowRect = NSMakeRect(0, 0, 1400, 900);
    
    self = [super initWithContentRect:windowRect
                            styleMask:(NSWindowStyleMaskTitled | 
                                     NSWindowStyleMaskClosable | 
                                     NSWindowStyleMaskMiniaturizable | 
                                     NSWindowStyleMaskResizable |
                                     NSWindowStyleMaskFullSizeContentView)
                              backing:NSBackingStoreBuffered
                                defer:NO];
    
    if (self) {
        [self setTitle:@"MacBird Browser"];
        [self center];
        
        // Stile moderno della finestra
        self.titlebarAppearsTransparent = YES;
        self.titleVisibility = NSWindowTitleHidden;
        
        // Colore di sfondo moderno (grigio scuro elegante)
        [self setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
        
        [self setupModernUI];
        
        // Crea e configura il MenuManager
        self.menuManager = [[MenuManager alloc] initWithBrowserWindow:self];
        [self.menuManager setupMenuBar];
        
        // ✨ NUOVO: Crea il DevToolsManager modulare integrato
        self.devToolsManager = [[DevToolsManager alloc] initWithBrowserWindow:self];
        
        std::cout << "🪟 Modern MacBird Browser window created with MULTI-TAB support!" << std::endl;
    }
    
    return self;
}

- (void)setupModernUI {
    NSView* contentView = [self contentView];
    
    // === TOOLBAR DI NAVIGAZIONE (PERFETTAMENTE CENTRATA) ===
    NSView* navigationToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, [contentView frame].size.height - 55, 290, 55)];
    [navigationToolbar setWantsLayer:YES];
    [navigationToolbar.layer setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0].CGColor];
    [navigationToolbar setAutoresizingMask:NSViewMinYMargin];
    
    // Menu hamburger (CENTRATO con spazio sopra e sotto)
    NSButton* menuButton = [[NSButton alloc] initWithFrame:NSMakeRect(82, 6, 32, 32)];
    [menuButton setTitle:@"☰"];
    [menuButton setFont:[NSFont systemFontOfSize:16]];
    [menuButton setBordered:NO];
    [menuButton setWantsLayer:YES];
    [menuButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [menuButton.layer setCornerRadius:6];
    
    // Pulsante Indietro (CENTRATO con spazio sopra e sotto)
    NSButton* backButton = [[NSButton alloc] initWithFrame:NSMakeRect(122, 6, 32, 32)];
    [backButton setTitle:@"←"];
    [backButton setFont:[NSFont systemFontOfSize:18]];
    [backButton setBordered:NO];
    [backButton setTarget:self];
    [backButton setAction:@selector(goBack:)];
    [backButton setWantsLayer:YES];
    [backButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [backButton.layer setCornerRadius:6];
    
    // Pulsante Avanti (CENTRATO con spazio sopra e sotto)
    NSButton* forwardButton = [[NSButton alloc] initWithFrame:NSMakeRect(162, 6, 32, 32)];
    [forwardButton setTitle:@"→"];
    [forwardButton setFont:[NSFont systemFontOfSize:18]];
    [forwardButton setBordered:NO];
    [forwardButton setTarget:self];
    [forwardButton setAction:@selector(goForward:)];
    [forwardButton setWantsLayer:YES];
    [forwardButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [forwardButton.layer setCornerRadius:6];
    
    // Pulsante Reload (CENTRATO con spazio sopra e sotto)
    NSButton* reloadButton = [[NSButton alloc] initWithFrame:NSMakeRect(202, 6, 32, 32)];
    [reloadButton setTitle:@"↻"];
    [reloadButton setFont:[NSFont systemFontOfSize:18]];
    [reloadButton setBordered:NO];
    [reloadButton setTarget:self];
    [reloadButton setAction:@selector(reload:)];
    [reloadButton setWantsLayer:YES];
    [reloadButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [reloadButton.layer setCornerRadius:6];
    
    // Pulsante Home (CENTRATO con spazio sopra e sotto)
    NSButton* homeButton = [[NSButton alloc] initWithFrame:NSMakeRect(242, 6, 32, 32)];
    [homeButton setTitle:@"🏠"];
    [homeButton setFont:[NSFont systemFontOfSize:16]];
    [homeButton setBordered:NO];
    [homeButton setTarget:self];
    [homeButton setAction:@selector(goHome:)];
    [homeButton setWantsLayer:YES];
    [homeButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [homeButton.layer setCornerRadius:6];
    
    // ✨ BARRA DIVISORIA ELEGANTE
    NSView* separatorLine = [[NSView alloc] initWithFrame:NSMakeRect(289, 6, 1, 32)];
    [separatorLine setWantsLayer:YES];
    [separatorLine.layer setBackgroundColor:[NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.6].CGColor];
    
    // Aggiungi tutti gli elementi al navigationToolbar
    [navigationToolbar addSubview:menuButton];
    [navigationToolbar addSubview:backButton];
    [navigationToolbar addSubview:forwardButton];
    [navigationToolbar addSubview:reloadButton];
    [navigationToolbar addSubview:homeButton];
    [navigationToolbar addSubview:separatorLine];
    
    // === SISTEMA TAB (MODIFICATO PER TABMANAGER) ===
    NSView* tabBar = [[NSView alloc] initWithFrame:NSMakeRect(295, [contentView frame].size.height - 55, [contentView frame].size.width - 295, 55)];
    [tabBar setWantsLayer:YES];
    [tabBar.layer setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0].CGColor];
    [tabBar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    
    // ✨ PULSANTE + PER NUOVA TAB (COLLEGATO AL TABMANAGER!)
    NSButton* newTabButton = [[NSButton alloc] initWithFrame:NSMakeRect(180, 6, 32, 32)];
    [newTabButton setTitle:@"+"];
    [newTabButton setFont:[NSFont systemFontOfSize:18]];
    [newTabButton setBordered:NO];
    [newTabButton setTarget:self];
    [newTabButton setAction:@selector(newTab:)]; // ✨ QUESTO CHIAMERÀ IL METODO newTab!
    [newTabButton setWantsLayer:YES];
    [newTabButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [newTabButton.layer setCornerRadius:6];
    
    [tabBar addSubview:newTabButton];
    
    // === CONTAINER PER LE WEBVIEW ===
    NSView* webViewContainer = [[NSView alloc] initWithFrame:NSMakeRect(15, 15, [contentView frame].size.width - 30, [contentView frame].size.height - 85)];
    [webViewContainer setWantsLayer:YES];
    [webViewContainer.layer setCornerRadius:12.0];
    [webViewContainer.layer setMasksToBounds:YES];
    [webViewContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // ✨ CREA IL TAB MANAGER CON SUPPORTO MULTI-TAB
    self.tabManager = [[TabManager alloc] initWithBrowserWindow:self 
                                                 tabBarContainer:tabBar 
                                               webViewContainer:webViewContainer];
    
    // Imposta la WebView attiva per compatibilità con i delegate methods
    self.webView = [self.tabManager activeWebView];
    
    // === AGGIUNGI TUTTO ALLA FINESTRA ===
    [contentView addSubview:navigationToolbar];
    [contentView addSubview:tabBar];
    [contentView addSubview:webViewContainer];
    
    std::cout << "🎨 Modern UI with MULTI-TAB support completed! Click + to create new tabs!" << std::endl;
}

// ========== DELEGATE METHODS AGGIORNATI PER MULTI-TAB ==========

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL* url = navigationAction.request.URL;
    
    // ✨ GESTIONE WELCOME PAGE per tab multiple
    if ([url.scheme isEqualToString:@"macbird"] && [url.host isEqualToString:@"welcome"]) {
        if (navigationAction.navigationType == WKNavigationTypeReload) {
            std::cout << "🔄 Reloading welcome page in current tab..." << std::endl;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tabManager loadWelcomePage];
            });
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else {
            std::cout << "🏠 Loading welcome page for first time..." << std::endl;
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    
    std::cout << "🌐 Allowing navigation to: " << [url.absoluteString UTF8String] << std::endl;
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    std::cout << "🔄 Navigation started in active tab..." << std::endl;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    std::cout << "✅ Page loaded in active tab - analyzing..." << std::endl;
    
    // ✨ AGGIORNA IL TITOLO DELLA TAB ATTIVA
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            NSString* pageTitle = (NSString*)result;
            if ([pageTitle length] > 0) {
                // Limita il titolo a 20 caratteri per il pulsante tab
                if ([pageTitle length] > 20) {
                    pageTitle = [[pageTitle substringToIndex:17] stringByAppendingString:@"..."];
                }
                
                // Aggiorna il titolo della tab attiva
                if (self.tabManager.activeTab) {
                    self.tabManager.activeTab.title = pageTitle;
                    [self.tabManager.activeTab.tabButton setTitle:pageTitle];
                }
            }
        }
    }];
    
    // JavaScript per analisi browser detection
    NSString* detectionScript = @""
        "console.log('=== MACBIRD BROWSER DETECTION LOG ===');"
        "console.log('User Agent detected:', navigator.userAgent);"
        "console.log('Platform:', navigator.platform);"
        "console.log('Vendor:', navigator.vendor);"
        "console.log('WebKit Version:', navigator.userAgent.match(/WebKit\\/(\\S+)/)?.[1] || 'unknown');"
        "console.log('Safari Version:', navigator.userAgent.match(/Version\\/(\\S+)/)?.[1] || 'unknown');"
        "'MacBird Multi-Tab Detection Complete'";
    
    [webView evaluateJavaScript:detectionScript completionHandler:^(id result, NSError *error) {
        if (error) {
            std::cout << "❌ JavaScript detection error: " << [[error localizedDescription] UTF8String] << std::endl;
        } else {
            std::cout << "🔍 Browser detection completed in active tab" << std::endl;
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    std::cout << "❌ Navigation failed in active tab: " << [[error localizedDescription] UTF8String] << std::endl;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tabManager loadWelcomePage];
    });
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    std::cout << "❌ Provisional navigation failed in active tab: " << [[error localizedDescription] UTF8String] << std::endl;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tabManager loadWelcomePage];
    });
}

// ========== METODI DI NAVIGAZIONE AGGIORNATI PER MULTI-TAB ==========

- (void)navigateToURL:(NSString*)url {
    [self.tabManager navigateToURL:url];
}

- (void)loadWelcomePage {
    [self.tabManager loadWelcomePage];
}

- (void)goBack:(id)sender {
    [self.tabManager goBack];
    std::cout << "← Back button pressed (active tab)" << std::endl;
}

- (void)goForward:(id)sender {
    [self.tabManager goForward];
    std::cout << "→ Forward button pressed (active tab)" << std::endl;
}

- (void)reload:(id)sender {
    [self.tabManager reload];
    std::cout << "↻ Reload button pressed (active tab)" << std::endl;
}

- (void)goHome:(id)sender {
    [self.tabManager loadWelcomePage];
    std::cout << "🏠 Home button pressed (active tab)" << std::endl;
}

// ✨ QUESTO È IL METODO CHIAVE CHE CREA NUOVE TAB!
- (void)newTab:(id)sender {
    [self.tabManager createNewTab];
    std::cout << "📑 ✨ NEW TAB CREATED! ✨ Total tabs: " << [self.tabManager.tabs count] << std::endl;
}

// ✨ DevTools integrati con architettura modulare
- (void)toggleDevTools:(id)sender {
    [self.devToolsManager toggleDevTools];
    std::cout << "🛠️ MacBird DevTools toggled (modular)" << std::endl;
}

@end