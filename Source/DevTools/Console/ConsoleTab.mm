#import "ConsoleTab.h"
#import "Platform/macOS/BrowserWindow.h"
#import "../Common/DevToolsStyles.h"
#include <iostream>

@implementation ConsoleTab

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.containerView = [self createConsoleTabView:frame];
    }
    return self;
}

- (NSView*)createConsoleTabView:(NSRect)frame {
    // Container console con sfondo scuro
    NSView* consoleContainer = [[NSView alloc] initWithFrame:frame];
    [consoleContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [consoleContainer setWantsLayer:YES];
    [consoleContainer.layer setBackgroundColor:[DevToolsStyles containerBackgroundColor].CGColor];
    
    // === TOOLBAR SCURA CHROME STYLE ===
    CGFloat toolbarHeight = [DevToolsStyles toolbarHeight];
    NSRect toolbarFrame = NSMakeRect(0, frame.size.height - toolbarHeight, frame.size.width, toolbarHeight);
    NSView* consoleToolbar = [[NSView alloc] initWithFrame:toolbarFrame];
    [consoleToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [consoleToolbar setWantsLayer:YES];
    [consoleToolbar.layer setBackgroundColor:[DevToolsStyles toolbarBackgroundColor].CGColor];
    [consoleToolbar.layer setBorderWidth:[DevToolsStyles borderWidth]];
    [consoleToolbar.layer setBorderColor:[DevToolsStyles borderColor].CGColor];
    
    // PULSANTI SCURI CHROME STYLE
    CGFloat padding = [DevToolsStyles padding];
    NSButton* clearButton = [[NSButton alloc] initWithFrame:NSMakeRect(padding, 6, 60, 23)];
    [clearButton setTitle:@"Clear"];
    [clearButton setBezelStyle:NSBezelStyleRounded];
    [clearButton setControlSize:NSControlSizeSmall];
    [clearButton setTarget:self];
    [clearButton setAction:@selector(clearConsole)];
    [clearButton setWantsLayer:YES];
    [clearButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [clearButton.layer setCornerRadius:3];
    
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(80, 6, 60, 23)];
    [refreshButton setTitle:@"Refresh"];
    [refreshButton setBezelStyle:NSBezelStyleRounded];
    [refreshButton setControlSize:NSControlSizeSmall];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(runDetectionAnalysis)];
    [refreshButton setWantsLayer:YES];
    [refreshButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [refreshButton.layer setCornerRadius:3];
    
    // Label con testo chiaro su sfondo scuro
    NSTextField* infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(155, 10, 300, 16)];
    [infoLabel setStringValue:@"MacBird Console - Dark Theme"];
    [infoLabel setBezeled:NO];
    [infoLabel setDrawsBackground:NO];
    [infoLabel setEditable:NO];
    [infoLabel setSelectable:NO];
    [infoLabel setTextColor:[DevToolsStyles secondaryTextColor]];
    [infoLabel setFont:[DevToolsStyles uiFont]];
    
    [consoleToolbar addSubview:clearButton];
    [consoleToolbar addSubview:refreshButton];
    [consoleToolbar addSubview:infoLabel];
    
    // === CONSOLE OUTPUT SCURA ===
    NSRect scrollFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height - toolbarHeight);
    NSScrollView* consoleScrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [consoleScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [consoleScrollView setHasVerticalScroller:YES];
    [consoleScrollView setHasHorizontalScroller:NO];
    [consoleScrollView setBorderType:NSNoBorder];
    [consoleScrollView setDrawsBackground:YES];
    [consoleScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    NSRect textFrame = [[consoleScrollView contentView] bounds];
    self.consoleOutput = [[NSTextView alloc] initWithFrame:textFrame];
    [self.consoleOutput setMinSize:NSMakeSize(0.0, 0.0)];
    [self.consoleOutput setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.consoleOutput setVerticallyResizable:YES];
    [self.consoleOutput setHorizontallyResizable:NO];
    [self.consoleOutput setAutoresizingMask:NSViewWidthSizable];
    [[self.consoleOutput textContainer] setContainerSize:NSMakeSize(textFrame.size.width, FLT_MAX)];
    [[self.consoleOutput textContainer] setWidthTracksTextView:YES];
    
    // TEMA SCURO CONSOLE - IDENTICO A CHROME DEVTOOLS
    [self.consoleOutput setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.consoleOutput setTextColor:[DevToolsStyles primaryTextColor]];
    [self.consoleOutput setInsertionPointColor:[NSColor whiteColor]];
    [self.consoleOutput setFont:[DevToolsStyles consoleFont]];
    [self.consoleOutput setEditable:NO];
    [self.consoleOutput setSelectable:YES];
    [self.consoleOutput setRichText:YES];
    [self.consoleOutput setString:@""];
    
    [consoleScrollView setDocumentView:self.consoleOutput];
    [consoleContainer addSubview:consoleScrollView];
    [consoleContainer addSubview:consoleToolbar];
    
    // Messaggi di benvenuto con colori console
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logToConsole:@"🛠️ MacBird Developer Tools - Console" withColor:[DevToolsStyles accentTextColor]];
        [self logToConsole:@"================================================" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"✅ Console tab loaded successfully" withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@"🎨 Chrome DevTools dark theme applied" withColor:[DevToolsStyles warningTextColor]];
        [self logToConsole:@"📱 Ready for browser analysis" withColor:[DevToolsStyles primaryTextColor]];
        [self logToConsole:@"" withColor:nil];
        [self logToConsole:@"💡 TIP: Click 'Refresh' to run detection analysis" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"🔍 TIP: Go to google.com and refresh to test detection" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"" withColor:nil];
    });
    
    return consoleContainer;
}

