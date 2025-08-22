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
    [self logToConsole:@"🔍 Running simplified browser detection..."];
    
    // ✨ SCRIPT ULTRA-SEMPLIFICATO - TESTATO E FUNZIONANTE
    NSString* detectionScript = @"navigator.userAgent";
    
    [self.browserWindow.webView evaluateJavaScript:detectionScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Basic test failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        } else if (result) {
            [self logToConsole:@"✅ JavaScript is working!" withColor:[DevToolsStyles successTextColor]];
            [self logToConsole:[NSString stringWithFormat:@"📱 User Agent: %@", (NSString*)result]];
            
            // Ora che sappiamo che funziona, proviamo uno script più complesso
            [self runCompleteAnalysis];
        } else {
            [self logToConsole:@"⚠️ No result returned" withColor:[DevToolsStyles warningTextColor]];
        }
    }];
}

- (void)runCompleteAnalysis {
    [self logToConsole:@"🔧 Running complete analysis..."];
    
    // ✨ SCRIPT STEP BY STEP - UNA COSA ALLA VOLTA
    NSString* stepByStepScript = @""
        "var result = {}; "
        "result.userAgent = navigator.userAgent; "
        "result.platform = navigator.platform; "
        "result.webkitVersion = navigator.userAgent.match(/WebKit\\/([0-9.]+)/) ? navigator.userAgent.match(/WebKit\\/([0-9.]+)/)[1] : 'unknown'; "
        "result.macBirdVersion = navigator.userAgent.match(/MacBird\\/([0-9.]+)/) ? navigator.userAgent.match(/MacBird\\/([0-9.]+)/)[1] : 'unknown'; "
        "result.currentURL = window.location.href; "
        "result.pageTitle = document.title; "
        "JSON.stringify(result);";
    
    [self.browserWindow.webView evaluateJavaScript:stepByStepScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Step analysis failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        } else if (result) {
            [self displayBasicResults:(NSString*)result];
            
            // Se questo funziona, proviamo Google detection
            [self runGoogleDetection];
        }
    }];
}

- (void)runGoogleDetection {
    [self logToConsole:@"🔍 Testing Google detection..."];
    
    NSString* googleScript = @""
        "if (window.location.hostname.includes('google')) { "
        "  var searchBox = document.querySelector('input[name=q]') || document.querySelector('.gLFyf'); "
        "  var result = {}; "
        "  result.onGoogle = true; "
        "  result.searchBoxFound = !!searchBox; "
        "  if (searchBox) { "
        "    var styles = getComputedStyle(searchBox); "
        "    result.borderRadius = styles.borderRadius; "
        "    result.padding = styles.padding; "
        "    result.isModern = styles.borderRadius !== '0px'; "
        "  } "
        "  JSON.stringify(result); "
        "} else { "
        "  JSON.stringify({onGoogle: false}); "
        "}";
    
    [self.browserWindow.webView evaluateJavaScript:googleScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Google detection failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        } else if (result) {
            [self displayGoogleResults:(NSString*)result];
        }
    }];
}

- (void)displayBasicResults:(NSString*)jsonResult {
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* analysis = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ JSON parsing error" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"=== 🔍 BASIC BROWSER INFO ===" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"🔧 WebKit: %@", analysis[@"webkitVersion"]]];
    
    NSString* macBirdVersion = analysis[@"macBirdVersion"];
    if (macBirdVersion && ![macBirdVersion isEqualToString:@"unknown"]) {
        [self logToConsole:[NSString stringWithFormat:@"🐦 MacBird: %@", macBirdVersion] withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@"✅ MacBird identity: WORKING" withColor:[DevToolsStyles successTextColor]];
    } else {
        [self logToConsole:@"⚠️ MacBird identity: NOT DETECTED" withColor:[DevToolsStyles warningTextColor]];
    }
    
    [self logToConsole:[NSString stringWithFormat:@"🌍 URL: %@", analysis[@"currentURL"]]];
    [self logToConsole:[NSString stringWithFormat:@"📄 Title: %@", analysis[@"pageTitle"]]];
}

