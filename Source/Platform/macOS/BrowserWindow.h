#ifndef BROWSERWINDOW_H
#define BROWSERWINDOW_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>  // Aggiungo WebKit per WKWebView

@interface BrowserWindow : NSWindow

@property (strong, nonatomic) NSTextField* addressBar;      // Barra URL
@property (strong, nonatomic) WKWebView* webView;          // WebView vero (come Safari!)
@property (strong, nonatomic) NSButton* goButton;          // Pulsante "Vai"

- (void)setupUI;                // Crea l'interfaccia
- (void)navigateToURL:(NSString*)url;  // Naviga a un URL

@end

#endif
