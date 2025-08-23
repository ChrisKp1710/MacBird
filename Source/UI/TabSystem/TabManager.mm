#import "TabManager.h"
#import "Platform/macOS/BrowserWindow.h"
#import "Core/Browser/BrowserInfo.h"
#import "DevTools/DevToolsManager.h" // Aggiungi questa riga
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
        
        std::cout << "📑 TabManager initialized with Professional Identity System!" << std::endl;
    }
    return self;
}

- (void)createNewTab {
    std::cout << "📑 Creating new professional tab..." << std::endl;
    
    // Crea la nuova tab
    Tab* newTab = [[Tab alloc] init];
    newTab.title = [NSString stringWithFormat:@"Tab %ld", (long)self.nextTabId];
    newTab.isActive = NO;
    newTab.isOnWelcomePage = YES;
    newTab.tabId = self.nextTabId++;
    
    // Crea la WebView per questa tab CON IDENTITY SYSTEM ENHANCED
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
    
    std::cout << "✅ Professional tab created! Total: " << [self.tabs count] << " (Active: Tab " << newTab.tabId << ")" << std::endl;
}

- (WKWebView*)createWebView {
    // ✨ CONFIGURAZIONE MACBIRD IDENTITY ENHANCED
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    
    // ✅ CONFIGURAZIONE BASE OTTIMIZZATA
    if (@available(macOS 10.15, *)) {
        config.preferences.fraudulentWebsiteWarningEnabled = YES;
        config.preferences.tabFocusesLinks = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    }

    // ✨ CONFIGURAZIONE MODERNA JAVASCRIPT (macOS 11.0+)
    if (@available(macOS 11.0, *)) {
        config.defaultWebpagePreferences.allowsContentJavaScript = YES;
    }
    
    // ✨ MACBIRD IDENTITY INJECTION SCRIPT - ENHANCED VERSION
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    
    NSString* macBirdIdentityScript = [NSString stringWithFormat:@""
        "// ✨ MACBIRD BROWSER IDENTITY INJECTION - ENHANCED V2.0"
        "// Professional browser identity system with full compatibility"
        ""
        "console.log('🐦 MacBird Identity System Loading...');"
        ""
        "// ✨ ENHANCED USER AGENT OVERRIDE"
        "Object.defineProperty(navigator, 'userAgent', {"
        "  get: () => '%@',"
        "  configurable: false,"
        "  enumerable: true"
        "});"
        ""
        "// ✨ BROWSER VENDOR IDENTIFICATION"
        "Object.defineProperty(navigator, 'vendor', {"
        "  get: () => 'Apple Computer, Inc.',"
        "  configurable: false,"
        "  enumerable: true"
        "});"
        ""
        "Object.defineProperty(navigator, 'platform', {"
        "  get: () => '%@',"
        "  configurable: false,"
        "  enumerable: true"
        "});"
        ""
        "// ✨ MACBIRD PROFESSIONAL API"
        "window.macBird = Object.freeze({"
        "  // Core Identity"
        "  name: '%@',"
        "  version: '%@',"
        "  build: '%@',"
        "  buildNumber: '%@',"
        "  codename: '%@',"
        "  fullName: '%@',"
        "  "
        "  // Status Flags"
        "  isMacBird: true,"
        "  isWebKit: true,"
        "  isModern: true,"
        "  isNative: true,"
        "  "
        "  // Platform Info"
        "  platform: {"
        "    name: 'macOS',"
        "    architecture: '%@',"
        "    hardware: '%@'"
        "  },"
        "  "
        "  // Engine Info"
        "  engine: {"
        "    webkit: '%@',"
        "    safari: '%@',"
        "    compatibility: 'full'"
        "  },"
        "  "
        "  // Feature Set"
        "  features: %@,"
        "  "
        "  // ✨ PROFESSIONAL API METHODS"
        "  getVersion: function() {"
        "    return this.version;"
        "  },"
        "  "
        "  getBuild: function() {"
        "    return this.build + ' (' + this.buildNumber + ')';"
        "  },"
        "  "
        "  getFullName: function() {"
        "    return this.fullName;"
        "  },"
        "  "
        "  getSupportedFeatures: function() {"
        "    return Object.keys(this.features).filter(key => this.features[key]);"
        "  },"
        "  "
        "  hasFeature: function(feature) {"
        "    return this.features[feature] === true;"
        "  },"
        "  "
        "  getCapabilities: function() {"
        "    const supported = this.getSupportedFeatures();"
        "    const total = Object.keys(this.features).length;"
        "    return {"
        "      supported: supported,"
        "      count: supported.length,"
        "      total: total,"
        "      percentage: Math.round((supported.length / total) * 100)"
        "    };"
        "  },"
        "  "
        "  getUserAgent: function() {"
        "    return navigator.userAgent;"
        "  },"
        "  "
        "  getPlatformInfo: function() {"
        "    return {"
        "      userAgent: navigator.userAgent,"
        "      vendor: navigator.vendor,"
        "      platform: navigator.platform,"
        "      language: navigator.language,"
        "      languages: navigator.languages,"
        "      cookieEnabled: navigator.cookieEnabled,"
        "      onLine: navigator.onLine,"
        "      hardwareConcurrency: navigator.hardwareConcurrency"
        "    };"
        "  },"
        "  "
        "  // ✨ DETECTION METHODS"
        "  isRecognizedBy: function(siteName) {"
        "    // Future implementation for site-specific detection"
        "    return 'unknown';"
        "  },"
        "  "
        "  getCompatibilityScore: function() {"
        "    const features = this.getCapabilities();"
        "    let score = features.percentage;"
        "    "
        "    // Bonus points for modern browser features"
        "    if (this.hasFeature('webgl2')) score += 5;"
        "    if (this.hasFeature('serviceworker')) score += 5;"
        "    if (this.hasFeature('webassembly')) score += 5;"
        "    if (this.hasFeature('cssgrid')) score += 5;"
        "    "
        "    return Math.min(100, score);"
        "  }"
        "});"
        ""
        "// ✨ ENHANCED CSS.supports POLYFILL"
        "if (window.CSS && !CSS.supports) {"
        "  Object.defineProperty(CSS, 'supports', {"
        "    value: function(property, value) {"
        "      if (arguments.length === 1) {"
        "        // CSS.supports('display: flex')"
        "        const declaration = property.split(':');"
        "        if (declaration.length === 2) {"
        "          return CSS.supports(declaration[0].trim(), declaration[1].trim());"
        "        }"
        "        return false;"
        "      }"
        "      "
        "      try {"
        "        const testElement = document.createElement('div');"
        "        testElement.style.setProperty(property, value);"
        "        const computed = window.getComputedStyle(testElement);"
        "        return computed.getPropertyValue(property) !== '';"
        "      } catch (e) {"
        "        return false;"
        "      }"
        "    },"
        "    writable: false,"
        "    configurable: false"
        "  });"
        "}"
        ""
        "// ✨ ENHANCED FEATURE DETECTION"
        "window.macBird.detectFeatures = function() {"
        "  return {"
        "    // Graphics"
        "    webgl: !!window.WebGLRenderingContext,"
        "    webgl2: !!window.WebGL2RenderingContext,"
        "    canvas: !!window.CanvasRenderingContext2D,"
        "    "
        "    // APIs"
        "    serviceworker: 'serviceWorker' in navigator,"
        "    pushapi: 'PushManager' in window,"
        "    notifications: 'Notification' in window,"
        "    geolocation: 'geolocation' in navigator,"
        "    websockets: 'WebSocket' in window,"
        "    webassembly: 'WebAssembly' in window,"
        "    "
        "    // Storage"
        "    localStorage: 'localStorage' in window,"
        "    sessionStorage: 'sessionStorage' in window,"
        "    indexedDB: 'indexedDB' in window,"
        "    "
        "    // Workers"
        "    webWorkers: 'Worker' in window,"
        "    sharedWorkers: 'SharedWorker' in window,"
        "    "
        "    // Observers"
        "    intersectionObserver: 'IntersectionObserver' in window,"
        "    resizeObserver: 'ResizeObserver' in window,"
        "    mutationObserver: 'MutationObserver' in window,"
        "    performanceObserver: 'PerformanceObserver' in window,"
        "    "
        "    // CSS"
        "    cssSupports: !!(window.CSS && CSS.supports),"
        "    cssGrid: CSS.supports ? CSS.supports('display', 'grid') : false,"
        "    flexbox: CSS.supports ? CSS.supports('display', 'flex') : false,"
        "    customProperties: CSS.supports ? CSS.supports('--test', 'red') : false,"
        "    backdropFilter: CSS.supports ? CSS.supports('backdrop-filter', 'blur(10px)') : false"
        "  };"
        "};"
        ""
        "// ✨ CONSOLE STARTUP MESSAGE"
        "console.log('🐦 MacBird Browser Identity System v2.0 Loaded');"
        "console.log('✅ Browser:', window.macBird.getFullName());"
        "console.log('🔧 Engine:', 'WebKit ' + window.macBird.engine.webkit);"
        "console.log('🎯 Compatibility Score:', window.macBird.getCompatibilityScore() + '/100');"
        "console.log('📊 Features:', window.macBird.getSupportedFeatures().length + ' supported');"
        "console.log('🌐 User-Agent:', navigator.userAgent);"
        "console.log('💡 API available at: window.macBird');"
        "console.log('===============================================');"
        "",
        
        [BrowserInfo compatibilityUserAgent],  // User Agent
        [BrowserInfo platformInfo],            // Platform
        [BrowserInfo browserName],             // Name
        [BrowserInfo browserVersion],          // Version
        [BrowserInfo browserBuild],            // Build
        @"20250125001",                        // Build Number (from Enhanced BrowserInfo)
        [BrowserInfo browserCodename],         // Codename
        [NSString stringWithFormat:@"%@ %@ (%@)", [BrowserInfo browserName], [BrowserInfo browserVersion], [BrowserInfo browserCodename]], // Full Name
        [BrowserInfo architecture],            // Architecture
        @"Apple Silicon",                      // Hardware (Enhanced)
        [BrowserInfo webKitVersion],           // WebKit
        [BrowserInfo safariVersion],           // Safari
        [self featuresJSONString]              // Features
    ];
    
    WKUserScript* macBirdScript = [[WKUserScript alloc] initWithSource:macBirdIdentityScript 
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart 
                                                      forMainFrameOnly:NO];
    [userContentController addUserScript:macBirdScript];
    
    // ✨ AGGIUNGI MESSAGE HANDLER PER CONSOLE LOG
    // TODO: Implementare WKScriptMessageHandler in ConsoleTab
    // [userContentController addScriptMessageHandler:self.browserWindow.devToolsManager.consoleTab name:@"consoleLog"];
    
    config.userContentController = userContentController;
    
    // ✨ CONFIGURAZIONE DATASTORE OTTIMIZZATA
    config.processPool = self.sharedProcessPool;
    config.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
    
    // ✨ CONFIGURAZIONI AVANZATE
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    config.allowsAirPlayForMediaPlayback = YES;
    
    // Crea la WebView con configurazione ottimizzata
    NSRect webViewFrame = [self.webViewContainer bounds];
    WKWebView* webView = [[WKWebView alloc] initWithFrame:webViewFrame configuration:config];
    [webView setWantsLayer:YES];
    [webView.layer setCornerRadius:12.0];
    [webView.layer setMasksToBounds:YES];
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // ✨ IMPOSTA USER AGENT ENHANCED - MACBIRD PROMINENTE
    [webView setCustomUserAgent:[BrowserInfo compatibilityUserAgent]];
    
    // Imposta delegate
    [webView setNavigationDelegate:self.browserWindow];
    [webView setUIDelegate:self.browserWindow];
    
    std::cout << "🐦 Created Professional MacBird WebView!" << std::endl;
    std::cout << "✨ User-Agent: " << [[BrowserInfo compatibilityUserAgent] UTF8String] << std::endl;
    std::cout << "🎯 Identity: MacBird positioned PROMINENTLY before Safari" << std::endl;
    std::cout << "🔧 Features: Enhanced API with professional capabilities" << std::endl;
    
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
    
    std::cout << "🎨 Professional tab button created for Tab " << tab.tabId << " at position " << xPosition << std::endl;
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
    
    // Aggiorna il colore del pulsante tab attivo (viola professionale)
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
    // ✨ ENHANCED WELCOME PAGE CON MACBIRD API INTEGRATION
    NSString* welcomeHTML = [NSString stringWithFormat:@"<!DOCTYPE html>"
    "<html lang=\"en\"><head>"
    "<meta charset=\"UTF-8\">"
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    "<title>MacBird Browser - Professional</title>"
    "<style>"
    "* { margin: 0; padding: 0; box-sizing: border-box; }"
    "body {"
    "  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', Helvetica, sans-serif;"
    "  background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);"
    "  color: white; height: 100vh; display: flex; align-items: center; justify-content: center;"
    "  text-align: center; overflow: hidden; position: relative;"
    "}"
    ".particles { position: absolute; width: 100%%; height: 100%%; overflow: hidden; z-index: 0; }"
    ".particle { position: absolute; width: 4px; height: 4px; background: rgba(255, 255, 255, 0.3);"
    "  border-radius: 50%%; animation: float 6s ease-in-out infinite; }"
    "@keyframes float { 0%%, 100%% { transform: translateY(0px) rotate(0deg); opacity: 0.3; }"
    "  50%% { transform: translateY(-20px) rotate(180deg); opacity: 0.8; } }"
    ".container { max-width: 700px; z-index: 10; position: relative; }"
    ".logo { font-size: 5rem; font-weight: 200; margin-bottom: 1.5rem; animation: logoGlow 3s ease-in-out infinite; }"
    "@keyframes logoGlow { 0%%, 100%% { text-shadow: 0 0 20px rgba(255, 255, 255, 0.5); }"
    "  50%% { text-shadow: 0 0 30px rgba(255, 255, 255, 0.8); } }"
    ".tagline { font-size: 1.6rem; opacity: 0.95; margin-bottom: 1rem; font-weight: 300; letter-spacing: 0.5px; }"
    ".version { font-size: 1rem; opacity: 0.7; margin-bottom: 3rem; font-weight: 400; }"
    ".search-container { margin: 3rem 0; position: relative; }"
    ".search-box { width: 100%%; padding: 1.2rem 1.5rem; font-size: 1.1rem; border: none;"
    "  border-radius: 50px; background: rgba(255, 255, 255, 0.15); color: white;"
    "  backdrop-filter: blur(20px); text-align: center; outline: none; transition: all 0.3s ease;"
    "  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1); }"
    ".search-box:focus { background: rgba(255, 255, 255, 0.25); transform: scale(1.02);"
    "  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.2); }"
    ".search-box::placeholder { color: rgba(255, 255, 255, 0.7); }"
    ".quick-links { display: flex; gap: 1.2rem; justify-content: center; flex-wrap: wrap; margin-bottom: 2rem; }"
    ".quick-link { padding: 0.7rem 1.5rem; background: rgba(255, 255, 255, 0.2);"
    "  border-radius: 30px; text-decoration: none; color: white; font-weight: 500;"
    "  transition: all 0.3s ease; backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.1); }"
    ".quick-link:hover { background: rgba(255, 255, 255, 0.3); transform: translateY(-3px);"
    "  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2); }"
    ".stats { display: flex; justify-content: center; gap: 2rem; margin-top: 2rem; flex-wrap: wrap; }"
    ".stat-item { text-align: center; opacity: 0.8; }"
    ".stat-number { font-size: 1.5rem; font-weight: 600; color: #fff; }"
    ".stat-label { font-size: 0.9rem; opacity: 0.7; margin-top: 0.2rem; }"
    ".tab-info { position: absolute; top: 25px; right: 25px; font-size: 0.9rem; opacity: 0.6;"
    "  background: rgba(0, 0, 0, 0.2); padding: 0.5rem 1rem; border-radius: 20px; backdrop-filter: blur(10px); }"
    ".features-info { position: absolute; bottom: 25px; left: 25px; font-size: 0.8rem; opacity: 0.6;"
    "  background: rgba(0, 0, 0, 0.2); padding: 0.5rem 1rem; border-radius: 15px; backdrop-filter: blur(10px); }"
    "@media (max-width: 768px) { .logo { font-size: 3.5rem; } .tagline { font-size: 1.3rem; }"
    "  .quick-links { gap: 0.8rem; } .stats { gap: 1rem; } }"
    "</style>"
    "</head><body>"
    "<div class=\"particles\" id=\"particles\"></div>"
    "<div class=\"tab-info\">Tab <span id=\"tabNumber\">%ld</span></div>"
    "<div class=\"container\">"
    "  <div class=\"logo\">🐦 MacBird</div>"
    "  <div class=\"tagline\">Il Browser Nativo Professionale per macOS</div>"
    "  <div class=\"version\">Version <span id=\"version\">1.0.0</span> - Swift Eagle</div>"
    "  <div class=\"search-container\">"
    "    <input type=\"text\" class=\"search-box\" placeholder=\"Cerca con Google o inserisci un indirizzo...\" id=\"searchBox\">"
    "  </div>"
    "  <div class=\"quick-links\">"
    "    <a href=\"https://google.com\" class=\"quick-link\">Google</a>"
    "    <a href=\"https://youtube.com\" class=\"quick-link\">YouTube</a>"
    "    <a href=\"https://github.com\" class=\"quick-link\">GitHub</a>"
    "    <a href=\"https://apple.com\" class=\"quick-link\">Apple</a>"
    "    <a href=\"https://twitter.com\" class=\"quick-link\">Twitter</a>"
    "  </div>"
    "  <div class=\"stats\">"
    "    <div class=\"stat-item\">"
    "      <div class=\"stat-number\" id=\"featuresCount\">25+</div>"
    "      <div class=\"stat-label\">Modern Features</div>"
    "    </div>"
    "    <div class=\"stat-item\">"
    "      <div class=\"stat-number\">100%%</div>"
    "      <div class=\"stat-label\">WebKit Compatible</div>"
    "    </div>"
    "    <div class=\"stat-item\">"
    "      <div class=\"stat-number\" id=\"compatibilityScore\">95%%</div>"
    "      <div class=\"stat-label\">Site Compatibility</div>"
    "    </div>"
    "  </div>"
    "</div>"
    "<div class=\"features-info\">"
    "  <div>🔒 Enhanced Privacy • 🛠️ DevTools • 📑 Multi-Tab • ⚡ Native Performance</div>"
    "</div>"
    "<script>"
    "// ✨ MACBIRD ENHANCED WELCOME PAGE SCRIPT"
    "function createParticles() {"
    "  const particlesContainer = document.getElementById('particles');"
    "  for (let i = 0; i < 20; i++) {"
    "    const particle = document.createElement('div');"
    "    particle.className = 'particle';"
    "    particle.style.left = Math.random() * 100 + '%%';"
    "    particle.style.animationDelay = Math.random() * 6 + 's';"
    "    particle.style.animationDuration = (4 + Math.random() * 4) + 's';"
    "    particlesContainer.appendChild(particle);"
    "  }"
    "}"
    "function initializeMacBirdInfo() {"
    "  if (typeof window.macBird !== 'undefined') {"
    "    document.getElementById('version').textContent = window.macBird.version;"
    "    const featuresCount = window.macBird.getSupportedFeatures().length;"
    "    document.getElementById('featuresCount').textContent = featuresCount + '+';"
    "    const compatibilityScore = window.macBird.getCompatibilityScore();"
    "    document.getElementById('compatibilityScore').textContent = compatibilityScore + '%%';"
    "    console.log('🐦 Welcome Page Enhanced with MacBird API');"
    "    console.log('📊 Browser Info:', window.macBird.getFullName());"
    "    console.log('🎯 Compatibility:', compatibilityScore + '/100');"
    "    console.log('✨ Features:', featuresCount + ' supported');"
    "  } else { console.warn('⚠️ MacBird API not available on welcome page'); }"
    "}"
    "function initializeSearch() {"
    "  const searchBox = document.getElementById('searchBox');"
    "  searchBox.addEventListener('keypress', function(e) {"
    "    if (e.key === 'Enter') {"
    "      const query = this.value.trim();"
    "      if (!query) return;"
    "      console.log('🔍 Search initiated:', query);"
    "      if (isURL(query)) {"
    "        const url = query.startsWith('http') ? query : 'https://' + query;"
    "        console.log('🌐 Navigating to URL:', url);"
    "        window.location.href = url;"
    "      } else {"
    "        const searchURL = 'https://www.google.com/search?q=' + encodeURIComponent(query);"
    "        console.log('🔍 Google search:', searchURL);"
    "        window.location.href = searchURL;"
    "      }"
    "    }"
    "  });"
    "  document.addEventListener('keydown', function(e) {"
    "    if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {"
    "      searchBox.focus();"
    "    }"
    "  });"
    "}"
    "function isURL(string) {"
    "  try {"
    "    const domainPattern = /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$/;"
    "    const wwwPattern = /^www\\.[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$/;"
    "    const httpPattern = /^https?:\\/\\//;"
    "    return httpPattern.test(string) || domainPattern.test(string) || wwwPattern.test(string) ||"
    "           (string.includes('.') && !string.includes(' '));"
    "  } catch { return false; }"
    "}"
    "document.addEventListener('DOMContentLoaded', function() {"
    "  createParticles();"
    "  initializeSearch();"
    "  setTimeout(initializeMacBirdInfo, 100);"
    "  console.log('🏠 MacBird Professional Welcome Page Loaded');"
    "  console.log('🎨 Enhanced design with MacBird API integration');"
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
    
    std::cout << "🌐 Navigating professional tab (" << self.activeTab.tabId << ") to: " << [url UTF8String] << std::endl;
    
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
        
        // ✨ USA MACBIRD IDENTITY SYSTEM ENHANCED
        
        // USER-AGENT PROMINENTE: MacBird PRIMA di Safari per massima visibilità
        NSString* userAgent = [BrowserInfo compatibilityUserAgent];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        // ✨ HEADERS PROFESSIONALI DA BROWSERINFO
        NSDictionary* browserHeaders = [BrowserInfo browserHeaders];
        for (NSString* header in browserHeaders) {
            if (![header isEqualToString:@"User-Agent"]) { // Già impostato sopra
                [request setValue:browserHeaders[header] forHTTPHeaderField:header];
            }
        }
        
        // ✨ SECURITY HEADERS ENHANCED
        NSDictionary* securityHeaders = [BrowserInfo securityHeaders];
        for (NSString* header in securityHeaders) {
            [request setValue:securityHeaders[header] forHTTPHeaderField:header];
        }
        
        // ✨ PERFORMANCE HEADERS
        NSDictionary* performanceHeaders = [BrowserInfo performanceHeaders];
        for (NSString* header in performanceHeaders) {
            [request setValue:performanceHeaders[header] forHTTPHeaderField:header];
        }
        
        [self.activeTab.webView loadRequest:request];
        
        // Aggiorna il titolo della tab
        self.activeTab.title = @"Caricamento...";
        [self.activeTab.tabButton setTitle:self.activeTab.title];
        
        std::cout << "✅ Loading in Professional Tab " << self.activeTab.tabId << " with MacBird Enhanced Identity..." << std::endl;
        std::cout << "🐦 User-Agent (Prominent): " << [userAgent UTF8String] << std::endl;
        std::cout << "🎯 Identity Position: MacBird positioned BEFORE Safari for maximum recognition" << std::endl;
    }
}

// ✨ HELPER METHOD FOR FEATURES JSON
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