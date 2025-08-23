#import "ConsoleTab.h"
#import "Platform/macOS/BrowserWindow.h"
#import "UI/TabSystem/TabManager.h"  // ✨ Import completo invece di forward declaration
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
    
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(80, 6, 80, 23)];
    [refreshButton setTitle:@"🕵️ Detective"];
    [refreshButton setBezelStyle:NSBezelStyleRounded];
    [clearButton setControlSize:NSControlSizeSmall];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(runDetectionAnalysis)];
    [refreshButton setWantsLayer:YES];
    [refreshButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [refreshButton.layer setCornerRadius:3];
    
    // Label con testo chiaro su sfondo scuro
    NSTextField* infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(175, 10, 300, 16)];
    [infoLabel setStringValue:@"MacBird Detective Console - Professional Analysis"];
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
        [self logToConsole:@"🕵️ MacBird Detective Console - Professional Analysis" withColor:[DevToolsStyles accentTextColor]];
        [self logToConsole:@"========================================================" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"✅ Professional detective system loaded" withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@"🎨 Chrome DevTools dark theme applied" withColor:[DevToolsStyles warningTextColor]];
        [self logToConsole:@"🔍 Ready for comprehensive browser analysis" withColor:[DevToolsStyles primaryTextColor]];
        [self logToConsole:@"" withColor:nil];
        [self logToConsole:@"💡 TIP: Click '🕵️ Detective' for full Google recognition analysis" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"🎯 TIP: Go to google.com first, then run detective analysis" withColor:[DevToolsStyles secondaryTextColor]];
        [self logToConsole:@"" withColor:nil];
    });
    
    return consoleContainer;
}

- (NSView*)createConsoleTabView {
    // Metodo wrapper per compatibilità
    return self.containerView;
}

