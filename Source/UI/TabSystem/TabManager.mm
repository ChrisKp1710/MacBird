#import "TabManager.h"
#import "Platform/macOS/BrowserWindow.h"
#import "Core/Browser/BrowserInfo.h" 
#include <iostream>

@implementation TabManager

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window 
                       tabBarContainer:(NSView*)tabBar 
                     webViewContainer:(NSView*)webViewContainer {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.tabBarContainer = tabBar;
        self.webViewContainer = webViewContainer;
        self.tabs = [[NSMutableArray alloc] init];
        self.nextTabId = 1;
        
        // ✨ NUOVO: Crea pool condivisi MA SEPARATI per ogni sessione
        self.sharedProcessPool = [[WKProcessPool alloc] init];
        self.sharedDataStore = [WKWebsiteDataStore nonPersistentDataStore];
        
        // Crea la prima tab automaticamente
        [self createNewTab];
        
        std::cout << "📑 TabManager initialized with isolated tabs - Ready for multiple tabs!" << std::endl;
    }
    return self;
}

- (void)createNewTab {
    std::cout << "📑 Creating new isolated tab..." << std::endl;
    
    // Crea la nuova tab
    Tab* newTab = [[Tab alloc] init];
    newTab.title = [NSString stringWithFormat:@"Tab %ld", (long)self.nextTabId];
    newTab.isActive = NO;
    newTab.isOnWelcomePage = YES;
    newTab.tabId = self.nextTabId++;
    
    // Crea la WebView per questa tab
    newTab.webView = [self createWebView];
    [newTab.webView setHidden:YES]; // Nascondi inizialmente
    [self.webViewContainer addSubview:newTab.webView];
    
    // Crea il pulsante tab CON PULSANTE X
    [self createTabButtonForTab:newTab];
    
    // Aggiungi la tab alla lista
    [self.tabs addObject:newTab];
    
    // Switcha automaticamente alla nuova tab
    [self switchToTab:newTab];
    
    // Carica la welcome page nella nuova tab
    [self loadWelcomePageInTab:newTab];
    
    // Aggiorna il layout delle tab
    [self updateTabLayout];
    
    std::cout << "✅ New isolated tab created! Total tabs: " << [self.tabs count] << " (Active: Tab " << newTab.tabId << ")" << std::endl;
}

