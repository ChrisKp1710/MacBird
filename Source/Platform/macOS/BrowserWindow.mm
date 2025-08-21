#import "BrowserWindow.h"
#import <WebKit/WebKit.h>
#include <iostream>

@implementation BrowserWindow

- (instancetype)init {
    // Crea finestra 1200x800 centrata
    NSRect windowRect = NSMakeRect(0, 0, 1200, 800);
    
    self = [super initWithContentRect:windowRect
                            styleMask:(NSWindowStyleMaskTitled | 
                                     NSWindowStyleMaskClosable | 
                                     NSWindowStyleMaskMiniaturizable | 
                                     NSWindowStyleMaskResizable)
                              backing:NSBackingStoreBuffered
                                defer:NO];
    
    if (self) {
        [self setTitle:@"MacBird Browser"];
        [self center];  // Centra la finestra
        [self setupUI];
        
        std::cout << "🪟 BrowserWindow created with WebKit engine" << std::endl;
    }
    
    return self;
}

- (void)setupUI {
    NSView* contentView = [self contentView];
    
    // Crea barra degli indirizzi (40 pixel di altezza, con margini)
    self.addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(10, [contentView frame].size.height - 50, [contentView frame].size.width - 90, 30)];
    [self.addressBar setStringValue:@"https://"];
    [self.addressBar setTarget:self];
    [self.addressBar setAction:@selector(addressBarEnterPressed:)];
    
    // Crea pulsante "Vai" (più piccolo e allineato)
    self.goButton = [[NSButton alloc] initWithFrame:NSMakeRect([contentView frame].size.width - 70, [contentView frame].size.height - 50, 60, 30)];
    [self.goButton setTitle:@"Vai"];
    [self.goButton setTarget:self];
    [self.goButton setAction:@selector(goButtonPressed:)];
    
    // Crea WKWebView che riempie TUTTA l'area sotto la barra indirizzi
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    
    // USA L'API MODERNA - elimina il warning deprecato
    // JavaScript è abilitato per default, non serve impostarlo
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // WebView che si adatta automaticamente alla finestra
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, [contentView frame].size.width, [contentView frame].size.height - 60) configuration:config];
    
    // Abilita autoresizing per adattarsi quando la finestra cambia dimensione
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.addressBar setAutoresizingMask:NSViewWidthSizable];
    [self.goButton setAutoresizingMask:NSViewMinXMargin];
    
    // Aggiungi tutto alla finestra
    [contentView addSubview:self.webView];      // WebView per primo (dietro)
    [contentView addSubview:self.addressBar];   // Barra indirizzi sopra
    [contentView addSubview:self.goButton];     // Pulsante sopra tutto
    
    std::cout << "🎨 UI setup completed with responsive WebKit engine" << std::endl;
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
    
    // Assicurati che l'URL abbia il protocollo
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        if ([url hasPrefix:@"www."] || [url containsString:@"."]) {
            url = [@"https://" stringByAppendingString:url];
        } else {
            url = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", url];
        }
    }
    
    // Naviga usando WebKit con User-Agent di Safari per rendering ottimale
    NSURL* nsUrl = [NSURL URLWithString:url];
    if (nsUrl) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
        
        // Imposta User-Agent identico a Safari per migliore compatibilità
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15" 
       forHTTPHeaderField:@"User-Agent"];
        
        [self.webView loadRequest:request];
        std::cout << "✅ Loading with Safari-compatible WebKit engine..." << std::endl;
    } else {
        std::cout << "❌ Invalid URL format" << std::endl;
    }
}

@end