- (void)runDetectionAnalysis {
    [self logToConsole:@"🕵️ Starting MacBird Detective Analysis..." withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:@"================================================" withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ SCRIPT DETECTIVE SEMPLIFICATO - SENZA MESSAGE HANDLERS
    NSString* simplifiedDetectionScript = @""
    "try {"
    "  console.log('🕵️ Detective: Starting analysis on ' + window.location.hostname);"
    "  var macBirdDetective = {"
    "    identity: {"
    "      userAgent: navigator.userAgent,"
    "      vendor: navigator.vendor,"
    "      platform: navigator.platform,"
    "      language: navigator.language,"
    "      cookieEnabled: navigator.cookieEnabled,"
    "      onLine: navigator.onLine"
    "    },"
    "    macbird: {"
    "      detected: navigator.userAgent.includes('MacBird'),"
    "      version: navigator.userAgent.match(/MacBird\\/(\\d+\\.\\d+\\.\\d+)/) ? navigator.userAgent.match(/MacBird\\/(\\d+\\.\\d+\\.\\d+)/)[1] : 'unknown',"
    "      position: navigator.userAgent.indexOf('MacBird'),"
    "      beforeSafari: navigator.userAgent.indexOf('MacBird') < navigator.userAgent.indexOf('Safari'),"
    "      hasAPI: typeof window.macBird !== 'undefined',"
    "      apiVersion: typeof window.macBird !== 'undefined' ? window.macBird.version : 'none'"
    "    },"
    "    webkit: {"
    "      version: navigator.userAgent.match(/WebKit\\/(\\d+\\.\\d+\\.\\d+)/) ? navigator.userAgent.match(/WebKit\\/(\\d+\\.\\d+\\.\\d+)/)[1] : 'unknown',"
    "      safari: navigator.userAgent.match(/Version\\/(\\d+\\.\\d+\\.?\\d*)/) ? navigator.userAgent.match(/Version\\/(\\d+\\.\\d+\\.?\\d*)/)[1] : 'unknown'"
    "    },"
    "    google: {"
    "      onGoogle: window.location.hostname.includes('google'),"
    "      searchBox: null,"
    "      modernLayout: false,"
    "      layoutScore: 0,"
    "      features: {"
    "        searchBox: false,"
    "        modernRadius: false,"
    "        flexLayout: false,"
    "        advancedControls: false"
    "      },"
    "      details: {}"
    "    },"
    "    features: {"
    "      webgl: !!window.WebGLRenderingContext,"
    "      webgl2: !!window.WebGL2RenderingContext,"
    "      serviceWorker: 'serviceWorker' in navigator,"
    "      pushAPI: 'PushManager' in window,"
    "      notifications: 'Notification' in window,"
    "      geolocation: 'geolocation' in navigator,"
    "      websockets: 'WebSocket' in window,"
    "      localStorage: 'localStorage' in window,"
    "      sessionStorage: 'sessionStorage' in window,"
    "      indexedDB: 'indexedDB' in window,"
    "      cssSupports: !!(window.CSS && window.CSS.supports),"
    "      cssGrid: window.CSS && window.CSS.supports ? window.CSS.supports('display', 'grid') : false,"
    "      flexbox: window.CSS && window.CSS.supports ? window.CSS.supports('display', 'flex') : false,"
    "      backdropFilter: window.CSS && window.CSS.supports ? window.CSS.supports('backdrop-filter', 'blur(10px)') : false"
    "    }"
    "  };"
    "  console.log('🕵️ Detective: Checking Google layout...');"
    "  if (macBirdDetective.google.onGoogle) {"
    "    var searchBox = document.querySelector('input[name=\"q\"]') || document.querySelector('.gLFyf') || document.querySelector('textarea[name=\"q\"]');"
    "    console.log('🕵️ Detective: Search box found: ' + !!searchBox);"
    "    macBirdDetective.google.searchBox = searchBox;"
    "    if (searchBox) {"
    "      console.log('🕵️ Detective: Getting styles for search box');"
    "      var styles = getComputedStyle(searchBox);"
    "      var borderRadius = styles.borderRadius || '0px';"
    "      var padding = styles.padding || '0px';"
    "      var display = styles.display || 'block';"
    "      var boxShadow = styles.boxShadow || 'none';"
    "      macBirdDetective.google.features.searchBox = true;"
    "      macBirdDetective.google.features.modernRadius = borderRadius !== '0px';"
    "      macBirdDetective.google.features.flexLayout = display.includes('flex');"
    "      macBirdDetective.google.features.advancedControls = !!document.querySelector('.UUbT9');"
    "      macBirdDetective.google.details = {"
    "        borderRadius: borderRadius,"
    "        padding: padding,"
    "        display: display,"
    "        boxShadow: boxShadow,"
    "        width: styles.width,"
    "        height: styles.height"
    "      };"
    "      var score = 0;"
    "      if (borderRadius !== '0px') score += 30;"
    "      if (boxShadow !== 'none') score += 20;"
    "      if (display.includes('flex')) score += 15;"
    "      if (parseInt(styles.fontSize) >= 14) score += 10;"
    "      if (!!document.querySelector('.UUbT9')) score += 25;"
    "      macBirdDetective.google.layoutScore = score;"
    "      macBirdDetective.google.modernLayout = score >= 50;"
    "    }"
    "  }"
    "  console.log('🕵️ Detective: Analysis complete, returning JSON');"
    "  JSON.stringify(macBirdDetective, null, 2);"
    "} catch (e) {"
    "  console.error('🕵️ Detective: JS Error: ' + e.message);"
    "  throw e;"
    "}";

    [self.browserWindow.tabManager.activeTab.webView evaluateJavaScript:simplifiedDetectionScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Detective analysis failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
            
            // ✨ FALLBACK: Prova analisi di base se quella completa fallisce
            [self runBasicAnalysis];
        } else if (result) {
            [self displayAdvancedDetectionResults:(NSString*)result];
        } else {
            [self logToConsole:@"⚠️ No detection results returned" withColor:[DevToolsStyles warningTextColor]];
            [self runBasicAnalysis];
        }
    }];
}

