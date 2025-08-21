#ifndef BROWSERWINDOW_H
#define BROWSERWINDOW_H

#import <Cocoa/Cocoa.h>

@interface BrowserWindow : NSWindow

@property (strong, nonatomic) NSTextField* addressBar;      // Barra URL
@property (strong, nonatomic) NSView* webContentView;       // Area contenuto
@property (strong, nonatomic) NSButton* goButton;          // Pulsante "Vai"
@property (strong, nonatomic) NSScrollView* contentScrollView;  // Area scorrevole
@property (strong, nonatomic) NSTextView* contentTextView;     // Area testo HTML

- (void)setupUI;                // Crea l'interfaccia
- (void)navigateToURL:(NSString*)url;  // Naviga a un URL
- (void)displayContent:(NSString*)content;  // Mostra contenuto nell'UI

@end

#endif
