#ifndef NETWORKTAB_H
#define NETWORKTAB_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface NetworkTab : NSObject

@property (strong, nonatomic) NSView* containerView;
@property (strong, nonatomic) NSTextView* networkOutput;
@property (assign, nonatomic) BrowserWindow* browserWindow;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame;
- (NSView*)createNetworkTabView;
- (void)showNetworkInfo;

@end

#endif