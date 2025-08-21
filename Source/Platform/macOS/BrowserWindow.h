#ifndef BROWSERWINDOW_H
#define BROWSERWINDOW_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class MenuManager;

@interface BrowserWindow : NSWindow <WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) NSTextField* addressBar;
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSButton* goButton;
@property (strong, nonatomic) MenuManager* menuManager;

- (void)setupModernUI;
- (void)navigateToURL:(NSString*)url;
- (void)loadWelcomePage;

// Metodo rimasto per compatibilità con MenuManager
- (void)toggleDevTools:(id)sender;

@end

#endif