- (void)displayGoogleResults:(NSString*)jsonResult {
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* google = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ Google JSON parsing error" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    if ([google[@"onGoogle"] boolValue]) {
        [self logToConsole:@"=== 🔍 GOOGLE DETECTION ===" withColor:[DevToolsStyles accentTextColor]];
        
        BOOL searchBoxFound = [google[@"searchBoxFound"] boolValue];
        [self logToConsole:[NSString stringWithFormat:@"🔍 Search box: %@", searchBoxFound ? @"✅ FOUND" : @"❌ NOT FOUND"]];
        
        if (searchBoxFound) {
            [self logToConsole:[NSString stringWithFormat:@"📐 Border radius: %@", google[@"borderRadius"]]];
            [self logToConsole:[NSString stringWithFormat:@"📏 Padding: %@", google[@"padding"]]];
            
            BOOL isModern = [google[@"isModern"] boolValue];
            NSString* status = isModern ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
            NSColor* color = isModern ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
            [self logToConsole:[NSString stringWithFormat:@"🎨 Layout: %@", status] withColor:color];
            
            if (isModern) {
                [self logToConsole:@"🎉 GOOGLE RECOGNIZES MACBIRD AS MODERN!" withColor:[DevToolsStyles successTextColor]];
            }
        }
    } else {
        [self logToConsole:@"ℹ️ Not on Google - no detection needed"];
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ DETECTION COMPLETE ===" withColor:[DevToolsStyles successTextColor]];
}

