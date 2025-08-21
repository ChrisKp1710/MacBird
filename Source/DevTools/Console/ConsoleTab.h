#ifndef CONSOLETAB_H
#define CONSOLETAB_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface ConsoleTab : NSObject

@property (strong, nonatomic) NSView* containerView;
@property (strong, nonatomic) NSTextView* consoleOutput;
@property (assign, nonatomic) BrowserWindow* browserWindow;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame;
- (NSView*)createConsoleTabView;
- (void)runDetectionAnalysis;
- (void)clearConsole;
- (void)logToConsole:(NSString*)message;
- (void)logToConsole:(NSString*)message withColor:(NSColor*)color;

@end

#endif