- (WKWebView*)createWebView {
    // ✨ CONFIGURAZIONE MACBIRD IDENTITY
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    
    // ✅ CONFIGURAZIONE BASE
    if (@available(macOS 10.15, *)) {
        config.preferences.fraudulentWebsiteWarningEnabled = YES;
        config.preferences.tabFocusesLinks = YES;
        // JavaScript è abilitato di default nelle WebView moderne
    }

    // ✨ CONFIGURAZIONE MODERNA JAVASCRIPT (macOS 11.0+)
    if (@available(macOS 11.0, *)) {
        config.defaultWebpagePreferences.allowsContentJavaScript = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    } else {
        // Fallback per versioni precedenti
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    }
    
    // ✨ SCRIPT MACBIRD IDENTITY INJECTION
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    
    NSString* macBirdIdentityScript = [NSString stringWithFormat:@""
        "// ✨ MACBIRD BROWSER IDENTITY INJECTION"
        "// Questo script definisce MacBird come browser unico"
        ""
        "// ✨ OVERRIDE USER AGENT CON MACBIRD IDENTITY"
        "Object.defineProperty(navigator, 'userAgent', {"
        "  get: () => '%@'"
        "});"
        ""
        "// ✨ MACBIRD BROWSER IDENTIFICATION"
        "Object.defineProperty(navigator, 'vendor', {"
        "  get: () => 'Apple Computer, Inc.'"
        "});"
        ""
        "Object.defineProperty(navigator, 'platform', {"
        "  get: () => '%@'"
        "});"
        ""
        "// ✨ MACBIRD UNIQUE FEATURES API"
        "window.macBird = {"
        "  name: '%@',"
        "  version: '%@',"
        "  build: '%@',"
        "  codename: '%@',"
        "  features: %@,"
        "  isMacBird: true,"
        "  isWebKit: true,"
        "  supportedFeatures: function() {"
        "    return Object.keys(this.features).filter(key => this.features[key]);"
        "  },"
        "  hasFeature: function(feature) {"
        "    return this.features[feature] === true;"
        "  }"
        "};"
        ""
        "// ✨ POLYFILL CSS.supports SE MANCANTE"
        "if (window.CSS && !CSS.supports) {"
        "  Object.defineProperty(CSS, 'supports', {"
        "    value: function(property, value) {"
        "      try {"
        "        const testElement = document.createElement('div');"
        "        testElement.style.setProperty(property, value);"
        "        return testElement.style.getPropertyValue(property) !== '';"
        "      } catch (e) {"
        "        return false;"
        "      }"
        "    },"
        "    writable: false,"
        "    configurable: false"
        "  });"
        "}"
        ""
        "console.log('🐦 MacBird Browser Identity loaded - Version %@ (%@)');"
        "console.log('✅ MacBird API available at window.macBird');"
        "console.log('🔧 Supported features:', window.macBird.supportedFeatures());",
        
        [BrowserInfo compatibilityUserAgent],
        [BrowserInfo platformInfo],
        [BrowserInfo browserName],
        [BrowserInfo browserVersion], 
        [BrowserInfo browserBuild],
        [BrowserInfo browserCodename],
        [self featuresJSONString],
        [BrowserInfo browserVersion],
        [BrowserInfo browserCodename]
    ];
    
    WKUserScript* macBirdScript = [[WKUserScript alloc] initWithSource:macBirdIdentityScript 
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart 
                                                      forMainFrameOnly:NO];
    [userContentController addUserScript:macBirdScript];
    
    config.userContentController = userContentController;
    
    // ✨ CONFIGURAZIONE DATASTORE 
    config.processPool = self.sharedProcessPool;
    config.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
    
    // Crea la WebView con la configurazione
    NSRect webViewFrame = [self.webViewContainer bounds];
    WKWebView* webView = [[WKWebView alloc] initWithFrame:webViewFrame configuration:config];
    [webView setWantsLayer:YES];
    [webView.layer setCornerRadius:12.0];
    [webView.layer setMasksToBounds:YES];
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // ✨ IMPOSTA MACBIRD USER AGENT SULLA WEBVIEW
    [webView setCustomUserAgent:[BrowserInfo compatibilityUserAgent]];
    
    // Imposta il BrowserWindow come delegate per tutte le WebView
    [webView setNavigationDelegate:self.browserWindow];
    [webView setUIDelegate:self.browserWindow];
    
    std::cout << "🐦 Created MacBird WebView with authentic identity!" << std::endl;
    
    return webView;
}

- (void)createTabButtonForTab:(Tab*)tab {
    // Calcola la posizione del nuovo pulsante tab (con spazio per il pulsante X)
    CGFloat xPosition = 9 + ([self.tabs count] * 170); // 160 width + 10 gap
    
    // ✨ PULSANTE TAB PRINCIPALE
    NSButton* tabButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPosition, 6, 160, 32)];
    [tabButton setTitle:tab.title];
    [tabButton setFont:[NSFont systemFontOfSize:13 weight:NSFontWeightMedium]];
    [tabButton setBordered:NO];
    [tabButton setWantsLayer:YES];
    [tabButton.layer setBackgroundColor:[NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor];
    [tabButton.layer setCornerRadius:10];
    
    // Aggiungi target per il click sulla tab
    [tabButton setTarget:self];
    [tabButton setAction:@selector(tabButtonClicked:)];
    [tabButton setTag:tab.tabId]; // Usa l'ID univoco della tab
    
    // ✨ PULSANTE X PER CHIUDERE LA TAB
    NSButton* closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(xPosition + 135, 10, 20, 20)];
    [closeButton setTitle:@"✕"];
    [closeButton setFont:[NSFont systemFontOfSize:12]];
    [closeButton setBordered:NO];
    [closeButton setWantsLayer:YES];
    [closeButton.layer setBackgroundColor:[NSColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor];
    [closeButton.layer setCornerRadius:10];
    
    // Aggiungi target per il click sul pulsante X
    [closeButton setTarget:self];
    [closeButton setAction:@selector(closeButtonClicked:)];
    [closeButton setTag:tab.tabId]; // Usa l'ID univoco della tab
    
    // Nascondi il pulsante X se è l'unica tab
    if ([self.tabs count] == 0) { // La prima tab non può essere chiusa
        [closeButton setHidden:YES];
    }
    
    // Assegna i pulsanti alla tab
    tab.tabButton = tabButton;
    tab.closeButton = closeButton;
    
    // Aggiungi i pulsanti alla tab bar
    [self.tabBarContainer addSubview:tabButton];
    [self.tabBarContainer addSubview:closeButton];
    
    std::cout << "🎨 Tab button created for Tab " << tab.tabId << " at position " << xPosition << std::endl;
}

