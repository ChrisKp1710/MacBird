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
    
    // Crea barra degli indirizzi (30 pixel di altezza, in alto)
    self.addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 760, 1000, 25)];
    [self.addressBar setStringValue:@"https://"];
    [self.addressBar setTarget:self];
    [self.addressBar setAction:@selector(addressBarEnterPressed:)];
    
    // Crea pulsante "Vai"
    self.goButton = [[NSButton alloc] initWithFrame:NSMakeRect(1020, 760, 60, 25)];
    [self.goButton setTitle:@"Vai"];
    [self.goButton setTarget:self];
    [self.goButton setAction:@selector(goButtonPressed:)];
    
    // Crea area di contenuto scorrevole (tutto il resto della finestra)
    self.contentScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, 1180, 740)];
    [self.contentScrollView setHasVerticalScroller:YES];
    [self.contentScrollView setHasHorizontalScroller:YES];
    [self.contentScrollView setAutohidesScrollers:NO];
    [self.contentScrollView setBorderType:NSBezelBorder];
    
    // Crea area di testo per il contenuto HTML
    NSRect textRect = NSMakeRect(0, 0, 1160, 720);
    self.contentTextView = [[NSTextView alloc] initWithFrame:textRect];
    [self.contentTextView setEditable:NO];  // Solo lettura
    [self.contentTextView setSelectable:YES];  // Permetti selezione testo
    [self.contentTextView setFont:[NSFont fontWithName:@"Monaco" size:11]];  // Font monospaced
    [self.contentTextView setString:@"MacBird Browser - Pronto per navigare!\n\nInserisci un URL nella barra sopra e premi 'Vai' per iniziare."];
    
    // Collega textView a scrollView
    [self.contentScrollView setDocumentView:self.contentTextView];
    
    // Aggiungi tutto alla finestra
    [contentView addSubview:self.addressBar];
    [contentView addSubview:self.goButton];
    [contentView addSubview:self.contentScrollView];
    
    std::cout << "🎨 UI setup completed with content area" << std::endl;
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
    
    // Mostra messaggio di caricamento (CORRETTO)
    NSString* loadingMessage = [NSString stringWithFormat:@"🔄 Caricamento in corso...\n\nScaricando contenuto da:\n%@", url];
    [self displayContent:loadingMessage];
    
    // Usa HTTPClient per scaricare la pagina
    HTTPClient* httpClient = [[HTTPClient alloc] init];
    [httpClient fetchURL:url completion:^(NSString* content, NSError* error) {
        
        if (error) {
            const char* errorMsg = error.localizedDescription ? [error.localizedDescription UTF8String] : "Unknown error";
            std::cout << "❌ Navigation failed: " << errorMsg << std::endl;
            
            // Mostra errore nell'UI
            NSString* errorContent = [NSString stringWithFormat:@"❌ Errore durante il caricamento\n\nURL: %@\nErrore: %@\n\nProva con un altro URL.", 
                                    url, error.localizedDescription ?: @"Errore sconosciuto"];
            [self displayContent:errorContent];
            
        } else {
            std::cout << "✅ Page loaded successfully!" << std::endl;
            std::cout << "📄 Content length: " << [content length] << " characters" << std::endl;
            
            // Mostra contenuto HTML nell'UI
            NSString* displayText = [NSString stringWithFormat:@"✅ Pagina caricata con successo!\n\nURL: %@\nDimensione: %lu caratteri\n\n--- CONTENUTO HTML ---\n\n%@", 
                                   url, (unsigned long)[content length], content ?: @"(contenuto vuoto)"];
            [self displayContent:displayText];
        }
    }];
}

- (void)displayContent:(NSString*)content {
    // Aggiorna l'UI nel main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTextView setString:content];
        
        // Scrolla in cima
        [self.contentTextView scrollRangeToVisible:NSMakeRange(0, 0)];
        
        std::cout << "🖥️ Content displayed in UI" << std::endl;
    });
}

@end
