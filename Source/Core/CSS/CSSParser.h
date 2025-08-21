#ifndef CSSPARSER_H
#define CSSPARSER_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface CSSParser : NSObject

// Estrae regole CSS da HTML e le converte in stili applicabili
+ (NSDictionary*)parseCSS:(NSString*)htmlContent;

// Applica stili CSS a un elemento HTML
+ (NSDictionary*)getStylesForElement:(NSString*)tagName withCSS:(NSDictionary*)cssRules;

@end

#endif