- (NSView*)createConsoleTabView {
    // Metodo wrapper per compatibilità
    return self.containerView;
}

- (void)runDetectionAnalysis {
    [self logToConsole:@"🔍 Running browser detection analysis..."];
    
    NSString* detectionScript = @""
        "const analysis = {"
        "  userAgent: navigator.userAgent,"
        "  platform: navigator.platform,"
        "  vendor: navigator.vendor || 'unknown',"
        "  webkitVersion: navigator.userAgent.match(/WebKit\\/(\\S+)/)?.[1] || 'unknown',"
        "  safariVersion: navigator.userAgent.match(/Version\\/(\\S+)/)?.[1] || 'unknown',"
        "  features: {"
        "    cssGrid: CSS.supports('display', 'grid'),"
        "    cssFlexbox: CSS.supports('display', 'flex'),"
        "    borderRadius: CSS.supports('border-radius', '10px'),"
        "    backdropFilter: CSS.supports('backdrop-filter', 'blur(10px)'),"
        "    fetchAPI: typeof fetch !== 'undefined',"
        "    webGL: !!document.createElement('canvas').getContext('webgl'),"
        "    webGL2: !!document.createElement('canvas').getContext('webgl2'),"
        "    intersectionObserver: typeof IntersectionObserver !== 'undefined',"
        "    resizeObserver: typeof ResizeObserver !== 'undefined',"
        "    serviceWorker: 'serviceWorker' in navigator,"
        "    pushAPI: 'PushManager' in window,"
        "    notifications: 'Notification' in window"
        "  },"
        "  screenInfo: {"
        "    width: screen.width,"
        "    height: screen.height,"
        "    pixelRatio: window.devicePixelRatio,"
        "    colorDepth: screen.colorDepth"
        "  }"
        "};"
        ""
        "if (window.location.hostname.includes('google')) {"
        "  const searchBox = document.querySelector('input[name=q], .gLFyf');"
        "  analysis.googleAnalysis = {"
        "    searchBoxFound: !!searchBox,"
        "    modernLayout: searchBox ? getComputedStyle(searchBox).borderRadius !== '0px' : false,"
        "    searchBoxBorderRadius: searchBox ? getComputedStyle(searchBox).borderRadius : 'none'"
        "  };"
        "}"
        ""
        "JSON.stringify(analysis, null, 2);";
    
    [self.browserWindow.webView evaluateJavaScript:detectionScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Analysis error: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        } else if (result) {
            NSString* analysisJSON = (NSString*)result;
            [self displayAnalysisResults:analysisJSON];
        }
    }];
}

