#ifndef DEVTOOLSMANAGER_H
#define DEVTOOLSMANAGER_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;
@class ConsoleTab;
@class ElementsTab;
@class NetworkTab;

@interface DevToolsManager : NSObject

@property (assign, nonatomic) BrowserWindow* browserWindow;
@property (strong, nonatomic) NSWindow* devToolsWindow;
@property (strong, nonatomic) NSTabView* tabView;

// Tab Components
@property (strong, nonatomic) ConsoleTab* consoleTab;
@property (strong, nonatomic) ElementsTab* elementsTab;
@property (strong, nonatomic) NetworkTab* networkTab;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window;
- (void)toggleDevTools;
- (void)openDevTools;
- (void)closeDevTools;
- (void)setupDevToolsUI;

// Public methods for external access
- (void)logToConsole:(NSString*)message;
- (void)logToConsole:(NSString*)message withColor:(NSColor*)color;
- (void)runDetectionAnalysis;

@end

#endif