- (void)displayOptimizedResults:(NSString*)analysisJSON {
    NSData* jsonData = [analysisJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* analysis = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ Error parsing analysis results" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"=== 🔍 MACBIRD BROWSER STATUS ===" withColor:[DevToolsStyles accentTextColor]];
    
    // ✨ MACBIRD IDENTITY CHECK
    NSString* macBirdVersion = analysis[@"macBirdVersion"];
    if (macBirdVersion && ![macBirdVersion isEqualToString:@"unknown"]) {
        [self logToConsole:[NSString stringWithFormat:@"🐦 MacBird Version: %@", macBirdVersion] withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@"✅ MacBird identity system: WORKING" withColor:[DevToolsStyles successTextColor]];
    } else {
        [self logToConsole:@"⚠️ MacBird version: NOT DETECTED" withColor:[DevToolsStyles warningTextColor]];
    }
    
    [self logToConsole:[NSString stringWithFormat:@"🔧 WebKit: %@", analysis[@"webkitVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"🌐 Safari: %@", analysis[@"safariVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"🌍 Current URL: %@", analysis[@"currentURL"]]];
    [self logToConsole:[NSString stringWithFormat:@"📄 Page Title: %@", analysis[@"pageTitle"]]];
    
    // ✨ FEATURE SUMMARY (SIMPLIFIED)
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ BROWSER CAPABILITIES ===" withColor:[DevToolsStyles accentTextColor]];
    NSDictionary* features = analysis[@"features"];
    NSInteger supportedCount = 0;
    NSInteger totalCount = [features count];
    
    for (NSString* feature in features) {
        if ([features[feature] boolValue]) {
            supportedCount++;
        }
    }
    
    CGFloat percentage = (CGFloat)supportedCount / totalCount * 100;
    NSColor* capabilityColor = percentage >= 80 ? [DevToolsStyles successTextColor] : 
                              percentage >= 60 ? [DevToolsStyles warningTextColor] : 
                                               [DevToolsStyles errorTextColor];
    
    [self logToConsole:[NSString stringWithFormat:@"📊 Modern features supported: %ld/%ld (%.0f%%)", (long)supportedCount, (long)totalCount, percentage] withColor:capabilityColor];
    
    // Show key features
    NSArray* keyFeatures = @[@"cssGrid", @"cssFlexbox", @"webGL", @"fetchAPI", @"serviceWorker"];
    for (NSString* feature in keyFeatures) {
        BOOL supported = [features[feature] boolValue];
        NSString* status = supported ? @"✅" : @"❌";
        [self logToConsole:[NSString stringWithFormat:@"  %@ %@", status, feature]];
    }
    
    // ✨ GOOGLE DETECTION RESULTS
    if (analysis[@"googleAnalysis"]) {
        [self logToConsole:@""];
        [self logToConsole:@"=== 🔍 GOOGLE RECOGNITION TEST ===" withColor:[DevToolsStyles accentTextColor]];
        NSDictionary* google = analysis[@"googleAnalysis"];
        
        BOOL isModern = [google[@"modernLayout"] boolValue];
        NSString* modernStatus = isModern ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
        NSColor* modernColor = isModern ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
        
        [self logToConsole:[NSString stringWithFormat:@"🎨 Layout detected: %@", modernStatus] withColor:modernColor];
        [self logToConsole:[NSString stringWithFormat:@"🎯 Detection confidence: %@", google[@"confidence"]]];
        [self logToConsole:[NSString stringWithFormat:@"📊 Modern score: %@/%@", google[@"modernScore"], google[@"maxScore"]]];
        [self logToConsole:[NSString stringWithFormat:@"📄 Page type: %@", google[@"pageType"]]];
        
        // Technical details
        if (google[@"details"]) {
            NSDictionary* details = google[@"details"];
            [self logToConsole:[NSString stringWithFormat:@"📐 Search box border-radius: %@", details[@"borderRadius"]]];
            [self logToConsole:[NSString stringWithFormat:@"📏 Search box padding: %@", details[@"padding"]]];
        }
        
        // Final verdict
        [self logToConsole:@""];
        if (isModern) {
            [self logToConsole:@"🎉 VERDICT: Google serves MacBird MODERN layout!" withColor:[DevToolsStyles successTextColor]];
            [self logToConsole:@"✨ MacBird browser identity: SUCCESSFUL" withColor:[DevToolsStyles successTextColor]];
        } else {
            [self logToConsole:@"⚠️ VERDICT: Google serves OLD layout" withColor:[DevToolsStyles warningTextColor]];
            [self logToConsole:@"🔍 This might need further investigation" withColor:[DevToolsStyles warningTextColor]];
        }
    }
    
    // ✨ OVERALL BROWSER HEALTH
    [self logToConsole:@""];
    [self logToConsole:@"=== 📊 MACBIRD HEALTH STATUS ===" withColor:[DevToolsStyles accentTextColor]];
    
    BOOL hasIdentity = macBirdVersion && ![macBirdVersion isEqualToString:@"unknown"];
    BOOL hasGoodFeatures = percentage >= 80;
    BOOL hasModernGoogle = analysis[@"googleAnalysis"] && [analysis[@"googleAnalysis"][@"modernLayout"] boolValue];
    
    NSInteger healthScore = (hasIdentity ? 1 : 0) + (hasGoodFeatures ? 1 : 0) + (hasModernGoogle ? 1 : 0);
    
    NSString* healthStatus;
    NSColor* healthColor;
    switch (healthScore) {
        case 3:
            healthStatus = @"🟢 EXCELLENT";
            healthColor = [DevToolsStyles successTextColor];
            break;
        case 2:
            healthStatus = @"🟡 GOOD";
            healthColor = [DevToolsStyles warningTextColor];
            break;
        default:
            healthStatus = @"🔴 NEEDS WORK";
            healthColor = [DevToolsStyles errorTextColor];
            break;
    }
    
    [self logToConsole:[NSString stringWithFormat:@"🏥 Browser health: %@", healthStatus] withColor:healthColor];
    [self logToConsole:[NSString stringWithFormat:@"📈 Health score: %ld/3", (long)healthScore]];
    
    [self logToConsole:@""];
    [self logToConsole:@"=== ✅ ANALYSIS COMPLETE ===" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@""];
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