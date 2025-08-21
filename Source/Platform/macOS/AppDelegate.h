#ifndef APPDELEGATE_H
#define APPDELEGATE_H

#import <Cocoa/Cocoa.h>

@class BrowserWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) BrowserWindow* mainWindow;

@end

#endif