- (void)runBasicAnalysis {
    [self logToConsole:@"🔧 Running simplified analysis..." withColor:[DevToolsStyles warningTextColor]];
    
    // ✨ ANALISI DI BASE SEMPLIFICATA
    NSString* basicScript = @""
        "var result = {}; "
        "result.userAgent = navigator.userAgent; "
        "result.platform = navigator.platform; "
        "result.macBirdDetected = navigator.userAgent.includes('MacBird'); "
        "result.macBirdVersion = navigator.userAgent.match(/MacBird\\/(\\d+\\.\\d+\\.\\d+)/) ? navigator.userAgent.match(/MacBird\\/(\\d+\\.\\d+\\.\\d+)/)[1] : 'unknown'; "
        "result.webkitVersion = navigator.userAgent.match(/WebKit\\/(\\d+\\.\\d+\\.\\d+)/) ? navigator.userAgent.match(/WebKit\\/(\\d+\\.\\d+\\.\\d+)/)[1] : 'unknown'; "
        "result.onGoogle = window.location.hostname.includes('google'); "
        "result.currentURL = window.location.href; "
        "result.pageTitle = document.title; "
        "if (result.onGoogle) {"
        "  var searchBox = document.querySelector('input[name=q]') || document.querySelector('.gLFyf'); "
        "  result.googleSearchBox = !!searchBox; "
        "  if (searchBox) {"
        "    var styles = getComputedStyle(searchBox); "
        "    result.googleModern = styles.borderRadius !== '0px'; "
        "    result.googleBorderRadius = styles.borderRadius; "
        "  }"
        "}"
        "JSON.stringify(result);";
    
    [self.browserWindow.tabManager.activeTab.webView evaluateJavaScript:basicScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Basic analysis also failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        } else if (result) {
            [self displayBasicAnalysisResults:(NSString*)result];
        }
    }];
}

- (void)displayBasicAnalysisResults:(NSString*)jsonResult {
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* analysis = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ JSON parsing error" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🔍 ===== BASIC DETECTIVE REPORT =====" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:@""];
    
    // MacBird Detection
    BOOL macBirdDetected = [analysis[@"macBirdDetected"] boolValue];
    if (macBirdDetected) {
        [self logToConsole:[NSString stringWithFormat:@"🐦 MacBird: ✅ DETECTED (v%@)", analysis[@"macBirdVersion"]] withColor:[DevToolsStyles successTextColor]];
    } else {
        [self logToConsole:@"🐦 MacBird: ❌ NOT DETECTED" withColor:[DevToolsStyles errorTextColor]];
    }
    
    // Engine Info
    [self logToConsole:[NSString stringWithFormat:@"🔧 WebKit: %@", analysis[@"webkitVersion"]]];
    [self logToConsole:[NSString stringWithFormat:@"🖥️  Platform: %@", analysis[@"platform"]]];
    
    // Current Page
    [self logToConsole:@""];
    [self logToConsole:[NSString stringWithFormat:@"🌍 URL: %@", analysis[@"currentURL"]]];
    [self logToConsole:[NSString stringWithFormat:@"📄 Title: %@", analysis[@"pageTitle"]]];
    
    // Google Analysis
    BOOL onGoogle = [analysis[@"onGoogle"] boolValue];
    if (onGoogle) {
        [self logToConsole:@""];
        [self logToConsole:@"🔍 GOOGLE ANALYSIS:" withColor:[DevToolsStyles accentTextColor]];
        
        BOOL googleSearchBox = [analysis[@"googleSearchBox"] boolValue];
        [self logToConsole:[NSString stringWithFormat:@"   Search Box: %@", googleSearchBox ? @"✅ FOUND" : @"❌ NOT FOUND"]];
        
        if (googleSearchBox && analysis[@"googleModern"]) {
            BOOL isModern = [analysis[@"googleModern"] boolValue];
            NSString* status = isModern ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
            NSColor* color = isModern ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
            [self logToConsole:[NSString stringWithFormat:@"   Layout: %@", status] withColor:color];
            [self logToConsole:[NSString stringWithFormat:@"   Border Radius: %@", analysis[@"googleBorderRadius"]]];
            
            if (isModern) {
                [self logToConsole:@""];
                [self logToConsole:@"🎉 GOOGLE RECOGNIZES MACBIRD AS MODERN!" withColor:[DevToolsStyles successTextColor]];
            }
        }
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🔍 ===== BASIC ANALYSIS COMPLETE =====" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@"💡 Simplified analysis completed successfully!" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@""];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"consoleLog"]) {
        [self logToConsole:[NSString stringWithFormat:@"%@", message.body] withColor:[DevToolsStyles secondaryTextColor]];
    }
}

