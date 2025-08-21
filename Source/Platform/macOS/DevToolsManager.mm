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
    if (self.devToolsWindow && [self.devToolsWindow isVisible]) {
        [self closeDevTools];
    } else {
        [self openDevTools];
    }
}

- (void)openDevTools {
    if (self.devToolsWindow) {
        [self.devToolsWindow makeKeyAndOrderFront:nil];
        return;
    }
    
    // Crea finestra DevTools (80% larghezza dello schermo, 400px altezza)
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    NSRect devToolsFrame = NSMakeRect(
        screenFrame.size.width * 0.1,
        100,
        screenFrame.size.width * 0.8,
        400
    );
    
    self.devToolsWindow = [[NSWindow alloc] initWithContentRect:devToolsFrame
                                                      styleMask:(NSWindowStyleMaskTitled |
                                                               NSWindowStyleMaskClosable |
                                                               NSWindowStyleMaskResizable)
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    
    [self.devToolsWindow setTitle:@"MacBird Developer Tools"];
    [self.devToolsWindow setBackgroundColor:[NSColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0]];
    
    [self setupDevToolsUI];
    [self.devToolsWindow makeKeyAndOrderFront:nil];
    
    // Auto-run detection quando si aprono i DevTools
    [self runDetectionAnalysis];
    
    std::cout << "🛠️ MacBird DevTools opened" << std::endl;
}

- (void)setupDevToolsUI {
    NSView* contentView = [self.devToolsWindow contentView];
    
    // === TAB VIEW PER ORGANIZZARE I DEVTOOLS ===
    self.tabView = [[NSTabView alloc] initWithFrame:[contentView bounds]];
    [self.tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.tabView setTabViewType:NSTopTabsBezelBorder];
    
    // === TAB CONSOLE ===
    NSTabViewItem* consoleTab = [[NSTabViewItem alloc] initWithIdentifier:@"console"];
    [consoleTab setLabel:@"Console"];
    
    NSScrollView* consoleScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 40, [contentView bounds].size.width, [contentView bounds].size.height - 40)];
    [consoleScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [consoleScrollView setHasVerticalScroller:YES];
    [consoleScrollView setBorderType:NSNoBorder];
    
    self.consoleOutput = [[NSTextView alloc] initWithFrame:[[consoleScrollView contentView] bounds]];
    [self.consoleOutput setBackgroundColor:[NSColor blackColor]];
    [self.consoleOutput setTextColor:[NSColor greenColor]];
    [self.consoleOutput setFont:[NSFont fontWithName:@"Monaco" size:11]];
    [self.consoleOutput setEditable:NO];
    [self.consoleOutput setString:@"🛠️ MacBird Developer Console\n================================\n"];
    
    [consoleScrollView setDocumentView:self.consoleOutput];
    
    // Pulsante Refresh Console
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 100, 25)];
    [refreshButton setTitle:@"Refresh"];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(runDetectionAnalysis)];
    
    NSView* consoleContainer = [[NSView alloc] initWithFrame:[contentView bounds]];
    [consoleContainer addSubview:consoleScrollView];
    [consoleContainer addSubview:refreshButton];
    [consoleTab setView:consoleContainer];
    
    // === TAB HTML SOURCE ===
    NSTabViewItem* htmlTab = [[NSTabViewItem alloc] initWithIdentifier:@"html"];
    [htmlTab setLabel:@"HTML"];
    
    NSScrollView* htmlScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 40, [contentView bounds].size.width, [contentView bounds].size.height - 40)];
    [htmlScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [htmlScrollView setHasVerticalScroller:YES];
    [htmlScrollView setBorderType:NSNoBorder];
    
    self.htmlSource = [[NSTextView alloc] initWithFrame:[[htmlScrollView contentView] bounds]];
    [self.htmlSource setBackgroundColor:[NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]];
    [self.htmlSource setTextColor:[NSColor whiteColor]];
    [self.htmlSource setFont:[NSFont fontWithName:@"Monaco" size:10]];
    [self.htmlSource setEditable:NO];
    [self.htmlSource setString:@"Loading HTML source..."];
    
    [htmlScrollView setDocumentView:self.htmlSource];
    
    // Pulsante Refresh HTML
    NSButton* htmlRefreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 100, 25)];
    [htmlRefreshButton setTitle:@"Refresh HTML"];
    [htmlRefreshButton setTarget:self];
    [htmlRefreshButton setAction:@selector(showHTMLSource)];
    
    NSView* htmlContainer = [[NSView alloc] initWithFrame:[contentView bounds]];
    [htmlContainer addSubview:htmlScrollView];
    [htmlContainer addSubview:htmlRefreshButton];
    [htmlTab setView:htmlContainer];
    
    // === TAB NETWORK ===
    NSTabViewItem* networkTab = [[NSTabViewItem alloc] initWithIdentifier:@"network"];
    [networkTab setLabel:@"Network"];
    
    NSTextView* networkView = [[NSTextView alloc] initWithFrame:[contentView bounds]];
    [networkView setBackgroundColor:[NSColor colorWithRed:0.1 green:0.1 blue:0.15 alpha:1.0]];
    [networkView setTextColor:[NSColor cyanColor]];
    [networkView setFont:[NSFont fontWithName:@"Monaco" size:11]];
    [networkView setEditable:NO];
    [networkView setString:@"🌐 Network Activity Monitor\n===========================\nMonitoring HTTP requests...\n"];
    [networkTab setView:networkView];
    
    // Aggiungi tabs al TabView
    [self.tabView addTabViewItem:consoleTab];
    [self.tabView addTabViewItem:htmlTab];
    [self.tabView addTabViewItem:networkTab];
    
    [contentView addSubview:self.tabView];
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
    
    [self logToConsole:@"\n=== 🔍 BROWSER ANALYSIS RESULTS ==="];
    [self logToConsole:[NSString stringWithFormat:@"User Agent: %@", analysis[@"userAgent"]]];
    [self logToConsole:[NSString stringWithFormat:@"Platform: %@", analysis[@"platform"]]];
    [self logToConsole:[NSString stringWithFormat:@"WebKit Version: %@", analysis[@"webkitVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"Safari Version: %@", analysis[@"safariVersion"]]];
    
    [self logToConsole:@"\n=== ✅ FEATURE SUPPORT ==="];
    NSDictionary* features = analysis[@"features"];
    for (NSString* feature in features) {
        BOOL supported = [features[feature] boolValue];
        NSString* status = supported ? @"✅ SUPPORTED" : @"❌ NOT SUPPORTED";
        [self logToConsole:[NSString stringWithFormat:@"%@: %@", feature, status]];
    }
    
    if (analysis[@"googleAnalysis"]) {
        [self logToConsole:@"\n=== 🔍 GOOGLE PAGE ANALYSIS ==="];
        NSDictionary* google = analysis[@"googleAnalysis"];
        [self logToConsole:[NSString stringWithFormat:@"Search box found: %@", [google[@"searchBoxFound"] boolValue] ? @"✅ YES" : @"❌ NO"]];
        [self logToConsole:[NSString stringWithFormat:@"Modern layout: %@", [google[@"modernLayout"] boolValue] ? @"✅ YES" : @"❌ NO"]];
        [self logToConsole:[NSString stringWithFormat:@"Border radius: %@", google[@"searchBoxBorderRadius"]]];
    }
    
    NSDictionary* screen = analysis[@"screenInfo"];
    [self logToConsole:@"\n=== 📱 DEVICE INFO ==="];
    [self logToConsole:[NSString stringWithFormat:@"Screen: %@x%@", screen[@"width"], screen[@"height"]]];
    [self logToConsole:[NSString stringWithFormat:@"Pixel Ratio: %@", screen[@"pixelRatio"]]];
    [self logToConsole:[NSString stringWithFormat:@"Color Depth: %@", screen[@"colorDepth"]]];
    
    [self logToConsole:@"\n=== ✅ ANALYSIS COMPLETE ===\n"];
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                             dateStyle:NSDateFormatterNoStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
        NSString* logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
        [self.consoleOutput.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:logMessage]];
        
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

@end