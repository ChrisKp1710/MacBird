#ifndef HTMLPARSER_H
#define HTMLPARSER_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface HTMLParser : NSObject

// Converte HTML raw in testo formattato
+ (NSAttributedString*)parseHTML:(NSString*)htmlContent;

// Helper per estrarre testo dai tag
+ (NSString*)extractTextContent:(NSString*)htmlContent;

@end

#endif
