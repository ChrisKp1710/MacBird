#import "ElementsTab.h"
#import "Platform/macOS/BrowserWindow.h"
#import "../Common/DevToolsStyles.h"
#include <iostream>

@implementation ElementsTab

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.containerView = [self createElementsTabView:frame];
    }
    return self;
}

- (NSView*)createElementsTabView:(NSRect)frame {
    NSView* htmlContainer = [[NSView alloc] initWithFrame:frame];
    [htmlContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [htmlContainer setWantsLayer:YES];
    [htmlContainer.layer setBackgroundColor:[DevToolsStyles containerBackgroundColor].CGColor];
    
    // Toolbar Elements
    CGFloat toolbarHeight = [DevToolsStyles toolbarHeight];
    NSView* htmlToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, frame.size.height - toolbarHeight, frame.size.width, toolbarHeight)];
    [htmlToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [htmlToolbar setWantsLayer:YES];
    [htmlToolbar.layer setBackgroundColor:[DevToolsStyles toolbarBackgroundColor].CGColor];
    [htmlToolbar.layer setBorderWidth:[DevToolsStyles borderWidth]];
    [htmlToolbar.layer setBorderColor:[DevToolsStyles borderColor].CGColor];
    
    NSButton* htmlRefreshButton = [[NSButton alloc] initWithFrame:NSMakeRect([DevToolsStyles padding], 6, 100, 23)];
    [htmlRefreshButton setTitle:@"Refresh HTML"];
    [htmlRefreshButton setTarget:self];
    [htmlRefreshButton setAction:@selector(refreshHTMLSource)];
    [htmlRefreshButton setBezelStyle:NSBezelStyleRounded];
    [htmlRefreshButton setControlSize:NSControlSizeSmall];
    [htmlRefreshButton setWantsLayer:YES];
    [htmlRefreshButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [htmlRefreshButton.layer setCornerRadius:3];
    
    // Label info
    NSTextField* infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(125, 10, 300, 16)];
    [infoLabel setStringValue:@"HTML Elements Inspector"];
    [infoLabel setBezeled:NO];
    [infoLabel setDrawsBackground:NO];
    [infoLabel setEditable:NO];
    [infoLabel setSelectable:NO];
    [infoLabel setTextColor:[DevToolsStyles secondaryTextColor]];
    [infoLabel setFont:[DevToolsStyles uiFont]];
    
    [htmlToolbar addSubview:htmlRefreshButton];
    [htmlToolbar addSubview:infoLabel];
    
    NSScrollView* htmlScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - toolbarHeight)];
    [htmlScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [htmlScrollView setHasVerticalScroller:YES];
    [htmlScrollView setBorderType:NSNoBorder];
    [htmlScrollView setDrawsBackground:YES];
    [htmlScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    self.htmlSource = [[NSTextView alloc] initWithFrame:[[htmlScrollView contentView] bounds]];
    [self.htmlSource setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.htmlSource setTextColor:[DevToolsStyles primaryTextColor]];
    [self.htmlSource setInsertionPointColor:[NSColor whiteColor]];
    [self.htmlSource setFont:[DevToolsStyles codeFont]];
    [self.htmlSource setEditable:NO];
    [self.htmlSource setSelectable:YES];
    [self.htmlSource setString:@"📄 HTML Source will appear here...\n\nClick 'Refresh HTML' button to load current page HTML"];
    
    [htmlScrollView setDocumentView:self.htmlSource];
    [htmlContainer addSubview:htmlScrollView];
    [htmlContainer addSubview:htmlToolbar];
    
    return htmlContainer;
}

- (NSView*)createElementsTabView {
    return self.containerView;
}

- (void)refreshHTMLSource {
    NSString* htmlScript = @"document.documentElement.outerHTML";
    [self.browserWindow.webView evaluateJavaScript:htmlScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            NSString* html = (NSString*)result;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* formattedHTML = [self formatHTMLString:html];
                [self.htmlSource setString:formattedHTML];
                [self applySyntaxHighlighting];
            });
        }
    }];
}

