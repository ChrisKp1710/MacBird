#ifndef BROWSERWINDOW_H
#define BROWSERWINDOW_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class MenuManager;
@class DevToolsManager;
@class TabManager;

@interface BrowserWindow : NSWindow <WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) NSTextField* addressBar;
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSButton* goButton;
@property (strong, nonatomic) MenuManager* menuManager;
@property (strong, nonatomic) DevToolsManager* devToolsManager;

// ✨ NUOVO: TabManager per gestire tab multiple
@property (strong, nonatomic) TabManager* tabManager;

// ✨ NUOVO: Proprietà per gestire welcome page reload
@property (nonatomic, assign) BOOL isOnWelcomePage;

- (void)setupModernUI;
- (void)navigateToURL:(NSString*)url;
- (void)loadWelcomePage;

// Metodo rimasto per compatibilità con MenuManager
- (void)toggleDevTools:(id)sender;

@end

#endif