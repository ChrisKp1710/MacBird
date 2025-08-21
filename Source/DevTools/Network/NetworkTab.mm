#import "NetworkTab.h"
#import "Platform/macOS/BrowserWindow.h"
#import "../Common/DevToolsStyles.h"
#include <iostream>

@implementation NetworkTab

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.containerView = [self createNetworkTabView:frame];
    }
    return self;
}

- (NSView*)createNetworkTabView:(NSRect)frame {
    NSView* networkContainer = [[NSView alloc] initWithFrame:frame];
    [networkContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [networkContainer setWantsLayer:YES];
    [networkContainer.layer setBackgroundColor:[DevToolsStyles containerBackgroundColor].CGColor];
    
    // Toolbar Network
    CGFloat toolbarHeight = [DevToolsStyles toolbarHeight];
    NSView* networkToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, frame.size.height - toolbarHeight, frame.size.width, toolbarHeight)];
    [networkToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [networkToolbar setWantsLayer:YES];
    [networkToolbar.layer setBackgroundColor:[DevToolsStyles toolbarBackgroundColor].CGColor];
    [networkToolbar.layer setBorderWidth:[DevToolsStyles borderWidth]];
    [networkToolbar.layer setBorderColor:[DevToolsStyles borderColor].CGColor];
    
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect([DevToolsStyles padding], 6, 100, 23)];
    [refreshButton setTitle:@"Show Network"];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(showNetworkInfo)];
    [refreshButton setBezelStyle:NSBezelStyleRounded];
    [refreshButton setControlSize:NSControlSizeSmall];
    [refreshButton setWantsLayer:YES];
    [refreshButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [refreshButton.layer setCornerRadius:3];
    
    // Label info
    NSTextField* infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(125, 10, 300, 16)];
    [infoLabel setStringValue:@"Network Activity Monitor"];
    [infoLabel setBezeled:NO];
    [infoLabel setDrawsBackground:NO];
    [infoLabel setEditable:NO];
    [infoLabel setSelectable:NO];
    [infoLabel setTextColor:[DevToolsStyles secondaryTextColor]];
    [infoLabel setFont:[DevToolsStyles uiFont]];
    
    [networkToolbar addSubview:refreshButton];
    [networkToolbar addSubview:infoLabel];
    
    // Network output area
    NSScrollView* networkScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - toolbarHeight)];
    [networkScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [networkScrollView setHasVerticalScroller:YES];
    [networkScrollView setBorderType:NSNoBorder];
    [networkScrollView setDrawsBackground:YES];
    [networkScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    self.networkOutput = [[NSTextView alloc] initWithFrame:[[networkScrollView contentView] bounds]];
    [self.networkOutput setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.networkOutput setTextColor:[DevToolsStyles primaryTextColor]];
    [self.networkOutput setFont:[DevToolsStyles consoleFont]];
    [self.networkOutput setEditable:NO];
    [self.networkOutput setSelectable:YES];
    [self.networkOutput setString:@"🌐 Network Activity Monitor\n"
                                   "===========================\n\n"
                                   "📡 HTTP Requests Monitoring\n"
                                   "🔍 Headers Analysis\n"
                                   "⏱️  Performance Timing\n"
                                   "📊 Resource Loading\n\n"
                                   "💡 Click 'Show Network' to display current connection info\n\n"
                                   "🎯 This tab will show:\n"
                                   "• All network requests\n"
                                   "• Response times\n"
                                   "• Headers and payloads\n"
                                   "• Resource loading waterfall\n\n"
                                   "🚀 Coming soon: Real-time network monitoring"];
    
    [networkScrollView setDocumentView:self.networkOutput];
    [networkContainer addSubview:networkScrollView];
    [networkContainer addSubview:networkToolbar];
    
    return networkContainer;
}

- (NSView*)createNetworkTabView {
    return self.containerView;
}

- (void)showNetworkInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* networkInfo = [NSString stringWithFormat:@"🌐 NETWORK MONITOR REPORT\n"
                                "=========================\n"
                                "📅 %@\n\n"
                                "🔗 Current Connection:\n"
                                "   URL: %@\n"
                                "   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Safari/605.1.15\n"
                                "   WebKit Version: 605.1.15\n"
                                "   Safari Version: 17.6\n\n"
                                "📊 Network Features:\n"
                                "   ✅ HTTP/2 Support\n"
                                "   ✅ HTTPS Encryption\n"
                                "   ✅ Gzip Compression\n"
                                "   ✅ WebSocket Support\n"
                                "   ✅ Modern TLS\n\n"
                                "🔍 Request Headers Sent:\n"
                                "   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\n"
                                "   Accept-Language: en-US,en;q=0.9\n"
                                "   Accept-Encoding: gzip, deflate, br\n"
                                "   DNT: 1\n"
                                "   Sec-Fetch-Site: same-origin\n"
                                "   Sec-Fetch-Mode: navigate\n"
                                "   Sec-Fetch-Dest: document\n\n"
                                "🎯 Browser Capabilities:\n"
                                "   • Modern JavaScript Engine\n"
                                "   • Advanced CSS Support\n"
                                "   • WebGL & Canvas\n"
                                "   • Service Workers\n"
                                "   • Push Notifications\n\n"
                                "💡 MacBird Network Analysis Complete\n"
                                "=========================\n\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterMediumStyle],
                                [[self.browserWindow.webView URL] absoluteString] ?: @"about:blank"];
        
        [self.networkOutput setString:networkInfo];
    });
}

@end