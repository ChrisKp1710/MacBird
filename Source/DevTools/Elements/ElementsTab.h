#ifndef ELEMENTSTAB_H
#define ELEMENTSTAB_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface ElementsTab : NSObject

@property (strong, nonatomic) NSView* containerView;
@property (strong, nonatomic) NSTextView* htmlSource;
@property (assign, nonatomic) BrowserWindow* browserWindow;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame;
- (NSView*)createElementsTabView;
- (void)refreshHTMLSource;
- (void)applySyntaxHighlighting;
- (NSString*)formatHTMLString:(NSString*)html;

@end

#endif