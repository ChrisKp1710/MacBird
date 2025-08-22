#ifndef TABMANAGER_H
#define TABMANAGER_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

// Struttura dati per una singola tab
@interface Tab : NSObject
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSButton* tabButton;
@property (strong, nonatomic) NSButton* closeButton;  // ✨ NUOVO: Pulsante X per chiudere
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSURL* url;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isOnWelcomePage;
@property (nonatomic, assign) NSInteger tabId;  // ✨ NUOVO: ID univoco per la tab
@end

@interface TabManager : NSObject

@property (strong, nonatomic) NSMutableArray<Tab*>* tabs;
@property (strong, nonatomic) Tab* activeTab;
@property (assign, nonatomic) BrowserWindow* browserWindow;
@property (strong, nonatomic) NSView* tabBarContainer;
@property (strong, nonatomic) NSView* webViewContainer;
@property (nonatomic, assign) NSInteger nextTabId;  // ✨ NUOVO: Contatore per ID tab

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window 
                       tabBarContainer:(NSView*)tabBar 
                     webViewContainer:(NSView*)webViewContainer;

// ✨ GESTIONE TAB MULTIPLE
- (void)createNewTab;
- (void)switchToTab:(Tab*)tab;
- (void)closeTab:(Tab*)tab;
- (void)updateTabLayout;

// ✨ METODI PER LA WEBVIEW ATTIVA
- (WKWebView*)activeWebView;
- (void)navigateToURL:(NSString*)url;
- (void)loadWelcomePage;
- (void)goBack;
- (void)goForward;
- (void)reload;

@end

#endif