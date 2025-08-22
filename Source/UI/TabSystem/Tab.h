#ifndef TAB_H
#define TAB_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface Tab : NSObject
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSButton* tabButton;
@property (strong, nonatomic) NSButton* closeButton;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSURL* url;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isOnWelcomePage;
@property (nonatomic, assign) NSInteger tabId;
@end

#endif