- (NSString*)formatHTMLString:(NSString*)html {
    NSMutableString* formatted = [[NSMutableString alloc] init];
    NSInteger indentLevel = 0;
    NSString* indent = @"    "; // 4 spazi per livello
    
    // Rimuovi spazi extra e new line esistenti
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    NSScanner* scanner = [NSScanner scannerWithString:html];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    while (![scanner isAtEnd]) {
        NSString* content = nil;
        
        // Scannerizza fino al prossimo tag
        if ([scanner scanUpToString:@"<" intoString:&content]) {
            if (content && content.length > 0) {
                content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (content.length > 0) {
                    for (NSInteger i = 0; i < indentLevel; i++) {
                        [formatted appendString:indent];
                    }
                    [formatted appendFormat:@"%@\n", content];
                }
            }
        }
        
        // Scannerizza il tag
        NSString* tag = nil;
        if ([scanner scanUpToString:@">" intoString:&tag]) {
            [scanner scanString:@">" intoString:nil];
            tag = [tag stringByAppendingString:@">"];
            
            if ([tag hasPrefix:@"</"] && [tag hasSuffix:@">"]) {
                // Tag di chiusura
                indentLevel = MAX(0, indentLevel - 1);
                for (NSInteger i = 0; i < indentLevel; i++) {
                    [formatted appendString:indent];
                }
                [formatted appendFormat:@"%@\n", tag];
            } else if ([tag hasSuffix:@"/>"] || 
                      [tag.lowercaseString containsString:@"<br"] ||
                      [tag.lowercaseString containsString:@"<hr"] ||
                      [tag.lowercaseString containsString:@"<img"] ||
                      [tag.lowercaseString containsString:@"<input"] ||
                      [tag.lowercaseString containsString:@"<meta"] ||
                      [tag.lowercaseString containsString:@"<link"]) {
                // Tag self-closing
                for (NSInteger i = 0; i < indentLevel; i++) {
                    [formatted appendString:indent];
                }
                [formatted appendFormat:@"%@\n", tag];
            } else {
                // Tag di apertura
                for (NSInteger i = 0; i < indentLevel; i++) {
                    [formatted appendString:indent];
                }
                [formatted appendFormat:@"%@\n", tag];
                indentLevel++;
            }
        }
    }
    
    return formatted;
}

- (void)applySyntaxHighlighting {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[self.htmlSource string]];
    NSString* htmlString = [self.htmlSource string];
    
    // Font base
    [attributedString addAttribute:NSFontAttributeName value:[DevToolsStyles codeFont] range:NSMakeRange(0, htmlString.length)];
    
    // Evidenzia i tag HTML
    NSRegularExpression* tagRegex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:nil];
    [tagRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[DevToolsStyles htmlTagColor] range:match.range];
    }];
    
    // Evidenzia gli attributi
    NSRegularExpression* attrRegex = [NSRegularExpression regularExpressionWithPattern:@"\\s(\\w+)=\"[^\"]*\"" options:0 error:nil];
    [attrRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[DevToolsStyles htmlAttributeColor] range:match.range];
    }];
    
    // Evidenzia le stringhe tra virgolette
    NSRegularExpression* stringRegex = [NSRegularExpression regularExpressionWithPattern:@"\"[^\"]*\"" options:0 error:nil];
    [stringRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[DevToolsStyles htmlStringColor] range:match.range];
    }];
    
    // Evidenzia i commenti
    NSRegularExpression* commentRegex = [NSRegularExpression regularExpressionWithPattern:@"<!--[^>]*-->" options:0 error:nil];
    [commentRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[DevToolsStyles htmlCommentColor] range:match.range];
    }];
    
    // Applica il syntax highlighting
    [[self.htmlSource textStorage] setAttributedString:attributedString];
}

@end