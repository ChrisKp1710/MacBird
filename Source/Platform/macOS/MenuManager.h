#ifndef MENUMANAGER_H
#define MENUMANAGER_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface MenuManager : NSObject

@property (assign, nonatomic) BrowserWindow* browserWindow;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window;
- (void)setupMenuBar;

// Menu actions
- (void)showAbout:(id)sender;
- (void)reloadPage:(id)sender;
- (void)forceReloadPage:(id)sender;
- (void)resetZoom:(id)sender;
- (void)zoomIn:(id)sender;
- (void)zoomOut:(id)sender;
- (void)viewSource:(id)sender;
- (void)showConsole:(id)sender;
- (void)showNetwork:(id)sender;
- (void)showDetectionReport:(id)sender;

@end

#endif