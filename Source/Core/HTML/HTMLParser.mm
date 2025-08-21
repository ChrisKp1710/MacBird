#import "HTMLParser.h"
#import "Core/CSS/CSSParser.h"
#include <iostream>

@implementation HTMLParser

+ (NSAttributedString*)parseHTML:(NSString*)htmlContent {
    std::cout << "🔧 HTML: Starting browser-like HTML parsing with CSS..." << std::endl;
    
    if (!htmlContent || [htmlContent length] == 0) {
        return [[NSAttributedString alloc] initWithString:@"Contenuto vuoto"];
    }
    
    // FASE 1: Parsa CSS dal HTML
    NSDictionary* cssRules = [CSSParser parseCSS:htmlContent];
    
    // FASE 2: Pulisci HTML (rimuovi CSS, script, commenti)
    NSString* cleanHTML = [self cleanHTML:htmlContent];
    
    // FASE 3: Estrai solo il contenuto del BODY
    NSString* bodyContent = [self extractBodyContent:cleanHTML];
    
    // FASE 4: Processa i tag principali con CSS applicato
    NSArray* elements = [self parseHTMLElements:bodyContent];
    
    // FASE 5: Crea il risultato finale con LAYOUT CENTRATO
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] init];
    
    // Aggiungi spazio iniziale per centrare (simula margini Safari)
    NSString* topSpacing = @"\n\n";
    NSDictionary* spacingAttrs = @{NSFontAttributeName: [NSFont systemFontOfSize:16]};
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:topSpacing attributes:spacingAttrs]];
    
    for (NSDictionary* element in elements) {
        NSString* type = element[@"type"];
        NSString* content = element[@"content"];
        
        // Salta il title (non si mostra nel body)
        if ([type isEqualToString:@"title"]) continue;
        
        // Ottieni stili CSS per questo elemento
        NSDictionary* styles = [CSSParser getStylesForElement:type withCSS:cssRules];
        
        // Crea testo formattato con stili CSS e LAYOUT CENTRATO
        NSAttributedString* formatted = [self createCenteredFormattedText:content 
                                                                 withType:type 
                                                                andStyles:styles];
        [result appendAttributedString:formatted];
    }
    
    // Se non abbiamo trovato contenuto, mostra messaggio
    if ([result length] <= 4) { // Solo spazi iniziali
        NSDictionary* attrs = @{
            NSFontAttributeName: [NSFont systemFontOfSize:16], 
            NSForegroundColorAttributeName: [NSColor secondaryLabelColor]
        };
        NSAttributedString* noContent = [[NSAttributedString alloc] initWithString:@"\n\nPagina caricata ma nessun contenuto testuale trovato.\n\nLa pagina potrebbe contenere principalmente JavaScript o elementi non testuali." attributes:attrs];
        [result appendAttributedString:noContent];
    }
    
    std::cout << "✅ HTML: Browser-like parsing completed, " << [[result string] length] << " characters in final content" << std::endl;
    
    return result;
}

+ (NSAttributedString*)createCenteredFormattedText:(NSString*)content 
                                          withType:(NSString*)type 
                                         andStyles:(NSDictionary*)styles {
    
    // CREA LAYOUT CENTRATO come Safari
    NSMutableDictionary* centeredStyles = [styles mutableCopy];
    
    // Crea paragraph style per centrare
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if ([type isEqualToString:@"h1"]) {
        // H1: Centrato e con margini grandi
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [paragraphStyle setParagraphSpacing:30];
        [paragraphStyle setParagraphSpacingBefore:20];
        [paragraphStyle setFirstLineHeadIndent:50]; // Margine sinistro
        [paragraphStyle setHeadIndent:50];          // Margine sinistro
        [paragraphStyle setTailIndent:-50];         // Margine destro
        
    } else if ([type isEqualToString:@"p"]) {
        // Paragrafi: Centrati con margini moderati
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [paragraphStyle setParagraphSpacing:20];
        [paragraphStyle setParagraphSpacingBefore:10];
        [paragraphStyle setFirstLineHeadIndent:80]; // Margine sinistro
        [paragraphStyle setHeadIndent:80];          // Margine sinistro  
        [paragraphStyle setTailIndent:-80];         // Margine destro
        
    } else if ([type isEqualToString:@"a"]) {
        // Link: Stesso layout dei paragrafi
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [paragraphStyle setParagraphSpacing:10];
        [paragraphStyle setFirstLineHeadIndent:80]; // Margine sinistro
        [paragraphStyle setHeadIndent:80];          // Margine sinistro
        [paragraphStyle setTailIndent:-80];         // Margine destro
        
    } else {
        // Altri elementi: Layout base centrato
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [paragraphStyle setParagraphSpacing:15];
        [paragraphStyle setFirstLineHeadIndent:60];
        [paragraphStyle setHeadIndent:60];
        [paragraphStyle setTailIndent:-60];
    }
    
    centeredStyles[NSParagraphStyleAttributeName] = paragraphStyle;
    
    // Determina spaziatura basata sul tipo di elemento
    NSString* formattedContent;
    if ([type isEqualToString:@"h1"]) {
        formattedContent = [NSString stringWithFormat:@"%@\n\n", content];
    } else if ([type isEqualToString:@"p"]) {
        formattedContent = [NSString stringWithFormat:@"%@\n\n", content];
    } else if ([type isEqualToString:@"a"]) {
        formattedContent = [NSString stringWithFormat:@"%@\n", content];
    } else {
        formattedContent = [NSString stringWithFormat:@"%@\n\n", content];
    }
    
    return [[NSAttributedString alloc] initWithString:formattedContent attributes:centeredStyles];
}

+ (NSString*)cleanHTML:(NSString*)html {
    NSMutableString* cleaned = [html mutableCopy];
    
    // Rimuovi script
    NSRegularExpression* scriptRegex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>.*?</script>" 
                                                                                 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                                                                   error:nil];
    [scriptRegex replaceMatchesInString:cleaned options:0 range:NSMakeRange(0, [cleaned length]) withTemplate:@""];
    
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

+ (NSString*)extractTextContent:(NSString*)htmlContent {
    return [self stripHTMLTags:htmlContent];
}

@end
