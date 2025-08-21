#import "DevToolsManager.h"
#import "BrowserWindow.h"
#include <iostream>

@implementation DevToolsManager

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.devToolsWindow = nil;
    }
    return self;
}

- (void)toggleDevTools {
    // FIX: Controllo più robusto per evitare bug dopo cambio tab
    if (self.devToolsWindow && [self.devToolsWindow isVisible] && !self.devToolsWindow.isMiniaturized) {
        [self closeDevTools];
    } else {
        [self openDevTools];
    }
}

- (void)openDevTools {
    // FIX: Se la finestra esiste ma è chiusa/minimizzata, riportala in primo piano
    if (self.devToolsWindow) {
        [self.devToolsWindow makeKeyAndOrderFront:nil];
        [self.devToolsWindow deminiaturize:nil];
        return;
    }
    
    // Crea finestra DevTools (80% larghezza dello schermo, 500px altezza)
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    NSRect devToolsFrame = NSMakeRect(
        screenFrame.size.width * 0.1,
        80,
        screenFrame.size.width * 0.8,
        500
    );
    
    self.devToolsWindow = [[NSWindow alloc] initWithContentRect:devToolsFrame
                                                      styleMask:(NSWindowStyleMaskTitled |
                                                               NSWindowStyleMaskClosable |
                                                               NSWindowStyleMaskResizable)
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    
    [self.devToolsWindow setTitle:@"MacBird Developer Tools"];
    // TEMA SCURO COME CHROME DEVTOOLS VERO
    [self.devToolsWindow setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    [self.devToolsWindow setTitlebarAppearsTransparent:YES];
    
    [self setupDevToolsUI];
    [self.devToolsWindow makeKeyAndOrderFront:nil];
    
    // Auto-run detection quando si aprono i DevTools
    [self runDetectionAnalysis];
    
    std::cout << "🛠️ MacBird DevTools opened" << std::endl;
}

- (void)setupDevToolsUI {
    NSView* contentView = [self.devToolsWindow contentView];
    NSRect contentFrame = [contentView bounds];
    
    // === TAB VIEW CON TEMA SCURO CHROME DEVTOOLS ===
    self.tabView = [[NSTabView alloc] initWithFrame:contentFrame];
    [self.tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.tabView setTabViewType:NSTopTabsBezelBorder];
    [self.tabView setWantsLayer:YES];
    // SFONDO SCURO CHROME DEVTOOLS AUTENTICO
    [self.tabView.layer setBackgroundColor:[NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor];
    
    // === TAB CONSOLE TEMA SCURO ===
    NSTabViewItem* consoleTab = [[NSTabViewItem alloc] initWithIdentifier:@"console"];
    [consoleTab setLabel:@"Console"];
    
    // Container console con sfondo scuro
    NSView* consoleContainer = [[NSView alloc] initWithFrame:contentFrame];
    [consoleContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [consoleContainer setWantsLayer:YES];
    [consoleContainer.layer setBackgroundColor:[NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0].CGColor];
    
    // === TOOLBAR SCURA CHROME STYLE ===
    CGFloat toolbarHeight = 35;
    NSRect toolbarFrame = NSMakeRect(0, contentFrame.size.height - toolbarHeight, contentFrame.size.width, toolbarHeight);
    NSView* consoleToolbar = [[NSView alloc] initWithFrame:toolbarFrame];
    [consoleToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [consoleToolbar setWantsLayer:YES];
    // TOOLBAR SCURA CHROME DEVTOOLS
    [consoleToolbar.layer setBackgroundColor:[NSColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0].CGColor];
    [consoleToolbar.layer setBorderWidth:0.5];
    [consoleToolbar.layer setBorderColor:[NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor];
    
    // PULSANTI SCURI CHROME STYLE
    NSButton* clearButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 6, 60, 23)];
    [clearButton setTitle:@"Clear"];
    [clearButton setBezelStyle:NSBezelStyleRounded];
    [clearButton setControlSize:NSControlSizeSmall];
    [clearButton setTarget:self];
    [clearButton setAction:@selector(clearConsole)];
    // Stile scuro per pulsanti
    [clearButton setWantsLayer:YES];
    [clearButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [clearButton.layer setCornerRadius:3];
    
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(80, 6, 60, 23)];
    [refreshButton setTitle:@"Refresh"];
    [refreshButton setBezelStyle:NSBezelStyleRounded];
    [refreshButton setControlSize:NSControlSizeSmall];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(runDetectionAnalysis)];
    [refreshButton setWantsLayer:YES];
    [refreshButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [refreshButton.layer setCornerRadius:3];
    
    // Label con testo chiaro su sfondo scuro
    NSTextField* infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(155, 10, 300, 16)];
    [infoLabel setStringValue:@"MacBird Console - Dark Theme"];
    [infoLabel setBezeled:NO];
    [infoLabel setDrawsBackground:NO];
    [infoLabel setEditable:NO];
    [infoLabel setSelectable:NO];
    [infoLabel setTextColor:[NSColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]]; // Testo chiaro
    [infoLabel setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightMedium]];
    
    [consoleToolbar addSubview:clearButton];
    [consoleToolbar addSubview:refreshButton];
    [consoleToolbar addSubview:infoLabel];
    
    // === CONSOLE OUTPUT SCURA ===
    NSRect scrollFrame = NSMakeRect(0, 0, contentFrame.size.width, contentFrame.size.height - toolbarHeight);
    NSScrollView* consoleScrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [consoleScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [consoleScrollView setHasVerticalScroller:YES];
    [consoleScrollView setHasHorizontalScroller:NO];
    [consoleScrollView setBorderType:NSNoBorder];
    [consoleScrollView setDrawsBackground:YES];
    // SFONDO SCURO CONSOLE
    [consoleScrollView setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    
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
    [self.consoleOutput setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    [self.consoleOutput setTextColor:[NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]]; // Testo chiaro
    [self.consoleOutput setInsertionPointColor:[NSColor whiteColor]]; // Cursore bianco
    [self.consoleOutput setFont:[NSFont fontWithName:@"SF Mono" size:12] ?: [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular]];
    [self.consoleOutput setEditable:NO];
    [self.consoleOutput setSelectable:YES];
    [self.consoleOutput setRichText:YES];
    [self.consoleOutput setString:@""];
    
    [consoleScrollView setDocumentView:self.consoleOutput];
    [consoleContainer addSubview:consoleScrollView];
    [consoleContainer addSubview:consoleToolbar];
    [consoleTab setView:consoleContainer];
    
    // === TAB ELEMENTS TEMA SCURO ===
    NSTabViewItem* htmlTab = [[NSTabViewItem alloc] initWithIdentifier:@"html"];
    [htmlTab setLabel:@"Elements"];
    
    NSView* htmlContainer = [[NSView alloc] initWithFrame:contentFrame];
    [htmlContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [htmlContainer setWantsLayer:YES];
    [htmlContainer.layer setBackgroundColor:[NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0].CGColor];
    
    // Toolbar Elements
    NSView* htmlToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, contentFrame.size.height - 35, contentFrame.size.width, 35)];
    [htmlToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [htmlToolbar setWantsLayer:YES];
    [htmlToolbar.layer setBackgroundColor:[NSColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0].CGColor];
    [htmlToolbar.layer setBorderWidth:0.5];
    [htmlToolbar.layer setBorderColor:[NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor];
    
    NSButton* htmlRefreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 6, 100, 23)];
    [htmlRefreshButton setTitle:@"Refresh HTML"];
    [htmlRefreshButton setTarget:self];
    [htmlRefreshButton setAction:@selector(showFormattedHTMLSource)];
    [htmlRefreshButton setBezelStyle:NSBezelStyleRounded];
    [htmlRefreshButton setControlSize:NSControlSizeSmall];
    [htmlRefreshButton setWantsLayer:YES];
    [htmlRefreshButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor];
    [htmlRefreshButton.layer setCornerRadius:3];
    
    [htmlToolbar addSubview:htmlRefreshButton];
    
    NSScrollView* htmlScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, contentFrame.size.width, contentFrame.size.height - 35)];
    [htmlScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [htmlScrollView setHasVerticalScroller:YES];
    [htmlScrollView setBorderType:NSNoBorder];
    [htmlScrollView setDrawsBackground:YES];
    [htmlScrollView setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    
    self.htmlSource = [[NSTextView alloc] initWithFrame:[[htmlScrollView contentView] bounds]];
    // TEMA SCURO PER HTML SOURCE
    [self.htmlSource setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    [self.htmlSource setTextColor:[NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    [self.htmlSource setInsertionPointColor:[NSColor whiteColor]];
    [self.htmlSource setFont:[NSFont fontWithName:@"Monaco" size:11] ?: [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    [self.htmlSource setEditable:NO];
    [self.htmlSource setSelectable:YES];
    [self.htmlSource setString:@"📄 HTML Source will appear here...\n\nClick 'Refresh HTML' button to load current page HTML"];
    
    [htmlScrollView setDocumentView:self.htmlSource];
    [htmlContainer addSubview:htmlScrollView];
    [htmlContainer addSubview:htmlToolbar];
    [htmlTab setView:htmlContainer];
    
    // === TAB NETWORK TEMA SCURO ===
    NSTabViewItem* networkTab = [[NSTabViewItem alloc] initWithIdentifier:@"network"];
    [networkTab setLabel:@"Network"];
    
    NSView* networkContainer = [[NSView alloc] initWithFrame:contentFrame];
    [networkContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [networkContainer setWantsLayer:YES];
    [networkContainer.layer setBackgroundColor:[NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0].CGColor];
    
    NSTextView* networkView = [[NSTextView alloc] initWithFrame:NSMakeRect(15, 15, contentFrame.size.width - 30, contentFrame.size.height - 30)];
    [networkView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    // TEMA SCURO NETWORK TAB
    [networkView setBackgroundColor:[NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0]];
    [networkView setTextColor:[NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    [networkView setFont:[NSFont systemFontOfSize:13]];
    [networkView setEditable:NO];
    [networkView setString:@"🌐 Network Activity Monitor\n"
                            "===========================\n\n"
                            "📡 HTTP Requests Monitoring\n"
                            "🔍 Headers Analysis\n"
                            "⏱️  Performance Timing\n"
                            "📊 Resource Loading\n\n"
                            "💡 Coming soon: Real-time network monitoring\n\n"
                            "🎯 This tab will show:\n"
                            "• All network requests\n"
                            "• Response times\n"
                            "• Headers and payloads\n"
                            "• Resource loading waterfall"];
    
    [networkContainer addSubview:networkView];
    [networkTab setView:networkContainer];
    
    // === AGGIUNGI TUTTI I TABS ===
    [self.tabView addTabViewItem:consoleTab];
    [self.tabView addTabViewItem:htmlTab];
    [self.tabView addTabViewItem:networkTab];
    
    // AGGIUNGI TAB VIEW ALLA FINESTRA
    [contentView addSubview:self.tabView];
    
    // FORZA REFRESH
    [self.devToolsWindow displayIfNeeded];
    [self.tabView setNeedsDisplay:YES];
    
    // Messaggi di benvenuto con colori console
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logToConsole:@"🛠️ MacBird Developer Tools - Dark Theme" withColor:[NSColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0]];
        [self logToConsole:@"================================================" withColor:[NSColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]];
        [self logToConsole:@"✅ Chrome DevTools dark theme activated" withColor:[NSColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1.0]];
        [self logToConsole:@"🎨 Professional dark color scheme" withColor:[NSColor colorWithRed:0.8 green:0.6 blue:0.2 alpha:1.0]];
        [self logToConsole:@"📱 Ready for debugging" withColor:[NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
        [self logToConsole:@"" withColor:nil];
        [self logToConsole:@"💡 TIP: Use the tabs above to navigate between tools" withColor:[NSColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
        [self logToConsole:@"🔍 TIP: Go to google.com and click Refresh to test detection" withColor:[NSColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
        [self logToConsole:@"" withColor:nil];
    });
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
            [self logToConsole:[NSString stringWithFormat:@"❌ Analysis error: %@", [error localizedDescription]]];
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
        [self logToConsole:@"❌ Error parsing analysis results"];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"=== 🔍 BROWSER ANALYSIS RESULTS ==="];
    [self logToConsole:[NSString stringWithFormat:@"📱 User Agent: %@", analysis[@"userAgent"]]];
    [self logToConsole:[NSString stringWithFormat:@"🖥️  Platform: %@", analysis[@"platform"]]];
    [self logToConsole:[NSString stringWithFormat:@"🔧 WebKit Version: %@", analysis[@"webkitVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"🌐 Safari Version: %@", analysis[@"safariVersion"]]];
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ FEATURE SUPPORT ANALYSIS ==="];
    NSDictionary* features = analysis[@"features"];
    for (NSString* feature in features) {
        BOOL supported = [features[feature] boolValue];
        NSString* status = supported ? @"✅ SUPPORTED" : @"❌ NOT SUPPORTED";
        NSString* paddedFeature = [feature stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
        [self logToConsole:[NSString stringWithFormat:@"  %@ → %@", paddedFeature, status]];
    }
    
    if (analysis[@"googleAnalysis"]) {
        [self logToConsole:@""];
        [self logToConsole:@"=== 🔍 GOOGLE PAGE DETECTION ==="];
        NSDictionary* google = analysis[@"googleAnalysis"];
        NSString* searchBoxStatus = [google[@"searchBoxFound"] boolValue] ? @"✅ FOUND" : @"❌ NOT FOUND";
        NSString* modernStatus = [google[@"modernLayout"] boolValue] ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
        
        [self logToConsole:[NSString stringWithFormat:@"  🔍 Search box detected → %@", searchBoxStatus]];
        [self logToConsole:[NSString stringWithFormat:@"  🎨 Layout type detected → %@", modernStatus]];
        [self logToConsole:[NSString stringWithFormat:@"  📐 Border radius value → %@", google[@"searchBoxBorderRadius"]]];
        
        if ([google[@"modernLayout"] boolValue]) {
            [self logToConsole:@"  🎉 Google recognizes us as MODERN browser!"];
        } else {
            [self logToConsole:@"  ⚠️  Google serves us OLD layout - needs investigation"];
        }
    }
    
    NSDictionary* screen = analysis[@"screenInfo"];
    [self logToConsole:@""];
    [self logToConsole:@"=== 📱 DEVICE & DISPLAY INFO ==="];
    [self logToConsole:[NSString stringWithFormat:@"  📺 Screen Resolution → %@x%@", screen[@"width"], screen[@"height"]]];
    [self logToConsole:[NSString stringWithFormat:@"  🔍 Pixel Ratio → %@x", screen[@"pixelRatio"]]];
    [self logToConsole:[NSString stringWithFormat:@"  🎨 Color Depth → %@ bits", screen[@"colorDepth"]]];
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ ANALYSIS COMPLETE ==="];
    [self logToConsole:@"💡 TIP: Check HTML tab for page source"];
    [self logToConsole:@"🔍 TIP: Go to google.com to test Google detection"];
    [self logToConsole:@""];
    
    // Auto-refresh HTML source
    [self showHTMLSource];
}

- (void)showHTMLSource {
    NSString* htmlScript = @"document.documentElement.outerHTML";
    [self.browserWindow.webView evaluateJavaScript:htmlScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            NSString* html = (NSString*)result;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.htmlSource setString:html];
            });
        }
    }];
}

- (void)showNetworkActivity {
    // Implementazione futura per network monitoring
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
        NSFont* consoleFont = [NSFont fontWithName:@"SF Mono" size:12] ?: [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
        [attributedMessage addAttribute:NSFontAttributeName value:consoleFont range:NSMakeRange(0, logMessage.length)];
        
        // Applica colore se specificato, altrimenti usa colore default
        NSColor* textColor = color ?: [NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        [attributedMessage addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, logMessage.length)];
        
        // Aggiungi al console output
        [self.consoleOutput.textStorage appendAttributedString:attributedMessage];
        
        // Scroll to bottom
        NSRange range = NSMakeRange([[self.consoleOutput string] length], 0);
        [self.consoleOutput scrollRangeToVisible:range];
    });
}

- (void)closeDevTools {
    if (self.devToolsWindow) {
        [self.devToolsWindow close];
        self.devToolsWindow = nil;
        std::cout << "🛠️ MacBird DevTools closed" << std::endl;
    }
}

- (void)clearConsole {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.consoleOutput setString:@""];
        [self logToConsole:@"🛠️ MacBird Developer Tools - Chrome-style Design"];
        [self logToConsole:@"================================================"];
        [self logToConsole:@"✅ Console cleared"];
        [self logToConsole:@""];
    });
}

- (void)showFormattedHTMLSource {
    NSString* htmlScript = @"document.documentElement.outerHTML";
    [self.browserWindow.webView evaluateJavaScript:htmlScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            NSString* html = (NSString*)result;
            dispatch_async(dispatch_get_main_queue(), ^{
                // FORMATTA L'HTML CON INDENTAZIONE COME CHROME
                NSString* formattedHTML = [self formatHTMLString:html];
                [self.htmlSource setString:formattedHTML];
                
                // AGGIUNGI SYNTAX HIGHLIGHTING BASIC
                [self applySyntaxHighlighting];
            });
        }
    }];
}

- (NSString*)formatHTMLString:(NSString*)html {
    // FORMATTAZIONE HTML INTELLIGENTE CON INDENTAZIONE
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
                    // Aggiungi contenuto con indentazione
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
            [scanner scanString:@">" intoString:nil]; // Consuma il >
            tag = [tag stringByAppendingString:@">"];
            
            // Determina se è tag di chiusura, self-closing, o apertura
            if ([tag hasPrefix:@"</"] && [tag hasSuffix:@">"]) {
                // Tag di chiusura - diminuisci indentazione
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
                // Tag self-closing - nessun cambio di indentazione
                for (NSInteger i = 0; i < indentLevel; i++) {
                    [formatted appendString:indent];
                }
                [formatted appendFormat:@"%@\n", tag];
            } else {
                // Tag di apertura - aggiungi indentazione
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
    // SYNTAX HIGHLIGHTING BASIC PER HTML
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[self.htmlSource string]];
    NSString* htmlString = [self.htmlSource string];
    
    // Colori per syntax highlighting (simili a Chrome)
    NSColor* tagColor = [NSColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0]; // Rosso per tag
    NSColor* attributeColor = [NSColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:1.0]; // Blu per attributi
    NSColor* stringColor = [NSColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]; // Verde per stringhe
    NSColor* commentColor = [NSColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]; // Grigio per commenti
    
    // Font base
    NSFont* baseFont = [NSFont fontWithName:@"Monaco" size:11];
    [attributedString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, htmlString.length)];
    
    // Evidenzia i tag HTML
    NSRegularExpression* tagRegex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:nil];
    [tagRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:tagColor range:match.range];
    }];
    
    // Evidenzia gli attributi
    NSRegularExpression* attrRegex = [NSRegularExpression regularExpressionWithPattern:@"\\s(\\w+)=\"[^\"]*\"" options:0 error:nil];
    [attrRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:attributeColor range:match.range];
    }];
    
    // Evidenzia le stringhe tra virgolette
    NSRegularExpression* stringRegex = [NSRegularExpression regularExpressionWithPattern:@"\"[^\"]*\"" options:0 error:nil];
    [stringRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:stringColor range:match.range];
    }];
    
    // Evidenzia i commenti
    NSRegularExpression* commentRegex = [NSRegularExpression regularExpressionWithPattern:@"<!--[^>]*-->" options:0 error:nil];
    [commentRegex enumerateMatchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:commentColor range:match.range];
    }];
    
    // Applica il syntax highlighting
    [[self.htmlSource textStorage] setAttributedString:attributedString];
}

@end