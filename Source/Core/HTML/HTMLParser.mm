#import "HTMLParser.h"
#include <iostream>

@implementation HTMLParser

+ (NSAttributedString*)parseHTML:(NSString*)htmlContent {
    std::cout << "🔧 HTML: Starting advanced HTML parsing..." << std::endl;
    
    if (!htmlContent || [htmlContent length] == 0) {
        return [[NSAttributedString alloc] initWithString:@"Contenuto vuoto"];
    }
    
    // Crea attributedString per il risultato finale
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] init];
    
    // Font di base
    NSFont* normalFont = [NSFont systemFontOfSize:16];
    NSFont* titleFont = [NSFont boldSystemFontOfSize:32];
    NSFont* h1Font = [NSFont boldSystemFontOfSize:28];
    NSFont* h2Font = [NSFont boldSystemFontOfSize:24];
    NSFont* h3Font = [NSFont boldSystemFontOfSize:20];
    
    // Colori
    NSColor* normalColor = [NSColor labelColor];
    NSColor* linkColor = [NSColor systemBlueColor];
    
    // FASE 1: Pulisci HTML (rimuovi CSS, script, commenti)
    NSString* cleanHTML = [self cleanHTML:htmlContent];
    
    // FASE 2: Estrai solo il contenuto del BODY
    NSString* bodyContent = [self extractBodyContent:cleanHTML];
    
    // FASE 3: Processa i tag principali
    NSArray* elements = [self parseHTMLElements:bodyContent];
    
    for (NSDictionary* element in elements) {
        NSString* type = element[@"type"];
        NSString* content = element[@"content"];
        
        if ([type isEqualToString:@"title"]) {
            NSDictionary* attrs = @{NSFontAttributeName: titleFont, NSForegroundColorAttributeName: [NSColor systemPurpleColor]};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"📄 %@\n\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
            
        } else if ([type isEqualToString:@"h1"]) {
            NSDictionary* attrs = @{NSFontAttributeName: h1Font, NSForegroundColorAttributeName: normalColor};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
            
        } else if ([type isEqualToString:@"h2"]) {
            NSDictionary* attrs = @{NSFontAttributeName: h2Font, NSForegroundColorAttributeName: normalColor};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
            
        } else if ([type isEqualToString:@"h3"]) {
            NSDictionary* attrs = @{NSFontAttributeName: h3Font, NSForegroundColorAttributeName: normalColor};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
            
        } else if ([type isEqualToString:@"p"]) {
            NSDictionary* attrs = @{NSFontAttributeName: normalFont, NSForegroundColorAttributeName: normalColor};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
            
        } else if ([type isEqualToString:@"a"]) {
            NSDictionary* attrs = @{NSFontAttributeName: normalFont, NSForegroundColorAttributeName: linkColor, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            NSAttributedString* formatted = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"🔗 %@\n", content] attributes:attrs];
            [result appendAttributedString:formatted];
        }
    }
    
    // Se non abbiamo trovato contenuto, mostra messaggio
    if ([result length] == 0) {
        NSDictionary* attrs = @{NSFontAttributeName: normalFont, NSForegroundColorAttributeName: [NSColor secondaryLabelColor]};
        NSAttributedString* noContent = [[NSAttributedString alloc] initWithString:@"📄 Pagina caricata ma nessun contenuto testuale trovato.\n\nLa pagina potrebbe contenere principalmente JavaScript o elementi non testuali." attributes:attrs];
        [result appendAttributedString:noContent];
    }
    
    std::cout << "✅ HTML: Advanced parsing completed, " << [[result string] length] << " characters in final content" << std::endl;
    
    return result;
}

