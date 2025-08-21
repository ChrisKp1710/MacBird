#ifndef DEVTOOLSMANAGER_H
#define DEVTOOLSMANAGER_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface DevToolsManager : NSObject

@property (assign, nonatomic) BrowserWindow* browserWindow;
@property (strong, nonatomic) NSWindow* devToolsWindow;
@property (strong, nonatomic) NSTextView* consoleOutput;
@property (strong, nonatomic) NSTextView* htmlSource;
@property (strong, nonatomic) NSTabView* tabView;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window;
- (void)toggleDevTools;
- (void)closeDevTools;
- (void)runDetectionAnalysis;
- (void)showHTMLSource;
- (void)showNetworkActivity;
- (void)logToConsole:(NSString*)message;

@end

#endif