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
    
    // SEMPRE applica stili di default del browser (come Chrome/Safari)
    NSDictionary* defaultStyles = [self getBrowserDefaultStyles];
    for (NSString* selector in defaultStyles) {
        if (!cssRules[selector]) {
            cssRules[selector] = defaultStyles[selector];
        } else {
            // Merge degli stili (default + custom)
            NSMutableDictionary* merged = [defaultStyles[selector] mutableCopy];
            [merged addEntriesFromDictionary:cssRules[selector]];
            cssRules[selector] = merged;
        }
    }
    
    std::cout << "✅ CSS: Parsed " << [cssRules count] << " CSS rules (including browser defaults)" << std::endl;
    
    return cssRules;
}

+ (NSDictionary*)getBrowserDefaultStyles {
    // Stili COMPLETI che Safari/Chrome applicano automaticamente
    return @{
        @"body": @{
            @"background-color": @"white",
            @"color": @"black",
            @"font-family": @"Times",  // Safari usa Times per default
            @"font-size": @"16px",
            @"line-height": @"1.2",
            @"margin": @"8px",
            @"padding": @"0px",
            @"text-align": @"left"
        },
        @"h1": @{
            @"font-size": @"32px",
            @"font-weight": @"bold",
            @"margin-top": @"21px", 
            @"margin-bottom": @"21px",
            @"margin-left": @"0px",
            @"margin-right": @"0px",
            @"color": @"black",
            @"line-height": @"1.2",
            @"display": @"block"
        },
        @"h2": @{
            @"font-size": @"24px",
            @"font-weight": @"bold",
            @"margin-top": @"19px",
            @"margin-bottom": @"19px", 
            @"margin-left": @"0px",
            @"margin-right": @"0px",
            @"color": @"black",
            @"line-height": @"1.2",
            @"display": @"block"
        },
        @"h3": @{
            @"font-size": @"19px",
            @"font-weight": @"bold",
            @"margin-top": @"16px",
            @"margin-bottom": @"16px",
            @"margin-left": @"0px", 
            @"margin-right": @"0px",
            @"color": @"black",
            @"line-height": @"1.2",
            @"display": @"block"
        },
        @"p": @{
            @"font-size": @"16px",
            @"margin-top": @"16px",
            @"margin-bottom": @"16px",
            @"margin-left": @"0px",
            @"margin-right": @"0px", 
            @"color": @"black",
            @"line-height": @"1.2",
            @"display": @"block"
        },
        @"a": @{
            @"color": @"rgb(0, 102, 204)",  // Blu Safari
            @"text-decoration": @"underline",
            @"font-size": @"16px"
        },
        @"title": @{
            @"display": @"none"  // Il title non si mostra nel body
        }
    };
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

+ (NSDictionary*)getStylesForElement:(NSString*)tagName withCSS:(NSDictionary*)cssRules {
    NSMutableDictionary* styles = [[NSMutableDictionary alloc] init];
    
    // Applica regole CSS per questo tag
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
        // Usa Times come Safari per il testo normale
        font = [NSFont fontWithName:@"Times New Roman" size:fontSizeValue] ?: [NSFont systemFontOfSize:fontSizeValue];
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
    
    // Paragraph style per margini
    NSString* marginTop = cssStyles[@"margin-top"];
    NSString* marginBottom = cssStyles[@"margin-bottom"];
    
    if (marginTop || marginBottom) {
        NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        
        if (marginTop) {
            CGFloat topMargin = [[marginTop stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
            [paragraphStyle setParagraphSpacingBefore:topMargin];
        }
        
        if (marginBottom) {
            CGFloat bottomMargin = [[marginBottom stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
            [paragraphStyle setParagraphSpacing:bottomMargin];
        }
        
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    
    return attributes;
}

+ (NSColor*)colorFromCSS:(NSString*)cssColor {
    if (!cssColor) return [NSColor blackColor];
    
    cssColor = [cssColor lowercaseString];
    
    // Gestisci colori RGB
    if ([cssColor hasPrefix:@"rgb("]) {
        // Estrai rgb(r, g, b)
        NSString* rgbValues = [cssColor stringByReplacingOccurrencesOfString:@"rgb(" withString:@""];
        rgbValues = [rgbValues stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray* components = [rgbValues componentsSeparatedByString:@","];
        
        if ([components count] == 3) {
            CGFloat r = [[components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue] / 255.0;
            CGFloat g = [[components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue] / 255.0;
            CGFloat b = [[components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue] / 255.0;
            
            return [NSColor colorWithRed:r green:g blue:b alpha:1.0];
        }
    }
    
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

+ (NSDictionary*)getDefaultBrowserStyles {
    // Questa è ridondante ora, ma manteniamo per retrocompatibilità
    return [self getBrowserDefaultStyles];
}

@end