+ (NSString*)cleanHTML:(NSString*)html {
    NSMutableString* cleaned = [html mutableCopy];
    
    // Rimuovi script
    NSRegularExpression* scriptRegex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>.*?</script>" 
                                                                                 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                   error:nil];
    [scriptRegex replaceMatchesInString:cleaned options:0 range:NSMakeRange(0, [cleaned length]) withTemplate:@""];
    
    // Rimuovi style
    NSRegularExpression* styleRegex = [NSRegularExpression regularExpressionWithPattern:@"<style[^>]*>.*?</style>" 
                                                                                options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                  error:nil];
    [styleRegex replaceMatchesInString:cleaned options:0 range:NSMakeRange(0, [cleaned length]) withTemplate:@""];
    
    // Rimuovi commenti HTML
    NSRegularExpression* commentRegex = [NSRegularExpression regularExpressionWithPattern:@"<!--.*?-->" 
                                                                                  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                    error:nil];
    [commentRegex replaceMatchesInString:cleaned options:0 range:NSMakeRange(0, [cleaned length]) withTemplate:@""];
    
    return cleaned;
}

+ (NSString*)extractBodyContent:(NSString*)html {
    NSRegularExpression* bodyRegex = [NSRegularExpression regularExpressionWithPattern:@"<body[^>]*>(.*?)</body>" 
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                 error:nil];
    NSTextCheckingResult* match = [bodyRegex firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
    
    if (match && [match numberOfRanges] > 1) {
        return [html substringWithRange:[match rangeAtIndex:1]];
    }
    
    // Se non trova body, restituisce tutto (fallback)
    return html;
}

+ (NSArray*)parseHTMLElements:(NSString*)html {
    NSMutableArray* elements = [[NSMutableArray alloc] init];
    
    // Pattern per i vari tag
    NSArray* patterns = @[
        @{@"pattern": @"<title[^>]*>(.*?)</title>", @"type": @"title"},
        @{@"pattern": @"<h1[^>]*>(.*?)</h1>", @"type": @"h1"},
        @{@"pattern": @"<h2[^>]*>(.*?)</h2>", @"type": @"h2"},
        @{@"pattern": @"<h3[^>]*>(.*?)</h3>", @"type": @"h3"},
        @{@"pattern": @"<p[^>]*>(.*?)</p>", @"type": @"p"},
        @{@"pattern": @"<a[^>]*>(.*?)</a>", @"type": @"a"}
    ];
    
    for (NSDictionary* patternInfo in patterns) {
        NSString* pattern = patternInfo[@"pattern"];
        NSString* type = patternInfo[@"type"];
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern 
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                 error:nil];
        
        NSArray* matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        for (NSTextCheckingResult* match in matches) {
            if ([match numberOfRanges] > 1) {
                NSString* content = [html substringWithRange:[match rangeAtIndex:1]];
                // Pulisci il contenuto da eventuali tag interni
                content = [self stripHTMLTags:content];
                content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([content length] > 0) {
                    [elements addObject:@{@"type": type, @"content": content}];
                }
            }
        }
    }
    
    return elements;
}

+ (NSString*)stripHTMLTags:(NSString*)html {
    NSRegularExpression* tagRegex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" 
                                                                              options:NSRegularExpressionCaseInsensitive 
                                                                                error:nil];
    return [tagRegex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, [html length]) withTemplate:@""];
}

+ (NSString*)extractContentFromTag:(NSString*)line startTag:(NSString*)startTag endTag:(NSString*)endTag {
    NSRange startRange = [line rangeOfString:startTag];
    NSRange endRange = [line rangeOfString:endTag];
    
    if (startRange.location != NSNotFound && endRange.location != NSNotFound && endRange.location > startRange.location) {
        NSUInteger contentStart = startRange.location + startRange.length;
        NSUInteger contentLength = endRange.location - contentStart;
        return [line substringWithRange:NSMakeRange(contentStart, contentLength)];
    }
    
    return nil;
}

+ (NSString*)extractLinkText:(NSString*)line {
    NSRange aStart = [line rangeOfString:@">"];
    NSRange aEnd = [line rangeOfString:@"</a>"];
    
    if (aStart.location != NSNotFound && aEnd.location != NSNotFound && aEnd.location > aStart.location) {
        NSUInteger contentStart = aStart.location + 1;
        NSUInteger contentLength = aEnd.location - contentStart;
        return [line substringWithRange:NSMakeRange(contentStart, contentLength)];
    }
    
    return @"[link]";
}

+ (NSString*)extractTextContent:(NSString*)htmlContent {
    return [self stripHTMLTags:htmlContent];
}

@end
