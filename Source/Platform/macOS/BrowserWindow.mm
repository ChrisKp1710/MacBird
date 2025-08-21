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
    
    // Crea barra degli indirizzi (50 pixel di altezza, in alto)
    self.addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 750, 1000, 30)];
    [self.addressBar setStringValue:@"https://"];
    [self.addressBar setTarget:self];
    [self.addressBar setAction:@selector(addressBarEnterPressed:)];
    
    // Crea pulsante "Vai"
    self.goButton = [[NSButton alloc] initWithFrame:NSMakeRect(1020, 750, 60, 30)];
    [self.goButton setTitle:@"Vai"];
    [self.goButton setTarget:self];
    [self.goButton setAction:@selector(goButtonPressed:)];
    
    // Crea WKWebView (motore Safari!) - tutto il resto della finestra
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(10, 10, 1180, 730) configuration:config];
    
    // Aggiungi tutto alla finestra
    [contentView addSubview:self.addressBar];
    [contentView addSubview:self.goButton];
    [contentView addSubview:self.webView];
    
    std::cout << "🎨 UI setup completed with WebKit rendering engine" << std::endl;
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
    
    // Naviga usando WebKit (rendering identico a Safari!)
    NSURL* nsUrl = [NSURL URLWithString:url];
    if (nsUrl) {
        NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl];
        [self.webView loadRequest:request];
        std::cout << "✅ Loading with WebKit engine..." << std::endl;
    } else {
        std::cout << "❌ Invalid URL format" << std::endl;
    }
}

@end