- (void)displayAdvancedDetectionResults:(NSString*)jsonResult {
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* detective = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        [self logToConsole:@"❌ Detective JSON parsing error" withColor:[DevToolsStyles errorTextColor]];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🕵️ ===== MACBIRD DETECTIVE REPORT =====" withColor:[DevToolsStyles accentTextColor]];
    
    // ✨ MACBIRD IDENTITY ANALYSIS
    NSDictionary* macbird = detective[@"macbird"];
    [self logToConsole:@""];
    [self logToConsole:@"🐦 MACBIRD IDENTITY STATUS:" withColor:[DevToolsStyles accentTextColor]];
    
    BOOL detected = [macbird[@"detected"] boolValue];
    NSString* detectionStatus = detected ? @"✅ DETECTED" : @"❌ NOT DETECTED";
    NSColor* detectionColor = detected ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
    [self logToConsole:[NSString stringWithFormat:@"   Detection: %@", detectionStatus] withColor:detectionColor];
    
    if (detected) {
        [self logToConsole:[NSString stringWithFormat:@"   Version: %@", macbird[@"version"]] withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:[NSString stringWithFormat:@"   Position: Character %@", macbird[@"position"]]];
        
        BOOL beforeSafari = [macbird[@"beforeSafari"] boolValue];
        NSString* positionStatus = beforeSafari ? @"✅ BEFORE Safari (Prominent)" : @"⚠️ AFTER Safari";
        NSColor* positionColor = beforeSafari ? [DevToolsStyles successTextColor] : [DevToolsStyles warningTextColor];
        [self logToConsole:[NSString stringWithFormat:@"   Priority: %@", positionStatus] withColor:positionColor];
        
        BOOL hasAPI = [macbird[@"hasAPI"] boolValue];
        NSString* apiStatus = hasAPI ? @"✅ AVAILABLE" : @"❌ MISSING";
        [self logToConsole:[NSString stringWithFormat:@"   API: %@", apiStatus] withColor:hasAPI ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor]];
    }
    
    // ✨ WEBKIT/SAFARI ANALYSIS
    NSDictionary* webkit = detective[@"webkit"];
    [self logToConsole:@""];
    [self logToConsole:@"🔧 ENGINE COMPATIBILITY:" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"   WebKit: %@", webkit[@"version"]]];
    [self logToConsole:[NSString stringWithFormat:@"   Safari: %@", webkit[@"safari"]]];
    
    // ✨ GOOGLE LAYOUT DETECTION (DETAILED)
    NSDictionary* google = detective[@"google"];
    BOOL onGoogle = [google[@"onGoogle"] boolValue];
    
    BOOL modernLayout = NO;
    NSInteger layoutScore = 0;
    
    [self logToConsole:@""];
    if (onGoogle) {
        [self logToConsole:@"🔍 GOOGLE RECOGNITION ANALYSIS:" withColor:[DevToolsStyles accentTextColor]];
        
        modernLayout = [google[@"modernLayout"] boolValue];
        layoutScore = [google[@"layoutScore"] integerValue];
        
        NSString* layoutStatus = modernLayout ? @"✅ MODERN LAYOUT" : @"❌ OLD LAYOUT";
        NSColor* layoutColor = modernLayout ? [DevToolsStyles successTextColor] : [DevToolsStyles errorTextColor];
        [self logToConsole:[NSString stringWithFormat:@"   Result: %@", layoutStatus] withColor:layoutColor];
        [self logToConsole:[NSString stringWithFormat:@"   Score: %ld/100 points", (long)layoutScore] withColor:layoutColor];
        
        // Detailed features analysis
        NSDictionary* features = google[@"features"];
        [self logToConsole:@"   Features Detected:"];
        [self logToConsole:[NSString stringWithFormat:@"     Search Box: %@", [features[@"searchBox"] boolValue] ? @"✅" : @"❌"]];
        [self logToConsole:[NSString stringWithFormat:@"     Modern Radius: %@", [features[@"modernRadius"] boolValue] ? @"✅" : @"❌"]];
        [self logToConsole:[NSString stringWithFormat:@"     Flex Layout: %@", [features[@"flexLayout"] boolValue] ? @"✅" : @"❌"]];
        [self logToConsole:[NSString stringWithFormat:@"     Advanced UI: %@", [features[@"advancedControls"] boolValue] ? @"✅" : @"❌"]];
        
        // Technical details
        NSDictionary* details = google[@"details"];
        if (details && [details count] > 0) {
            [self logToConsole:@"   Technical Details:"];
            [self logToConsole:[NSString stringWithFormat:@"     Border-radius: %@", details[@"borderRadius"]]];
            [self logToConsole:[NSString stringWithFormat:@"     Padding: %@", details[@"padding"]]];
            [self logToConsole:[NSString stringWithFormat:@"     Box-shadow: %@", details[@"boxShadow"]]];
        }
        
        // ✨ GOOGLE'S VERDICT
        [self logToConsole:@""];
        if (modernLayout) {
            [self logToConsole:@"🎉 GOOGLE'S VERDICT: MacBird = MODERN BROWSER!" withColor:[DevToolsStyles successTextColor]];
            [self logToConsole:@"✨ You get the full Google experience!" withColor:[DevToolsStyles successTextColor]];
        } else {
            [self logToConsole:@"⚠️ GOOGLE'S VERDICT: Needs improvement" withColor:[DevToolsStyles warningTextColor]];
            [self logToConsole:@"🔍 Consider adjusting User-Agent strategy" withColor:[DevToolsStyles warningTextColor]];
        }
        
    } else {
        [self logToConsole:@"ℹ️ Not on Google - navigate to google.com to test" withColor:[DevToolsStyles secondaryTextColor]];
    }
    
    // ✨ FEATURE CAPABILITY ANALYSIS
    NSDictionary* features = detective[@"features"];
    [self logToConsole:@""];
    [self logToConsole:@"🚀 BROWSER CAPABILITIES REPORT:" withColor:[DevToolsStyles accentTextColor]];
    
    NSInteger supportedFeatures = 0;
    NSInteger totalFeatures = [features count];
    
    // Count supported features
    for (NSString* feature in features) {
        if ([features[feature] boolValue]) {
            supportedFeatures++;
        }
    }
    
    CGFloat percentage = (CGFloat)supportedFeatures / totalFeatures * 100;
    NSColor* capabilityColor = percentage >= 90 ? [DevToolsStyles successTextColor] : 
                              percentage >= 70 ? [DevToolsStyles warningTextColor] : 
                                               [DevToolsStyles errorTextColor];
    
    [self logToConsole:[NSString stringWithFormat:@"   Modern Features: %ld/%ld (%.0f%%)", (long)supportedFeatures, (long)totalFeatures, percentage] withColor:capabilityColor];
    
    // Key features breakdown
    NSArray* keyFeatures = @[@"webgl2", @"serviceWorker", @"webAssembly", @"intersectionObserver", @"cssGrid"];
    for (NSString* feature in keyFeatures) {
        BOOL supported = [features[feature] boolValue];
        NSString* status = supported ? @"✅" : @"❌";
        [self logToConsole:[NSString stringWithFormat:@"     %@ %@", status, feature]];
    }
    
    // ✨ PERFORMANCE METRICS
    NSDictionary* performance = detective[@"performance"];
    if (performance) {
        [self logToConsole:@""];
        [self logToConsole:@"⚡ PERFORMANCE ANALYSIS:" withColor:[DevToolsStyles accentTextColor]];
        
        NSDictionary* memory = performance[@"memory"];
        if (memory && ![memory isKindOfClass:[NSString class]]) {
            [self logToConsole:[NSString stringWithFormat:@"   Memory Used: %@", memory[@"used"]]];
            [self logToConsole:[NSString stringWithFormat:@"   Memory Total: %@", memory[@"total"]]];
            [self logToConsole:[NSString stringWithFormat:@"   Memory Limit: %@", memory[@"limit"]]];
        }
        
        NSDictionary* timing = performance[@"timing"];
        if (timing && ![timing isKindOfClass:[NSString class]]) {
            [self logToConsole:[NSString stringWithFormat:@"   Load Time: %@", timing[@"loadTime"]]];
            [self logToConsole:[NSString stringWithFormat:@"   DOM Ready: %@", timing[@"domReady"]]];
        }
    }
    
    // ✨ OVERALL MACBIRD HEALTH SCORE
    [self logToConsole:@""];
    [self logToConsole:@"📊 MACBIRD HEALTH ASSESSMENT:" withColor:[DevToolsStyles accentTextColor]];
    
    NSInteger healthScore = 0;
    NSMutableArray* healthFactors = [[NSMutableArray alloc] init];
    
    // Identity detection (25 points)
    if (detected) {
        healthScore += 25;
        [healthFactors addObject:@"✅ Browser Identity"];
    } else {
        [healthFactors addObject:@"❌ Browser Identity"];
    }
    
    // Modern capabilities (25 points)
    if (percentage >= 85) {
        healthScore += 25;
        [healthFactors addObject:@"✅ Modern Features"];
    } else if (percentage >= 70) {
        healthScore += 15;
        [healthFactors addObject:@"⚠️ Modern Features"];
    } else {
        [healthFactors addObject:@"❌ Modern Features"];
    }
    
    // Google recognition (25 points)
    if (onGoogle && modernLayout) {
        healthScore += 25;
        [healthFactors addObject:@"✅ Google Recognition"];
    } else if (onGoogle && !modernLayout) {
        healthScore += 10;
        [healthFactors addObject:@"⚠️ Google Recognition"];
    } else {
        [healthFactors addObject:@"? Google Recognition (Not tested)"];
    }
    
    // API availability (25 points)
    BOOL hasAPI = [macbird[@"hasAPI"] boolValue];
    if (hasAPI) {
        healthScore += 25;
        [healthFactors addObject:@"✅ MacBird API"];
    } else {
        [healthFactors addObject:@"❌ MacBird API"];
    }
    
    // Health assessment
    NSString* healthStatus;
    NSColor* healthColor;
    if (healthScore >= 85) {
        healthStatus = @"🟢 EXCELLENT";
        healthColor = [DevToolsStyles successTextColor];
    } else if (healthScore >= 70) {
        healthStatus = @"🟡 GOOD";
        healthColor = [DevToolsStyles warningTextColor];
    } else if (healthScore >= 50) {
        healthStatus = @"🟠 FAIR";
        healthColor = [DevToolsStyles warningTextColor];
    } else {
        healthStatus = @"🔴 NEEDS WORK";
        healthColor = [DevToolsStyles errorTextColor];
    }
    
    [self logToConsole:[NSString stringWithFormat:@"   Overall Score: %ld/100", (long)healthScore] withColor:healthColor];
    [self logToConsole:[NSString stringWithFormat:@"   Status: %@", healthStatus] withColor:healthColor];
    [self logToConsole:@"   Health Factors:"];
    for (NSString* factor in healthFactors) {
        [self logToConsole:[NSString stringWithFormat:@"     %@", factor]];
    }
    
    // ✨ RECOMMENDATIONS
    [self logToConsole:@""];
    [self logToConsole:@"💡 DETECTIVE RECOMMENDATIONS:" withColor:[DevToolsStyles accentTextColor]];
    
    if (!detected) {
        [self logToConsole:@"   🔧 Fix: MacBird identity injection failed" withColor:[DevToolsStyles errorTextColor]];
    }
    
    if (percentage < 85) {
        [self logToConsole:@"   🔧 Improve: Enable more modern web features" withColor:[DevToolsStyles warningTextColor]];
    }
    
    if (onGoogle && !modernLayout) {
        [self logToConsole:@"   🔧 Optimize: Adjust User-Agent for better Google compatibility" withColor:[DevToolsStyles warningTextColor]];
    }
    
    if (!hasAPI) {
        [self logToConsole:@"   🔧 Fix: MacBird JavaScript API not injected properly" withColor:[DevToolsStyles errorTextColor]];
    }
    
    if (healthScore >= 85) {
        [self logToConsole:@"   🎉 MacBird is performing excellently!" withColor:[DevToolsStyles successTextColor]];
        [self logToConsole:@"   🚀 Ready for production use!" withColor:[DevToolsStyles successTextColor]];
    }
    
    // ✨ USER AGENT ANALYSIS
    [self logToConsole:@""];
    [self logToConsole:@"🔍 USER-AGENT DETAILED ANALYSIS:" withColor:[DevToolsStyles accentTextColor]];
    NSDictionary* identity = detective[@"identity"];
    NSString* userAgent = identity[@"userAgent"];
    
    [self logToConsole:[NSString stringWithFormat:@"   Full UA: %@", userAgent]];
    [self logToConsole:@"   Breakdown:"];
    
    // Parse User-Agent components
    if ([userAgent containsString:@"MacBird"]) {
        NSRange macbirdRange = [userAgent rangeOfString:@"MacBird"];
        NSRange safariRange = [userAgent rangeOfString:@"Safari"];
        
        if (macbirdRange.location < safariRange.location) {
            [self logToConsole:@"     ✅ MacBird positioned BEFORE Safari (Optimal)" withColor:[DevToolsStyles successTextColor]];
        } else {
            [self logToConsole:@"     ⚠️ MacBird positioned AFTER Safari" withColor:[DevToolsStyles warningTextColor]];
        }
    }
    
    if ([userAgent containsString:@"WebKit"]) {
        [self logToConsole:@"     ✅ WebKit engine detected" withColor:[DevToolsStyles successTextColor]];
    }
    
    if ([userAgent containsString:@"Safari"]) {
        [self logToConsole:@"     ✅ Safari compatibility maintained" withColor:[DevToolsStyles successTextColor]];
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🕵️ ===== DETECTIVE ANALYSIS COMPLETE =====" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"💡 TIP: Test on different websites to gather more data!" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"🔍 TIP: Try YouTube, Twitter, GitHub for comprehensive testing!" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@""];
}

// ========== METODI LEGACY PER COMPATIBILITÀ ==========

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

- (void)clearConsole {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.consoleOutput setString:@""];
        [self logToConsole:@"🕵️ MacBird Detective Console - Professional Analysis" withColor:[DevToolsStyles accentTextColor]];
        [self logToConsole:@"========================================================" withColor:[DevToolsStyles secondaryTextColor]];
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