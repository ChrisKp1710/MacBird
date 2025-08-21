#import "BrowserWindow.h"
#import "Core/Network/HTTPClient.h"
#import "Core/HTML/HTMLParser.h"
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
    
    // Crea area di testo per il contenuto HTML - SFONDO BIANCO COME BROWSER VERO
    NSRect textRect = NSMakeRect(0, 0, 1160, 720);
    self.contentTextView = [[NSTextView alloc] initWithFrame:textRect];
    [self.contentTextView setEditable:NO];  // Solo lettura
    [self.contentTextView setSelectable:YES];  // Permetti selezione testo
    [self.contentTextView setFont:[NSFont systemFontOfSize:16]];  // Font di default
    
    // IMPOSTA SFONDO BIANCO COME BROWSER VERO
    [self.contentTextView setBackgroundColor:[NSColor whiteColor]];
    [self.contentTextView setTextColor:[NSColor blackColor]];
    
    [self.contentTextView setString:@"MacBird Browser\n\nInserisci un URL nella barra sopra per iniziare la navigazione.\n\nIl browser renderizzerà HTML e CSS come Safari!"];
    
    // Collega textView a scrollView
    [self.contentScrollView setDocumentView:self.contentTextView];
    
    // Aggiungi tutto alla finestra
    [contentView addSubview:self.addressBar];
    [contentView addSubview:self.goButton];
    [contentView addSubview:self.contentScrollView];
    
    std::cout << "🎨 UI setup completed with browser-like rendering" << std::endl;
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
    
    // Mostra messaggio di caricamento
    NSString* loadingMessage = [NSString stringWithFormat:@"Caricamento in corso...\n\nURL: %@", url];
    [self displayContent:loadingMessage];
    
    // Usa HTTPClient per scaricare la pagina
    HTTPClient* httpClient = [[HTTPClient alloc] init];
    [httpClient fetchURL:url completion:^(NSString* content, NSError* error) {
        
        if (error) {
            const char* errorMsg = error.localizedDescription ? [error.localizedDescription UTF8String] : "Unknown error";
            std::cout << "❌ Navigation failed: " << errorMsg << std::endl;
            
            // Mostra errore nell'UI
            NSString* errorContent = [NSString stringWithFormat:@"Impossibile caricare la pagina\n\nURL: %@\nErrore: %@\n\nProva con un altro URL.", 
                                    url, error.localizedDescription ?: @"Errore sconosciuto"];
            [self displayContent:errorContent];
            
        } else {
            std::cout << "✅ Page loaded successfully!" << std::endl;
            std::cout << "📄 Content length: " << [content length] << " characters" << std::endl;
            
            // USA IL RENDERING BROWSER-LIKE (senza header di debug)
            [self displayBrowserLikeContent:content fromURL:url];
        }
    }];
}

- (void)displayContent:(NSString*)content {
    // Mostra contenuto come testo semplice
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTextView setString:content];
        [self.contentTextView scrollRangeToVisible:NSMakeRange(0, 0)];
        std::cout << "🖥️ Content displayed in UI" << std::endl;
    });
}

- (void)displayBrowserLikeContent:(NSString*)htmlContent fromURL:(NSString*)url {
    // RENDERING BROWSER-LIKE SENZA DEBUG INFO!
    dispatch_async(dispatch_get_main_queue(), ^{
        std::cout << "🎨 Starting browser-like rendering..." << std::endl;
        
        // Parsa l'HTML con CSS applicato
        NSAttributedString* renderedContent = [HTMLParser parseHTML:htmlContent];
        
        // Mostra SOLO il contenuto renderizzato (come Safari)
        [[self.contentTextView textStorage] setAttributedString:renderedContent];
        [self.contentTextView scrollRangeToVisible:NSMakeRange(0, 0)];
        
        std::cout << "🎨 Browser-like content rendered!" << std::endl;
    });
}

@end
