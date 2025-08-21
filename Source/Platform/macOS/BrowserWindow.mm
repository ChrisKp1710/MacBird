#import "BrowserWindow.h"
#import "MenuManager.h"
#import "DevTools/DevToolsManager.h"
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
        
        std::cout << "🪟 Modern MacBird Browser window created with modular DevTools architecture" << std::endl;
    }
    
    return self;
}

- (void)setupModernUI {
    NSView* contentView = [self contentView];
    
    // === TOOLBAR DI NAVIGAZIONE (CENTRATA E UNIFORME) ===
    NSView* navigationToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, [contentView frame].size.height - 55, 290, 55)];
    [navigationToolbar setWantsLayer:YES];
    [navigationToolbar.layer setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0].CGColor];
    [navigationToolbar setAutoresizingMask:NSViewMinYMargin];
    
    // Menu hamburger (perfettamente centrato)
    NSButton* menuButton = [[NSButton alloc] initWithFrame:NSMakeRect(82, 11.5, 32, 32)];
    [menuButton setTitle:@"☰"];
    [menuButton setFont:[NSFont systemFontOfSize:16]];
    [menuButton setBordered:NO];
    [menuButton setWantsLayer:YES];
    [menuButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [menuButton.layer setCornerRadius:6];
    
    // Pulsante Indietro (perfettamente centrato)
    NSButton* backButton = [[NSButton alloc] initWithFrame:NSMakeRect(122, 11.5, 32, 32)];
    [backButton setTitle:@"←"];
    [backButton setFont:[NSFont systemFontOfSize:18]];
    [backButton setBordered:NO];
    [backButton setTarget:self];
    [backButton setAction:@selector(goBack:)];
    [backButton setWantsLayer:YES];
    [backButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [backButton.layer setCornerRadius:6];
    
    // Pulsante Avanti (perfettamente centrato)
    NSButton* forwardButton = [[NSButton alloc] initWithFrame:NSMakeRect(162, 11.5, 32, 32)];
    [forwardButton setTitle:@"→"];
    [forwardButton setFont:[NSFont systemFontOfSize:18]];
    [forwardButton setBordered:NO];
    [forwardButton setTarget:self];
    [forwardButton setAction:@selector(goForward:)];
    [forwardButton setWantsLayer:YES];
    [forwardButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [forwardButton.layer setCornerRadius:6];
    
    // Pulsante Reload (perfettamente centrato)
    NSButton* reloadButton = [[NSButton alloc] initWithFrame:NSMakeRect(202, 11.5, 32, 32)];
    [reloadButton setTitle:@"↻"];
    [reloadButton setFont:[NSFont systemFontOfSize:18]];
    [reloadButton setBordered:NO];
    [reloadButton setTarget:self];
    [reloadButton setAction:@selector(reload:)];
    [reloadButton setWantsLayer:YES];
    [reloadButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [reloadButton.layer setCornerRadius:6];
    
    // Pulsante Home (perfettamente centrato)
     NSButton* homeButton = [[NSButton alloc] initWithFrame:NSMakeRect(242, 11.5, 32, 32)];
    [homeButton setTitle:@"🏠"];
    [homeButton setFont:[NSFont systemFontOfSize:16]];
    [homeButton setBordered:NO];
    [homeButton setTarget:self];
    [homeButton setAction:@selector(goHome:)];
    [homeButton setWantsLayer:YES];
    [homeButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [homeButton.layer setCornerRadius:6];
    
    [navigationToolbar addSubview:menuButton];
    [navigationToolbar addSubview:backButton];
    [navigationToolbar addSubview:forwardButton];
    [navigationToolbar addSubview:reloadButton];
    [navigationToolbar addSubview:homeButton];
    
    // ✨ NUOVO: BARRA DIVISORIA ELEGANTE (QUASI INVISIBILE)
    NSView* separatorLine = [[NSView alloc] initWithFrame:NSMakeRect(289, [contentView frame].size.height - 50, 1, 45)];
    [separatorLine setWantsLayer:YES];
    [separatorLine.layer setBackgroundColor:[NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.6].CGColor];
    [separatorLine setAutoresizingMask:NSViewMinYMargin];
    
    // === SISTEMA TAB (STESSO GRIGIO, CENTRATO, CON SPAZIO PER SEPARATORE) ===
    NSView* tabBar = [[NSView alloc] initWithFrame:NSMakeRect(295, [contentView frame].size.height - 55, [contentView frame].size.width - 295, 55)];
    [tabBar setWantsLayer:YES];
    [tabBar.layer setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0].CGColor];
    [tabBar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    
    // Tab attivo (perfettamente centrato, spostato leggermente per il separatore)
    NSButton* activeTab = [[NSButton alloc] initWithFrame:NSMakeRect(15, 11.5, 150, 32)];
    [activeTab setTitle:@"MacBird Tab"];
    [activeTab setFont:[NSFont systemFontOfSize:13 weight:NSFontWeightMedium]];
    [activeTab setBordered:NO];
    [activeTab setWantsLayer:YES];
    [activeTab.layer setBackgroundColor:[NSColor colorWithRed:0.4 green:0.3 blue:0.8 alpha:1.0].CGColor];
    [activeTab.layer setCornerRadius:10];
    
    // Tab inattivo (perfettamente centrato, spostato leggermente per il separatore)
    NSButton* inactiveTab = [[NSButton alloc] initWithFrame:NSMakeRect(175, 11.5, 150, 32)];
    [inactiveTab setTitle:@"Nuova Tab"];
    [inactiveTab setFont:[NSFont systemFontOfSize:13]];
    [inactiveTab setBordered:NO];
    [inactiveTab setWantsLayer:YES];
    [inactiveTab.layer setBackgroundColor:[NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor];
    [inactiveTab.layer setCornerRadius:10];
    
    // Pulsante + per nuova tab (perfettamente centrato, spostato leggermente per il separatore)
    NSButton* newTabButton = [[NSButton alloc] initWithFrame:NSMakeRect(335, 11.5, 32, 32)];
    [newTabButton setTitle:@"+"];
    [newTabButton setFont:[NSFont systemFontOfSize:18]];
    [newTabButton setBordered:NO];
    [newTabButton setTarget:self];
    [newTabButton setAction:@selector(newTab:)];
    [newTabButton setWantsLayer:YES];
    [newTabButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [newTabButton.layer setCornerRadius:6];
    
    [tabBar addSubview:activeTab];
    [tabBar addSubview:inactiveTab];
    [tabBar addSubview:newTabButton];
    
    // === WEBVIEW CON CONFIGURAZIONE WEBKIT MODERNA + DEBUG ===
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    if (@available(macOS 10.15, *)) {
        config.preferences.fraudulentWebsiteWarningEnabled = YES;
        config.preferences.tabFocusesLinks = YES;
    }
    
    if (@available(macOS 10.12, *)) {
        config.allowsAirPlayForMediaPlayback = YES;
        config.suppressesIncrementalRendering = NO;
    }
    if (@available(macOS 10.13, *)) {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }
    
    if (@available(macOS 10.15, *)) {
        config.limitsNavigationsToAppBoundDomains = NO;
        if (@available(macOS 11.0, *)) {
            config.upgradeKnownHostsToHTTPS = YES;
        }
    }
    
    if (@available(macOS 12.0, *)) {
        config.preferences.elementFullscreenEnabled = YES;
        config.preferences.textInteractionEnabled = YES;
    }
    
    if (@available(macOS 13.0, *)) {
        config.preferences.siteSpecificQuirksModeEnabled = NO;
    }
    
    // Script minimo per feature native
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    
    NSString* enableFeaturesScript = @""
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
        "console.log('✅ MacBird: Feature native abilitate');";
    
    WKUserScript* enableScript = [[WKUserScript alloc] initWithSource:enableFeaturesScript 
                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentStart 
                                                     forMainFrameOnly:NO];
    [userContentController addUserScript:enableScript];
    
    config.userContentController = userContentController;
    config.processPool = [[WKProcessPool alloc] init];
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    
    // WebView finale (POSIZIONE AGGIORNATA per layout più spazioso)
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(15, 15, [contentView frame].size.width - 30, [contentView frame].size.height - 85) configuration:config];
    [self.webView setWantsLayer:YES];
    [self.webView.layer setCornerRadius:12.0];
    [self.webView.layer setMasksToBounds:YES];
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate:self];
    
    // === AGGIUNGI TUTTO ALLA FINESTRA ===
    [contentView addSubview:navigationToolbar];
    [contentView addSubview:separatorLine];  // ✨ NUOVO: Linea separatrice elegante
    [contentView addSubview:tabBar];
    [contentView addSubview:self.webView];
    
    [self loadWelcomePage];
    
    std::cout << "🎨 Modern UI with elegant separator setup completed" << std::endl;
}

- (void)loadWelcomePage {
    // Pagina di benvenuto moderna e pulita
    NSString* welcomeHTML = @"<!DOCTYPE html>"
    "<html><head>"
    "<meta charset='UTF-8'>"
    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    "<title>MacBird Browser</title>"
    "<style>"
    "* { margin: 0; padding: 0; box-sizing: border-box; }"
    "body { "
    "  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;"
    "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);"
    "  color: white; height: 100vh; display: flex; align-items: center; justify-content: center;"
    "  text-align: center;"
    "}"
    ".container { max-width: 600px; }"
    ".logo { font-size: 4rem; font-weight: 300; margin-bottom: 1rem; }"
    ".tagline { font-size: 1.5rem; opacity: 0.9; margin-bottom: 2rem; font-weight: 300; }"
    ".search-container { margin: 2rem 0; }"
    ".search-box { "
    "  width: 100%; padding: 1rem; font-size: 1.1rem; border: none; border-radius: 50px;"
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
    "</style>"
    "</head><body>"
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
    "</body></html>";
    
    // ✨ NUOVO: Carica con URL locale personalizzato per gestire reload
    NSURL* welcomeURL = [NSURL URLWithString:@"macbird://welcome"];
    [self.webView loadHTMLString:welcomeHTML baseURL:welcomeURL];
    
    // Marca che siamo sulla welcome page
    self.isOnWelcomePage = YES;
    //[self.addressBar setStringValue:@""];
    
    std::cout << "🏠 Welcome page loaded with custom URL scheme" << std::endl;
}

- (void)addressBarEnterPressed:(id)sender {
    NSString* url = [self.addressBar stringValue];
    [self navigateToURL:url];
}

- (void)goButtonPressed:(id)sender {
    NSString* url = [self.addressBar stringValue];
    [self navigateToURL:url];
}

- (void)navigateToURL:(NSString*)url {
    std::cout << "🌐 Navigating to: " << [url UTF8String] << std::endl;
    
    // Gestione intelligente URL
    if ([url length] == 0) {
        [self loadWelcomePage];
        return;
    }
    
    // ✨ NUOVO: Marca che non siamo più sulla welcome page
    self.isOnWelcomePage = NO;
    
    // Aggiunge protocollo se mancante
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        if ([url hasPrefix:@"www."] || ([url containsString:@"."] && ![url containsString:@" "])) {
            url = [@"https://" stringByAppendingString:url];
        } else {
            url = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
    }
    
    // Naviga con User-Agent Safari MODERNO + logging
    NSURL* nsUrl = [NSURL URLWithString:url];
    if (nsUrl) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
        
        // User-Agent Safari 17.6 (ULTIMA versione 2024)
        NSString* modernUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15";
        [request setValue:modernUserAgent forHTTPHeaderField:@"User-Agent"];
        
        // Headers aggiuntivi per sembrare Safari moderno
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setValue:@"en-US,en;q=0.9" forHTTPHeaderField:@"Accept-Language"];
        [request setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"1" forHTTPHeaderField:@"DNT"];
        [request setValue:@"same-origin" forHTTPHeaderField:@"Sec-Fetch-Site"];
        [request setValue:@"navigate" forHTTPHeaderField:@"Sec-Fetch-Mode"];
        [request setValue:@"document" forHTTPHeaderField:@"Sec-Fetch-Dest"];
        
        // LOGGING DETTAGLIATO
        std::cout << "📡 Request Headers sent to server:" << std::endl;
        std::cout << "   User-Agent: " << [modernUserAgent UTF8String] << std::endl;
        std::cout << "   WebKit Version: 605.1.15 (Latest)" << std::endl;
        std::cout << "   Safari Version: 17.6 (Latest)" << std::endl;
        
        [self.webView loadRequest:request];
        //[self.addressBar setStringValue:url];
        std::cout << "✅ Loading with MODERN Safari-compatible engine..." << std::endl;
    } else {
        std::cout << "❌ Invalid URL format" << std::endl;
    }
}

// ======= DELEGATE METHODS PER GESTIRE RELOAD =======

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL* url = navigationAction.request.URL;
    
    // ✨ NUOVO: Gestisce reload della welcome page - MA SENZA LOOP!
    if ([url.scheme isEqualToString:@"macbird"] && [url.host isEqualToString:@"welcome"]) {
        // Se è un reload (non il primo caricamento), ricarica la welcome page
        if (navigationAction.navigationType == WKNavigationTypeReload) {
            std::cout << "🔄 Reloading welcome page..." << std::endl;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadWelcomePage];
            });
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else {
            // Se è il primo caricamento, permettilo
            std::cout << "🏠 Loading welcome page for first time..." << std::endl;
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    
    // ✨ CORRETTO: Gestisce URL vuoti SOLO se siamo già sulla welcome page
    if (self.isOnWelcomePage && 
        ([url.absoluteString isEqualToString:@"about:blank"] || 
        [url.absoluteString isEqualToString:@""] ||
        url == nil)) {
        std::cout << "🏠 Empty URL detected while on welcome page, staying..." << std::endl;
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // ✨ NUOVO: Se è un URL normale, marca che non siamo più sulla welcome page
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        self.isOnWelcomePage = NO;
        //[self.addressBar setStringValue:url.absoluteString];
    }
    
    std::cout << "🌐 Allowing navigation to: " << [url.absoluteString UTF8String] << std::endl;
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    std::cout << "🔄 Navigation started - checking what Google detects..." << std::endl;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    std::cout << "✅ Page loaded - analyzing Google's detection..." << std::endl;
    
    // ✨ NUOVO: Aggiorna l'address bar solo se non siamo sulla welcome page
    if (!self.isOnWelcomePage && webView.URL) {
        //[self.addressBar setStringValue:webView.URL.absoluteString];
    }
    
    // JavaScript per controllare cosa Google rileva del nostro browser
    NSString* detectionScript = @""
        "console.log('=== MACBIRD BROWSER DETECTION LOG ===');"
        "console.log('User Agent detected:', navigator.userAgent);"
        "console.log('Platform:', navigator.platform);"
        "console.log('Vendor:', navigator.vendor);"
        "console.log('App Version:', navigator.appVersion);"
        "console.log('WebKit Version:', navigator.userAgent.match(/WebKit\\/(\\S+)/)?.[1] || 'unknown');"
        "console.log('Safari Version:', navigator.userAgent.match(/Version\\/(\\S+)/)?.[1] || 'unknown');"
        ""
        "// Controlla feature moderne supportate"
        "const modernFeatures = {"
        "  'CSS Grid': CSS.supports('display', 'grid'),"
        "  'CSS Flexbox': CSS.supports('display', 'flex'),"
        "  'Backdrop Filter': CSS.supports('backdrop-filter', 'blur(10px)'),"
        "  'Border Radius': CSS.supports('border-radius', '10px'),"
        "  'IntersectionObserver': typeof IntersectionObserver !== 'undefined',"
        "  'ResizeObserver': typeof ResizeObserver !== 'undefined',"
        "  'Fetch API': typeof fetch !== 'undefined',"
        "  'WebGL': !!document.createElement('canvas').getContext('webgl'),"
        "  'WebGL2': !!document.createElement('canvas').getContext('webgl2'),"
        "  'ServiceWorker': 'serviceWorker' in navigator,"
        "  'Push API': 'PushManager' in window,"
        "  'Notifications': 'Notification' in window"
        "};"
        ""
        "console.log('=== MODERN FEATURES SUPPORT ===');"
        "Object.entries(modernFeatures).forEach(([feature, supported]) => {"
        "  console.log(`${feature}: ${supported ? '✅ SUPPORTED' : '❌ NOT SUPPORTED'}`);"
        "});"
        ""
        "// Controlla cosa Google pensa di noi"
        "if (window.location.hostname.includes('google')) {"
        "  console.log('=== GOOGLE DETECTION ANALYSIS ===');"
        "  const searchBox = document.querySelector('input[name=q], .gLFyf');"
        "  if (searchBox) {"
        "    const styles = window.getComputedStyle(searchBox);"
        "    console.log('Google search box border-radius:', styles.borderRadius);"
        "    console.log('Google detected modern layout:', styles.borderRadius !== '0px' ? '✅ YES' : '❌ NO');"
        "  }"
        "  "
        "  const body = document.body;"
        "  if (body) {"
        "    const bodyStyles = window.getComputedStyle(body);"
        "    console.log('Google page background:', bodyStyles.backgroundColor);"
        "    console.log('Google using dark theme:', bodyStyles.backgroundColor.includes('32, 33, 36') ? '✅ YES' : '❌ NO');"
        "  }"
        "}"
        ""
        "'MacBird Detection Complete - Check Console'";
    
    [webView evaluateJavaScript:detectionScript completionHandler:^(id result, NSError *error) {
        if (error) {
            std::cout << "❌ JavaScript detection error: " << [[error localizedDescription] UTF8String] << std::endl;
        } else {
            std::cout << "🔍 Browser detection completed - check DevTools Console for details" << std::endl;
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    std::cout << "❌ Navigation failed: " << [[error localizedDescription] UTF8String] << std::endl;
    
    // ✨ NUOVO: Se la navigazione fallisce e siamo su welcome page, ricarica welcome
    if (self.isOnWelcomePage || !webView.URL || [webView.URL.absoluteString isEqualToString:@"about:blank"]) {
        std::cout << "🏠 Loading welcome page after navigation failure..." << std::endl;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadWelcomePage];
        });
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    std::cout << "❌ Provisional navigation failed: " << [[error localizedDescription] UTF8String] << std::endl;
    
    // ✨ NUOVO: Se la navigazione provisoria fallisce, torna alla welcome page
    std::cout << "🏠 Loading welcome page after provisional navigation failure..." << std::endl;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadWelcomePage];
    });
}

// ✨ NUOVO: DevTools integrati con architettura modulare
- (void)toggleDevTools:(id)sender {
    [self.devToolsManager toggleDevTools];
    std::cout << "🛠️ MacBird DevTools toggled (modular)" << std::endl;
}


// === AZIONI PER I PULSANTI DI NAVIGAZIONE ===
- (void)goBack:(id)sender {
    [self.webView goBack];
    std::cout << "← Back button pressed" << std::endl;
}

- (void)goForward:(id)sender {
    [self.webView goForward];
    std::cout << "→ Forward button pressed" << std::endl;
}

- (void)reload:(id)sender {
    [self.webView reload];
    std::cout << "↻ Reload button pressed" << std::endl;
}

- (void)goHome:(id)sender {
    [self loadWelcomePage];
    std::cout << "🏠 Home button pressed" << std::endl;
}

- (void)newTab:(id)sender {
    // Per ora, ricarica la welcome page
    [self loadWelcomePage];
    std::cout << "+ New tab button pressed" << std::endl;
}

@end