- (void)displayAnalysisResults:(NSString*)analysisJSON {
    NSData* jsonData = [analysisJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* analysis = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ Error parsing analysis results" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"=== 🔍 BROWSER ANALYSIS RESULTS ===" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"📱 User Agent: %@", analysis[@"userAgent"]]];
    [self logToConsole:[NSString stringWithFormat:@"🖥️  Platform: %@", analysis[@"platform"]]];
    [self logToConsole:[NSString stringWithFormat:@"🔧 WebKit Version: %@", analysis[@"webkitVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"🌐 Safari Version: %@", analysis[@"safariVersion"]]];
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ FEATURE SUPPORT ANALYSIS ===" withColor:[DevToolsStyles accentTextColor]];
    NSDictionary* features = analysis[@"features"];
    for (NSString* feature in features) {
        BOOL supported = [features[feature] boolValue];
        NSString* status = supported ? @"✅ SUPPORTED" : @"❌ NOT SUPPORTED";
        NSString* paddedFeature = [feature stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
        NSColor* color = supported ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
        [self logToConsole:[NSString stringWithFormat:@"  %@ → %@", paddedFeature, status] withColor:color];
    }
    
    if (analysis[@"googleAnalysis"]) {
        [self logToConsole:@""];
        [self logToConsole:@"=== 🔍 GOOGLE PAGE DETECTION ===" withColor:[DevToolsStyles accentTextColor]];
        NSDictionary* google = analysis[@"googleAnalysis"];
        NSString* searchBoxStatus = [google[@"searchBoxFound"] boolValue] ? @"✅ FOUND" : @"❌ NOT FOUND";
        NSString* modernStatus = [google[@"modernLayout"] boolValue] ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
        
        [self logToConsole:[NSString stringWithFormat:@"  🔍 Search box detected → %@", searchBoxStatus]];
        [self logToConsole:[NSString stringWithFormat:@"  🎨 Layout type detected → %@", modernStatus]];
        [self logToConsole:[NSString stringWithFormat:@"  📐 Border radius value → %@", google[@"searchBoxBorderRadius"]]];
        
        if ([google[@"modernLayout"] boolValue]) {
            [self logToConsole:@"  🎉 Google recognizes us as MODERN browser!" withColor:[DevToolsStyles successTextColor]];
        } else {
            [self logToConsole:@"  ⚠️  Google serves us OLD layout - needs investigation" withColor:[DevToolsStyles warningTextColor]];
        }
    }
    
    NSDictionary* screen = analysis[@"screenInfo"];
    [self logToConsole:@""];
    [self logToConsole:@"=== 📱 DEVICE & DISPLAY INFO ===" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"  📺 Screen Resolution → %@x%@", screen[@"width"], screen[@"height"]]];
    [self logToConsole:[NSString stringWithFormat:@"  🔍 Pixel Ratio → %@x", screen[@"pixelRatio"]]];
    [self logToConsole:[NSString stringWithFormat:@"  🎨 Color Depth → %@ bits", screen[@"colorDepth"]]];
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ ANALYSIS COMPLETE ===" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@"💡 TIP: Check Elements tab for page source" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"🔍 TIP: Go to google.com to test Google detection" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@""];
}

- (void)clearConsole {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.consoleOutput setString:@""];
        [self logToConsole:@"🛠️ MacBird Developer Tools - Console" withColor:[DevToolsStyles accentTextColor]];
        [self logToConsole:@"================================================" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"✅ Console cleared" withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@""];
    });
}

- (void)logToConsole:(NSString*)message {
    [self logToConsole:message withColor:nil];
}

- (void)logToConsole:(NSString*)message withColor:(NSColor*)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                             dateStyle:NSDateFormatterNoStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
        NSString* logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
        
        // Crea attributed string con colore personalizzato
        NSMutableAttributedString* attributedMessage = [[NSMutableAttributedString alloc] initWithString:logMessage];
        
        // Applica font monospaziato
        [attributedMessage addAttribute:NSFontAttributeName value:[DevToolsStyles consoleFont] range:NSMakeRange(0, logMessage.length)];
        
        // Applica colore se specificato, altrimenti usa colore default
        NSColor* textColor = color ?: [DevToolsStyles primaryTextColor];
        [attributedMessage addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, logMessage.length)];
        
        // Aggiungi al console output
        [self.consoleOutput.textStorage appendAttributedString:attributedMessage];
        
        // Scroll to bottom
        NSRange range = NSMakeRange([[self.consoleOutput string] length], 0);
        [self.consoleOutput scrollRangeToVisible:range];
    });
}

@end