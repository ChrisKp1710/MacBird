#import "BrowserWindow.h"
#import "Core/Network/HTTPClient.h"
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
    
    // Usa HTTPClient per scaricare la pagina
    HTTPClient* httpClient = [[HTTPClient alloc] init];
    [httpClient fetchURL:url completion:^(NSString* content, NSError* error) {
        
        if (error) {
            const char* errorMsg = error.localizedDescription ? [error.localizedDescription UTF8String] : "Unknown error";
            std::cout << "❌ Navigation failed: " << errorMsg << std::endl;
        } else {
            std::cout << "✅ Page loaded successfully!" << std::endl;
            
            // DEBUG: Stampa dettagli sul contenuto ricevuto
            if (content == nil) {
                std::cout << "🐛 DEBUG: content is NIL!" << std::endl;
            } else {
                std::cout << "🐛 DEBUG: content exists, length = " << [content length] << std::endl;
                
                if ([content length] > 0) {
                    NSUInteger previewLength = MIN(100, [content length]);  // Riduciamo a 100 caratteri
                    NSString* preview = [content substringToIndex:previewLength];
                    std::cout << "📄 Content preview (first " << previewLength << " chars): " << std::endl;
                    std::cout << [preview UTF8String] << std::endl;
                    std::cout << "..." << std::endl;
                } else {
                    std::cout << "⚠️ Content has zero length" << std::endl;
                }
            }
        }
    }];
}

@end
