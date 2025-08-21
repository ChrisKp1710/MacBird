#import "CSSParser.h"
#include <iostream>

@implementation CSSParser

+ (NSDictionary*)parseCSS:(NSString*)htmlContent {
    std::cout << "🎨 CSS: Starting CSS parsing..." << std::endl;
    
    NSMutableDictionary* cssRules = [[NSMutableDictionary alloc] init];
    
    // Estrai CSS inline da tag <style>
    NSRegularExpression* styleRegex = [NSRegularExpression regularExpressionWithPattern:@"<style[^>]*>(.*?)</style>" 
                                                                                options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                  error:nil];
    
    NSArray* matches = [styleRegex matchesInString:htmlContent options:0 range:NSMakeRange(0, [htmlContent length])];
    
    for (NSTextCheckingResult* match in matches) {
        if ([match numberOfRanges] > 1) {
            NSString* cssContent = [htmlContent substringWithRange:[match rangeAtIndex:1]];
            NSDictionary* rules = [self parseCSSRules:cssContent];
            [cssRules addEntriesFromDictionary:rules];
        }
    }
    
    // Aggiungi stili di default del browser
    [cssRules addEntriesFromDictionary:[self getDefaultBrowserStyles]];
    
    std::cout << "✅ CSS: Parsed " << [cssRules count] << " CSS rules" << std::endl;
    
    return cssRules;
}

+ (NSDictionary*)parseCSSRules:(NSString*)cssContent {
    NSMutableDictionary* rules = [[NSMutableDictionary alloc] init];
    
    // Pattern per regole CSS: selettore { proprietà: valore; }
    NSRegularExpression* ruleRegex = [NSRegularExpression regularExpressionWithPattern:@"([^{]+)\\{([^}]+)\\}" 
                                                                               options:NSRegularExpressionCaseInsensitive 
                                                                                 error:nil];
    
    NSArray* matches = [ruleRegex matchesInString:cssContent options:0 range:NSMakeRange(0, [cssContent length])];
    
    for (NSTextCheckingResult* match in matches) {
        if ([match numberOfRanges] > 2) {
            NSString* selector = [[cssContent substringWithRange:[match rangeAtIndex:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* declarations = [cssContent substringWithRange:[match rangeAtIndex:2]];
            
            NSDictionary* properties = [self parseDeclarations:declarations];
            
            if ([properties count] > 0) {
                rules[selector] = properties;
            }
        }
    }
    
    return rules;
}

+ (NSDictionary*)parseDeclarations:(NSString*)declarations {
    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
    
    // Dividi per punto e virgola
    NSArray* declarationList = [declarations componentsSeparatedByString:@";"];
    
    for (NSString* declaration in declarationList) {
        NSArray* parts = [declaration componentsSeparatedByString:@":"];
        if ([parts count] >= 2) {
            NSString* property = [[parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            NSString* value = [[parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            
            if ([property length] > 0 && [value length] > 0) {
                properties[property] = value;
            }
        }
    }
    
    return properties;
}

+ (NSDictionary*)getDefaultBrowserStyles {
    // Stili di default che un browser applica automaticamente
    return @{
        @"body": @{
            @"background-color": @"white",
            @"color": @"black",
            @"font-family": @"serif",
            @"font-size": @"16px",
            @"margin": @"8px",
            @"padding": @"0px"
        },
        @"h1": @{
            @"font-size": @"32px",
            @"font-weight": @"bold",
            @"margin": @"20px 0",
            @"color": @"black"
        },
        @"h2": @{
            @"font-size": @"24px",
            @"font-weight": @"bold",
            @"margin": @"16px 0",
            @"color": @"black"
        },
        @"h3": @{
            @"font-size": @"20px",
            @"font-weight": @"bold",
            @"margin": @"12px 0",
            @"color": @"black"
        },
        @"p": @{
            @"font-size": @"16px",
            @"margin": @"16px 0",
            @"color": @"black"
        },
        @"a": @{
            @"color": @"blue",
            @"text-decoration": @"underline"
        }
    };
}

+ (NSDictionary*)getStylesForElement:(NSString*)tagName withCSS:(NSDictionary*)cssRules {
    NSMutableDictionary* styles = [[NSMutableDictionary alloc] init];
    
    // Inizia con stili di default per questo tag
    NSDictionary* defaults = [self getDefaultBrowserStyles];
    if (defaults[tagName]) {
        [styles addEntriesFromDictionary:defaults[tagName]];
    }
    
    // Applica regole CSS specifiche
    if (cssRules[tagName]) {
        [styles addEntriesFromDictionary:cssRules[tagName]];
    }
    
    // Converti in attributi NSAttributedString
    return [self convertCSSToNSAttributes:styles];
}

+ (NSDictionary*)convertCSSToNSAttributes:(NSDictionary*)cssStyles {
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    
    // Font size
    NSString* fontSize = cssStyles[@"font-size"];
    CGFloat fontSizeValue = 16.0; // default
    if (fontSize) {
        fontSizeValue = [[fontSize stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
    }
    
    // Font weight
    NSString* fontWeight = cssStyles[@"font-weight"];
    NSFont* font;
    if ([fontWeight isEqualToString:@"bold"]) {
        font = [NSFont boldSystemFontOfSize:fontSizeValue];
    } else {
        font = [NSFont systemFontOfSize:fontSizeValue];
    }
    attributes[NSFontAttributeName] = font;
    
    // Color
    NSString* color = cssStyles[@"color"];
    NSColor* textColor = [self colorFromCSS:color];
    if (textColor) {
        attributes[NSForegroundColorAttributeName] = textColor;
    }
    
    // Text decoration (underline)
    NSString* textDecoration = cssStyles[@"text-decoration"];
    if ([textDecoration isEqualToString:@"underline"]) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    return attributes;
}

+ (NSColor*)colorFromCSS:(NSString*)cssColor {
    if (!cssColor) return [NSColor blackColor];
    
    cssColor = [cssColor lowercaseString];
    
    // Colori CSS comuni
    NSDictionary* colorMap = @{
        @"black": [NSColor blackColor],
        @"white": [NSColor whiteColor],
        @"red": [NSColor redColor],
        @"blue": [NSColor blueColor],
        @"green": [NSColor greenColor],
        @"yellow": [NSColor yellowColor],
        @"orange": [NSColor orangeColor],
        @"purple": [NSColor purpleColor],
        @"gray": [NSColor grayColor],
        @"grey": [NSColor grayColor]
    };
    
    return colorMap[cssColor] ?: [NSColor blackColor];
}

@end
