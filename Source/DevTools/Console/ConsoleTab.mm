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
    
    // ✨ ULTRA-SEMPLIFICATO: Inizia sempre dal più basilare
    [self runUltraBasicAnalysis];
}

- (void)runUltraBasicAnalysis {
    [self logToConsole:@"🔍 Running ultra-basic analysis..." withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ SCRIPT MINIMAL - SOLO NAVIGATOR INFO
    NSString* minimalScript = @""
        "try {"
        "  var result = {"
        "    userAgent: navigator.userAgent || 'unknown',"
        "    platform: navigator.platform || 'unknown',"
        "    vendor: navigator.vendor || 'unknown',"
        "    language: navigator.language || 'unknown',"
        "    url: window.location ? window.location.href : 'unknown',"
        "    title: document.title || 'unknown',"
        "    hostname: window.location ? window.location.hostname : 'unknown'"
        "  };"
        "  JSON.stringify(result);"
        "} catch(e) {"
        "  '{\"error\":\"' + e.message + '\"}';"
        "}";
    
    [self.browserWindow.tabManager.activeTab.webView evaluateJavaScript:minimalScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"❌ Ultra-basic analysis failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
            [self runManualAnalysis]; // Ultimo resort
        } else if (result && [result isKindOfClass:[NSString class]]) {
            NSString* jsonString = (NSString*)result;
            [self displayUltraBasicResults:jsonString];
        } else {
            [self logToConsole:@"⚠️ No results from ultra-basic analysis" withColor:[DevToolsStyles warningTextColor]];
            [self runManualAnalysis];
        }
    }];
}