- (void)tabButtonClicked:(NSButton*)sender {
    NSInteger tabId = [sender tag];
    Tab* clickedTab = [self findTabById:tabId];
    
    if (clickedTab) {
        [self switchToTab:clickedTab];
        std::cout << "📑 Switched to Tab " << tabId << " (" << [clickedTab.title UTF8String] << ")" << std::endl;
    }
}

- (void)closeButtonClicked:(NSButton*)sender {
    NSInteger tabId = [sender tag];
    Tab* tabToClose = [self findTabById:tabId];
    
    if (tabToClose) {
        [self closeTab:tabToClose];
        std::cout << "❌ Closed Tab " << tabId << std::endl;
    }
}

- (Tab*)findTabById:(NSInteger)tabId {
    for (Tab* tab in self.tabs) {
        if (tab.tabId == tabId) {
            return tab;
        }
    }
    return nil;
}

- (void)switchToTab:(Tab*)tab {
    // Nascondi la WebView attualmente attiva
    if (self.activeTab) {
        [self.activeTab.webView setHidden:YES];
        self.activeTab.isActive = NO;
        
        // Aggiorna il colore del pulsante tab precedente (inattivo)
        [self.activeTab.tabButton.layer setBackgroundColor:[NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor];
    }
    
    // Attiva la nuova tab
    self.activeTab = tab;
    tab.isActive = YES;
    
    // Mostra la WebView della nuova tab
    [tab.webView setHidden:NO];
    
    // Aggiorna il colore del pulsante tab attivo (viola)
    [tab.tabButton.layer setBackgroundColor:[NSColor colorWithRed:0.4 green:0.3 blue:0.8 alpha:1.0].CGColor];
    
    // Aggiorna la WebView nel BrowserWindow per i delegate methods
    self.browserWindow.webView = tab.webView;
    
    std::cout << "📑 Active tab switched to: " << [tab.title UTF8String] << " (ID: " << tab.tabId << ")" << std::endl;
}

- (void)closeTab:(Tab*)tab {
    // Non permettere di chiudere l'ultima tab
    if ([self.tabs count] <= 1) {
        std::cout << "⚠️ Cannot close the last tab!" << std::endl;
        return;
    }
    
    std::cout << "🗑️ Closing Tab " << tab.tabId << " (" << [tab.title UTF8String] << ")..." << std::endl;
    
    // Rimuovi la WebView
    [tab.webView removeFromSuperview];
    
    // Rimuovi i pulsanti tab
    [tab.tabButton removeFromSuperview];
    [tab.closeButton removeFromSuperview];
    
    // Se stiamo chiudendo la tab attiva, switcha a un'altra
    if (tab == self.activeTab) {
        NSInteger currentIndex = [self.tabs indexOfObject:tab];
        NSInteger newActiveIndex;
        
        // Scegli la tab a sinistra, o a destra se è la prima
        if (currentIndex > 0) {
            newActiveIndex = currentIndex - 1;
        } else {
            newActiveIndex = 0; // Prendi la prima tab rimanente
        }
        
        // Rimuovi la tab dalla lista prima di switchare
        [self.tabs removeObject:tab];
        
        // Switcha alla nuova tab attiva
        if ([self.tabs count] > 0) {
            Tab* newActiveTab = self.tabs[newActiveIndex];
            [self switchToTab:newActiveTab];
        }
    } else {
        // Se non era la tab attiva, rimuovi semplicemente dalla lista
        [self.tabs removeObject:tab];
    }
    
    // Aggiorna il layout per riposizionare le tab rimanenti
    [self updateTabLayout];
    
    // Nascondi il pulsante X se rimane solo una tab
    if ([self.tabs count] == 1) {
        [self.tabs[0].closeButton setHidden:YES];
    }
    
    std::cout << "✅ Tab closed. Remaining tabs: " << [self.tabs count] << std::endl;
}

- (void)updateTabLayout {
    // Riposiziona tutti i pulsanti tab
    for (NSInteger i = 0; i < [self.tabs count]; i++) {
        Tab* tab = self.tabs[i];
        CGFloat xPosition = 9 + (i * 170); // 160 width + 10 gap
        
        // Riposiziona il pulsante tab principale
        NSRect tabFrame = tab.tabButton.frame;
        tabFrame.origin.x = xPosition;
        [tab.tabButton setFrame:tabFrame];
        
        // Riposiziona il pulsante X
        NSRect closeFrame = tab.closeButton.frame;
        closeFrame.origin.x = xPosition + 135;
        [tab.closeButton setFrame:closeFrame];
        
        // Mostra il pulsante X se ci sono più di una tab
        [tab.closeButton setHidden:([self.tabs count] <= 1)];
    }
    
    // Aggiorna la posizione del pulsante "+"
    [self updateNewTabButtonPosition];
}

- (void)updateNewTabButtonPosition {
    // Trova il pulsante "+" e riposizionalo dopo l'ultima tab
    for (NSView* subview in [self.tabBarContainer subviews]) {
        if ([subview isKindOfClass:[NSButton class]]) {
            NSButton* button = (NSButton*)subview;
            if ([[button title] isEqualToString:@"+"]) {
                CGFloat newXPosition = 9 + ([self.tabs count] * 170) + 10; // Dopo l'ultima tab
                NSRect newFrame = button.frame;
                newFrame.origin.x = newXPosition;
                [button setFrame:newFrame];
                break;
            }
        }
    }
}

- (void)loadWelcomePageInTab:(Tab*)tab {
    NSString* welcomeHTML = [NSString stringWithFormat:@"<!DOCTYPE html>"
    "<html><head>"
    "<meta charset='UTF-8'>"
    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    "<title>MacBird Browser</title>"
    "<style>"
    "* { margin: 0; padding: 0; box-sizing: border-box; }"
    "body { "
    "  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;"
    "  background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);"
    "  color: white; height: 100vh; display: flex; align-items: center; justify-content: center;"
    "  text-align: center;"
    "}"
    ".container { max-width: 600px; }"
    ".logo { font-size: 4rem; font-weight: 300; margin-bottom: 1rem; }"
    ".tagline { font-size: 1.5rem; opacity: 0.9; margin-bottom: 2rem; font-weight: 300; }"
    ".search-container { margin: 2rem 0; }"
    ".search-box { "
    "  width: 100%%; padding: 1rem; font-size: 1.1rem; border: none; border-radius: 50px;"
    "  background: rgba(255,255,255,0.15); color: white; backdrop-filter: blur(10px);"
    "  text-align: center; outline: none;"
    "}"
    ".search-box::placeholder { color: rgba(255,255,255,0.7); }"
    ".quick-links { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }"
    ".quick-link { "
    "  padding: 0.5rem 1rem; background: rgba(255,255,255,0.2); border-radius: 25px;"
    "  text-decoration: none; color: white; transition: all 0.3s ease;"
    "}"
    ".quick-link:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); }"
    ".tab-info { position: absolute; top: 20px; right: 20px; font-size: 0.9rem; opacity: 0.7; }"
    "</style>"
    "</head><body>"
    "<div class='tab-info'>Tab %ld</div>"
    "<div class='container'>"
    "  <div class='logo'>🐦 MacBird</div>"
    "  <div class='tagline'>Il tuo browser nativo per macOS</div>"
    "  <div class='search-container'>"
    "    <input type='text' class='search-box' placeholder='Cerca con Google o inserisci un indirizzo...' id='searchBox'>"
    "  </div>"
    "  <div class='quick-links'>"
    "    <a href='https://google.com' class='quick-link'>Google</a>"
    "    <a href='https://youtube.com' class='quick-link'>YouTube</a>"
    "    <a href='https://github.com' class='quick-link'>GitHub</a>"
    "    <a href='https://apple.com' class='quick-link'>Apple</a>"
    "  </div>"
    "</div>"
    "<script>"
    "document.getElementById('searchBox').addEventListener('keypress', function(e) {"
    "  if (e.key === 'Enter') {"
    "    const query = this.value;"
    "    if (query.includes('.') && !query.includes(' ')) {"
    "      window.location.href = query.startsWith('http') ? query : 'https://' + query;"
    "    } else {"
    "      window.location.href = 'https://www.google.com/search?q=' + encodeURIComponent(query);"
    "    }"
    "  }"
    "});"
    "</script>"
    "</body></html>", (long)tab.tabId];
    
    NSURL* welcomeURL = [NSURL URLWithString:@"macbird://welcome"];
    [tab.webView loadHTMLString:welcomeHTML baseURL:welcomeURL];
    
    tab.isOnWelcomePage = YES;
    tab.title = [NSString stringWithFormat:@"Tab %ld", (long)tab.tabId];
    [tab.tabButton setTitle:tab.title];
}

// ========== METODI PUBBLICI PER INTERFACCIA ==========

- (WKWebView*)activeWebView {
    return self.activeTab.webView;
}

- (void)navigateToURL:(NSString*)url {
    if (!self.activeTab) return;
    
    std::cout << "🌐 Navigating active tab (" << self.activeTab.tabId << ") to: " << [url UTF8String] << std::endl;
    
    if ([url length] == 0) {
        [self loadWelcomePage];
        return;
    }
    
    self.activeTab.isOnWelcomePage = NO;
    
    // Aggiunge protocollo se mancante
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        if ([url hasPrefix:@"www."] || ([url containsString:@"."] && ![url containsString:@" "])) {
            url = [@"https://" stringByAppendingString:url];
        } else {
            url = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
    }
    
    NSURL* nsUrl = [NSURL URLWithString:url];
    if (nsUrl) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
        
        // ✨ USA MACBIRD IDENTITY SYSTEM
        
        // FASE TRANSITORIA: Compatibility User-Agent
        // (Mantiene Safari ma aggiunge MacBird per identificazione)
        NSString* userAgent = [BrowserInfo compatibilityUserAgent];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        // ✨ HEADERS STANDARD DA BROWSERINFO
        NSDictionary* browserHeaders = [BrowserInfo browserHeaders];
        for (NSString* header in browserHeaders) {
            if (![header isEqualToString:@"User-Agent"]) { // Già impostato sopra
                [request setValue:browserHeaders[header] forHTTPHeaderField:header];
            }
        }
        
        // ✨ SECURITY HEADERS DA BROWSERINFO  
        NSDictionary* securityHeaders = [BrowserInfo securityHeaders];
        for (NSString* header in securityHeaders) {
            [request setValue:securityHeaders[header] forHTTPHeaderField:header];
        }
        
        // ✨ PERFORMANCE HEADERS DA BROWSERINFO
        NSDictionary* performanceHeaders = [BrowserInfo performanceHeaders];
        for (NSString* header in performanceHeaders) {
            [request setValue:performanceHeaders[header] forHTTPHeaderField:header];
        }
        
        [self.activeTab.webView loadRequest:request];
        
        // Aggiorna il titolo della tab
        self.activeTab.title = @"Caricamento...";
        [self.activeTab.tabButton setTitle:self.activeTab.title];
        
        std::cout << "✅ Loading in Tab " << self.activeTab.tabId << " with MacBird Identity System..." << std::endl;
        std::cout << "🐦 User-Agent: " << [userAgent UTF8String] << std::endl;
    }
}


// ✨ AGGIUNGI QUESTO NUOVO METODO HELPER ALLA FINE DEL FILE:
- (NSString*)featuresJSONString {
    NSDictionary* features = [BrowserInfo supportedFeatures];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:features 
                                                       options:0 
                                                         error:&error];
    if (error) {
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)loadWelcomePage {
    if (self.activeTab) {
        [self loadWelcomePageInTab:self.activeTab];
    }
}

- (void)goBack {
    if (self.activeTab && [self.activeTab.webView canGoBack]) {
        [self.activeTab.webView goBack];
    }
}

- (void)goForward {
    if (self.activeTab && [self.activeTab.webView canGoForward]) {
        [self.activeTab.webView goForward];
    }
}

- (void)reload {
    if (self.activeTab) {
        [self.activeTab.webView reload];
    }
}

@end