#import "BrowserWindow.h"
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
                                     NSWindowStyleMaskFullSizeContentView)  // Moderno!
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
        
        std::cout << "🪟 Modern MacBird Browser window created" << std::endl;
    }
    
    return self;
}

- (void)setupModernUI {
    NSView* contentView = [self contentView];
    
    // === BARRA SUPERIORE MODERNA ===
    NSView* topBar = [[NSView alloc] initWithFrame:NSMakeRect(0, [contentView frame].size.height - 70, [contentView frame].size.width, 70)];
    [topBar setWantsLayer:YES];
    [topBar.layer setBackgroundColor:[NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor];
    [topBar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    
    // === LOGO/TITOLO MODERNO ===
    NSTextField* logoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 25, 120, 25)];
    [logoLabel setStringValue:@"MacBird"];
    [logoLabel setBezeled:NO];
    [logoLabel setDrawsBackground:NO];
    [logoLabel setEditable:NO];
    [logoLabel setSelectable:NO];
    [logoLabel setTextColor:[NSColor whiteColor]];
    [logoLabel setFont:[NSFont systemFontOfSize:18 weight:NSFontWeightSemibold]];
    
    // === BARRA INDIRIZZI MODERNA ===
    CGFloat addressBarWidth = [contentView frame].size.width - 300;  // Spazio per logo e pulsante
    self.addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(150, 20, addressBarWidth, 35)];
    [self.addressBar setStringValue:@""];
    [self.addressBar setPlaceholderString:@"Cerca con Google o inserisci un indirizzo"];
    [self.addressBar setTarget:self];
    [self.addressBar setAction:@selector(addressBarEnterPressed:)];
    [self.addressBar setAutoresizingMask:NSViewWidthSizable];
    
    // Stile moderno barra indirizzi
    [self.addressBar setWantsLayer:YES];
    [self.addressBar.layer setCornerRadius:8.0];
    [self.addressBar.layer setBackgroundColor:[NSColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1.0].CGColor];
    [self.addressBar.layer setBorderWidth:1.0];
    [self.addressBar.layer setBorderColor:[NSColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0].CGColor];
    [self.addressBar setTextColor:[NSColor whiteColor]];
    [self.addressBar setFont:[NSFont systemFontOfSize:14]];
    
    // === PULSANTE VAI MODERNO ===
    self.goButton = [[NSButton alloc] initWithFrame:NSMakeRect([contentView frame].size.width - 120, 20, 80, 35)];
    [self.goButton setTitle:@"Vai"];
    [self.goButton setTarget:self];
    [self.goButton setAction:@selector(goButtonPressed:)];
    [self.goButton setAutoresizingMask:NSViewMinXMargin];
    
    // Stile moderno pulsante
    [self.goButton setWantsLayer:YES];
    [self.goButton.layer setCornerRadius:8.0];
    [self.goButton.layer setBackgroundColor:[NSColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0].CGColor];  // Blu Apple
    [self.goButton setBordered:NO];
    [self.goButton setFont:[NSFont systemFontOfSize:14 weight:NSFontWeightMedium]];
    
    // === WEBVIEW MODERNO ===
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // WebView con bordi arrotondati
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(15, 15, [contentView frame].size.width - 30, [contentView frame].size.height - 100) configuration:config];
    [self.webView setWantsLayer:YES];
    [self.webView.layer setCornerRadius:12.0];
    [self.webView.layer setMasksToBounds:YES];
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // === AGGIUNGI TUTTO ALLA FINESTRA ===
    [topBar addSubview:logoLabel];
    [topBar addSubview:self.addressBar];
    [topBar addSubview:self.goButton];
    
    [contentView addSubview:self.webView];
    [contentView addSubview:topBar];
    
    // === PAGINA INIZIALE ELEGANTE ===
    [self loadWelcomePage];
    
    std::cout << "🎨 Modern UI setup completed with elegant design" << std::endl;
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
    
    [self.webView loadHTMLString:welcomeHTML baseURL:nil];
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
    
    // Aggiunge protocollo se mancante
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        if ([url hasPrefix:@"www."] || ([url containsString:@"."] && ![url containsString:@" "])) {
            url = [@"https://" stringByAppendingString:url];
        } else {
            url = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
    }
    
    // Naviga con User-Agent Safari
    NSURL* nsUrl = [NSURL URLWithString:url];
    if (nsUrl) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15" 
       forHTTPHeaderField:@"User-Agent"];
        
        [self.webView loadRequest:request];
        [self.addressBar setStringValue:url];
        std::cout << "✅ Loading with modern Safari-compatible engine..." << std::endl;
    } else {
        std::cout << "❌ Invalid URL format" << std::endl;
    }
}

@end