- (void)displayUltraBasicResults:(NSString*)jsonResult {
    // ✨ MEGA-DEBUG: Log ogni singolo passo
    [self logToConsole:@"🔍 [DEBUG] displayUltraBasicResults called" withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ CONTROLLO SICUREZZA 1: Verifica che jsonResult non sia nil o vuoto
    if (!jsonResult) {
        [self logToConsole:@"❌ [DEBUG] jsonResult is nil!" withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    if ([jsonResult length] == 0) {
        [self logToConsole:@"❌ [DEBUG] jsonResult is empty string!" withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    [self logToConsole:[NSString stringWithFormat:@"📋 [DEBUG] Raw JSON length: %lu", (unsigned long)[jsonResult length]] withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ FIX WARNING: Trunca la stringa manualmente invece di usare %.100@
    NSString* preview = [jsonResult length] > 100 ? 
        [[jsonResult substringToIndex:100] stringByAppendingString:@"..."] : 
        jsonResult;
    [self logToConsole:[NSString stringWithFormat:@"📋 [DEBUG] Raw JSON preview: %@", preview] withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ CONTROLLO SICUREZZA 2: Conversione a NSData
    NSData* jsonData = nil;
    @try {
        jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
        [self logToConsole:@"✅ [DEBUG] JSON string converted to data successfully" withColor:[DevToolsStyles secondaryTextColor]];
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception in dataUsingEncoding: %@", e.reason] withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    if (!jsonData) {
        [self logToConsole:@"❌ [DEBUG] jsonData is nil after conversion!" withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    [self logToConsole:[NSString stringWithFormat:@"📋 [DEBUG] JSON data length: %lu", (unsigned long)[jsonData length]] withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ CONTROLLO SICUREZZA 3: JSON Parsing
    NSError* error = nil;
    NSDictionary* analysis = nil;
    
    @try {
        analysis = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        [self logToConsole:@"✅ [DEBUG] JSON parsing attempted" withColor:[DevToolsStyles secondaryTextColor]];
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception in JSON parsing: %@", e.reason] withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    if (error) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] JSON parsing failed: %@", [error localizedDescription]] withColor:[DevToolsStyles errorTextColor]];
        [self logToConsole:[NSString stringWithFormat:@"📋 [DEBUG] Raw result: %@", jsonResult] withColor:[DevToolsStyles secondaryTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    // ✨ CONTROLLO SICUREZZA 4: Verifica che analysis non sia nil
    if (!analysis) {
        [self logToConsole:@"❌ [DEBUG] analysis dictionary is nil!" withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    [self logToConsole:[NSString stringWithFormat:@"✅ [DEBUG] Analysis dictionary created with %lu keys", (unsigned long)[analysis count]] withColor:[DevToolsStyles successTextColor]];
    
    // ✨ CONTROLLO SICUREZZA 5: Verifica se è un dictionary
    if (![analysis isKindOfClass:[NSDictionary class]]) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] analysis is not NSDictionary! It's %@", [analysis class]] withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    // Controlla se c'è un errore nel JSON
    @try {
        id errorValue = [analysis objectForKey:@"error"];
        if (errorValue && ![errorValue isEqual:[NSNull null]]) {
            [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] JavaScript error found: %@", errorValue] withColor:[DevToolsStyles errorTextColor]];
            [self runManualAnalysis];
            return;
        }
        [self logToConsole:@"✅ [DEBUG] No error field in JSON" withColor:[DevToolsStyles secondaryTextColor]];
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception checking error field: %@", e.reason] withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🔍 ===== MACBIRD ULTRA-BASIC DETECTIVE REPORT =====" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:@""];
    
    // ✅ ESTRAZIONE SICURA DEI DATI CON CONTROLLI NIL ESTREMI
    NSString* userAgent = nil;
    NSString* platform = nil;
    NSString* vendor = nil;
    NSString* url = nil;
    NSString* title = nil;
    NSString* hostname = nil;
    
    @try {
        id userAgentValue = [analysis objectForKey:@"userAgent"];
        userAgent = (userAgentValue && ![userAgentValue isEqual:[NSNull null]]) ? [userAgentValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] UserAgent extracted: %@", userAgent] withColor:[DevToolsStyles secondaryTextColor]];
        
        id platformValue = [analysis objectForKey:@"platform"];
        platform = (platformValue && ![platformValue isEqual:[NSNull null]]) ? [platformValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] Platform extracted: %@", platform] withColor:[DevToolsStyles secondaryTextColor]];
        
        id vendorValue = [analysis objectForKey:@"vendor"];
        vendor = (vendorValue && ![vendorValue isEqual:[NSNull null]]) ? [vendorValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] Vendor extracted: %@", vendor] withColor:[DevToolsStyles secondaryTextColor]];
        
        id urlValue = [analysis objectForKey:@"url"];
        url = (urlValue && ![urlValue isEqual:[NSNull null]]) ? [urlValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] URL extracted: %@", url] withColor:[DevToolsStyles secondaryTextColor]];
        
        id titleValue = [analysis objectForKey:@"title"];
        title = (titleValue && ![titleValue isEqual:[NSNull null]]) ? [titleValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] Title extracted: %@", title] withColor:[DevToolsStyles secondaryTextColor]];
        
        id hostnameValue = [analysis objectForKey:@"hostname"];
        hostname = (hostnameValue && ![hostnameValue isEqual:[NSNull null]]) ? [hostnameValue description] : @"unknown";
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] Hostname extracted: %@", hostname] withColor:[DevToolsStyles secondaryTextColor]];
        
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception in data extraction: %@", e.reason] withColor:[DevToolsStyles errorTextColor]];
        [self runManualAnalysis];
        return;
    }
    
    // MacBird Detection con controlli sicuri
    BOOL macBirdDetected = NO;
    @try {
        macBirdDetected = userAgent && [userAgent containsString:@"MacBird"];
        [self logToConsole:[NSString stringWithFormat:@"📊 [DEBUG] MacBird detection: %@", macBirdDetected ? @"YES" : @"NO"] withColor:[DevToolsStyles secondaryTextColor]];
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception in MacBird detection: %@", e.reason] withColor:[DevToolsStyles errorTextColor]];
        macBirdDetected = NO;
    }
    
    if (macBirdDetected) {
        [self logToConsole:@"🐦 MacBird Status: ✅ DETECTED!" withColor:[DevToolsStyles successTextColor]];
    } else {
        [self logToConsole:@"🐦 MacBird Status: ❌ NOT DETECTED" withColor:[DevToolsStyles errorTextColor]];
        [self logToConsole:@"   This means MacBird identity injection failed!" withColor:[DevToolsStyles errorTextColor]];
    }
    
    // Engine Info SEMPLIFICATO
    [self logToConsole:@""];
    [self logToConsole:@"🔧 Browser Engine Info:" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"   Platform: %@", platform ?: @"unknown"]];
    [self logToConsole:[NSString stringWithFormat:@"   Vendor: %@", vendor ?: @"unknown"]];
    
    // Current Page SEMPLIFICATO
    [self logToConsole:@""];
    [self logToConsole:@"🌍 Current Page Info:" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:[NSString stringWithFormat:@"   URL: %@", url ?: @"unknown"]];
    [self logToConsole:[NSString stringWithFormat:@"   Title: %@", title ?: @"unknown"]];
    [self logToConsole:[NSString stringWithFormat:@"   Hostname: %@", hostname ?: @"unknown"]];
    
    // Overall Assessment SEMPLIFICATO
    [self logToConsole:@""];
    [self logToConsole:@"📊 Quick Assessment:" withColor:[DevToolsStyles accentTextColor]];
    
    @try {
        NSInteger score = 0;
        if (macBirdDetected) score += 50;
        if (userAgent && [userAgent containsString:@"WebKit"]) score += 20;
        if (vendor && [vendor isEqualToString:@"Apple Computer, Inc."]) score += 15;
        if (url && ![url isEqualToString:@"unknown"]) score += 15;
        
        NSString* status;
        NSColor* statusColor;
        if (score >= 85) {
            status = @"🟢 EXCELLENT";
            statusColor = [DevToolsStyles successTextColor];
        } else if (score >= 60) {
            status = @"🟡 GOOD";
            statusColor = [DevToolsStyles warningTextColor];
        } else {
            status = @"🔴 NEEDS WORK";
            statusColor = [DevToolsStyles errorTextColor];
        }
        
        [self logToConsole:[NSString stringWithFormat:@"   Overall Score: %ld/100", (long)score] withColor:statusColor];
        [self logToConsole:[NSString stringWithFormat:@"   Status: %@", status] withColor:statusColor];
    } @catch (NSException* e) {
        [self logToConsole:[NSString stringWithFormat:@"❌ [DEBUG] Exception in assessment: %@", e.reason] withColor:[DevToolsStyles warningTextColor]];
    }
    
    [self logToConsole:@""];
    [self logToConsole:@"🔍 ===== ULTRA-BASIC ANALYSIS COMPLETE =====" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@"✅ [DEBUG] displayUltraBasicResults completed successfully!" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@""];
}

- (void)tryGoogleAdvancedAnalysis {
    [self logToConsole:@"🔍 Attempting Google advanced analysis..." withColor:[DevToolsStyles secondaryTextColor]];
    
    // ✨ GOOGLE ANALYSIS ULTRA-SEMPLIFICATO
    NSString* googleScript = @""
        "try {"
        "  var searchBox = document.querySelector('input[name=q]') || document.querySelector('.gLFyf') || document.querySelector('input[type=search]');"
        "  var result = {"
        "    hasSearchBox: !!searchBox"
        "  };"
        "  if (searchBox) {"
        "    try {"
        "      var styles = getComputedStyle(searchBox);"
        "      result.borderRadius = styles.borderRadius || '0px';"
        "      result.isModern = (styles.borderRadius && styles.borderRadius !== '0px');"
        "    } catch(e) {"
        "      result.styleError = e.message;"
        "    }"
        "  }"
        "  JSON.stringify(result);"
        "} catch(e) {"
        "  '{\"error\":\"' + e.message + '\"}';"
        "}";
    
    [self.browserWindow.tabManager.activeTab.webView evaluateJavaScript:googleScript completionHandler:^(id result, NSError *error) {
        if (error) {
            [self logToConsole:[NSString stringWithFormat:@"   ⚠️ Google analysis failed: %@", [error localizedDescription]] withColor:[DevToolsStyles warningTextColor]];
        } else if (result) {
            [self displayGoogleAnalysis:(NSString*)result];
        }
    }];
}

- (void)displayGoogleAnalysis:(NSString*)jsonResult {
    NSData* jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* google = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error || google[@"error"]) {
        [self logToConsole:@"   ⚠️ Google analysis had issues, but that's okay!" withColor:[DevToolsStyles warningTextColor]];
        return;
    }
    
    BOOL hasSearchBox = [google[@"hasSearchBox"] boolValue];
    [self logToConsole:[NSString stringWithFormat:@"   Search Box: %@", hasSearchBox ? @"✅ Found" : @"❌ Not found"]];
    
    if (hasSearchBox && google[@"isModern"]) {
        BOOL isModern = [google[@"isModern"] boolValue];
        if (isModern) {
            [self logToConsole:@"   Layout: ✅ MODERN (Google recognizes MacBird!)" withColor:[DevToolsStyles successTextColor]];
            [self logToConsole:[NSString stringWithFormat:@"   Border radius: %@", google[@"borderRadius"]]];
            [self logToConsole:@""];
            [self logToConsole:@"🎉 GOOGLE VERDICT: MacBird is recognized as a MODERN browser!" withColor:[DevToolsStyles successTextColor]];
        } else {
            [self logToConsole:@"   Layout: ❌ Basic (needs improvement)" withColor:[DevToolsStyles warningTextColor]];
        }
    }
}

- (void)runManualAnalysis {
    [self logToConsole:@"🔧 Running manual analysis as last resort..." withColor:[DevToolsStyles warningTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"📋 ===== MANUAL DETECTIVE REPORT =====" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"❌ JavaScript analysis failed completely" withColor:[DevToolsStyles errorTextColor]];
    [self logToConsole:@"🔧 This suggests a deeper issue with the WebView or page" withColor:[DevToolsStyles warningTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"💡 Troubleshooting suggestions:" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"   1. Try refreshing the page" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"   2. Try a different website" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"   3. Check if JavaScript is enabled" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@"   4. Restart MacBird if issues persist" withColor:[DevToolsStyles secondaryTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"📊 Based on static info:" withColor:[DevToolsStyles accentTextColor]];
    [self logToConsole:@"   MacBird version: 1.0.0" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@"   Engine: WebKit (latest)" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@"   Platform: macOS" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@""];
    [self logToConsole:@"🔍 ===== MANUAL ANALYSIS COMPLETE =====" withColor:[DevToolsStyles successTextColor]];
    [self logToConsole:@""];
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