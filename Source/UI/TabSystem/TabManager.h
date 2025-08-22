#ifndef TABMANAGER_H
#define TABMANAGER_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Tab.h"

@class BrowserWindow;

@interface TabManager : NSObject

@property (strong, nonatomic) NSMutableArray<Tab*>* tabs;
@property (strong, nonatomic) Tab* activeTab;
@property (assign, nonatomic) BrowserWindow* browserWindow;
@property (strong, nonatomic) NSView* tabBarContainer;
@property (strong, nonatomic) NSView* webViewContainer;
@property (nonatomic, assign) NSInteger nextTabId;
@property (strong, nonatomic) WKProcessPool* sharedProcessPool;
@property (strong, nonatomic) WKWebsiteDataStore* sharedDataStore;

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