#import "BrowserWindow.h"
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
        
        std::cout << "🪟 BrowserWindow created" << std::endl;
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
    
    // Crea area contenuto (tutto il resto della finestra)
    self.webContentView = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, 1180, 730)];
    [self.webContentView setWantsLayer:YES];
    [self.webContentView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    // Aggiungi tutto alla finestra
    [contentView addSubview:self.addressBar];
    [contentView addSubview:self.goButton];
    [contentView addSubview:self.webContentView];
    
    std::cout << "🎨 UI setup completed" << std::endl;
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
    
    // Per ora mostra solo un messaggio (futuro: caricherà HTML)
    // TODO: Qui andrà il parser HTML e il rendering
}

@end
