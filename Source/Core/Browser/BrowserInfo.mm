#import "BrowserInfo.h"
#include <iostream>

// ✨ MACBIRD BROWSER IDENTITY - VERSIONE 1.0.0
// Questo è il cuore dell'identità MacBird

@implementation BrowserInfo

// ========== BROWSER IDENTITY ==========

+ (NSString*)browserName {
    return @"MacBird";
}

+ (NSString*)browserVersion {
    return @"1.0.0";
}

+ (NSString*)browserBuild {
    return @"2025.01.22";  // Data di build
}

+ (NSString*)browserCodename {
    return @"Swift Eagle";  // Nome in codice per la v1.0
}

// ========== USER AGENT MANAGEMENT ==========

+ (NSString*)macBirdUserAgent {
    // ✨ USER-AGENT AUTENTICO MACBIRD
    // Questo è il nostro vero User-Agent che useremo gradualmente
    return [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel Mac OS X %@) AppleWebKit/%@ (KHTML, like Gecko) %@/%@ Safari/%@",
            [self macOSVersionForUA],
            [self webKitVersion],
            [self browserName],
            [self browserVersion],
            [self safariVersion]];
}

+ (NSString*)compatibilityUserAgent {
    // ✨ USER-AGENT CON COMPATIBILITY
    // Mantiene Safari ma aggiunge MacBird per identificazione
    return [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel Mac OS X %@) AppleWebKit/%@ (KHTML, like Gecko) Version/%@ Safari/%@ %@/%@",
            [self macOSVersionForUA],
            [self webKitVersion],
            [self safariVersion],
            [self safariVersion],
            [self browserName],
            [self browserVersion]];
}

+ (NSString*)webKitVersion {
    return @"618.3.7";  // WebKit moderno 2025
}

+ (NSString*)safariVersion {
    return @"18.2";     // Safari compatibile
}

+ (NSString*)macOSVersionForUA {
    return @"10_15_7";  // macOS Catalina+ compatible
}

// ========== PLATFORM INFO ==========

+ (NSString*)platformInfo {
    return @"MacIntel";
}

+ (NSString*)macOSVersion {
    NSProcessInfo* processInfo = [NSProcessInfo processInfo];
    NSOperatingSystemVersion version = [processInfo operatingSystemVersion];
    return [NSString stringWithFormat:@"%ld.%ld.%ld", 
            (long)version.majorVersion, 
            (long)version.minorVersion, 
            (long)version.patchVersion];
}

+ (NSString*)architecture {
    #if defined(__x86_64__)
        return @"x86_64";
    #elif defined(__arm64__)
        return @"arm64";
    #else
        return @"unknown";
    #endif
}

// ========== FEATURE DETECTION ==========

+ (NSDictionary*)supportedFeatures {
    return @{
        // ✨ STANDARD WEB FEATURES
        @"html5": @YES,
        @"css3": @YES,
        @"javascript": @YES,
        @"webgl": @YES,
        @"webgl2": @YES,
        @"canvas": @YES,
        @"svg": @YES,
        @"websockets": @YES,
        @"fetch": @YES,
        @"serviceworker": @YES,
        @"pushapi": @NO,  // Da implementare
        @"notifications": @YES,
        
        // ✨ MODERN WEB APIS
        @"intersectionobserver": @YES,
        @"resizeobserver": @YES,
        @"mutationobserver": @YES,
        @"performanceobserver": @YES,
        
        // ✨ CSS FEATURES
        @"cssgrid": @YES,
        @"flexbox": @YES,
        @"customproperties": @YES,
        @"backdropfilter": @YES,
        @"borderradius": @YES,
        @"transforms": @YES,
        @"animations": @YES,
        
        // ✨ MACBIRD UNIQUE FEATURES
        @"macbird_privacy": @YES,
        @"macbird_devtools": @YES,
        @"macbird_tabs": @YES,
        @"macbird_macos": @YES
    };
}

+ (BOOL)supportsFeature:(NSString*)featureName {
    NSDictionary* features = [self supportedFeatures];
    NSNumber* supported = features[featureName];
    return supported ? [supported boolValue] : NO;
}

+ (NSArray*)macBirdUniqueFeatures {
    return @[
        @"Enhanced Privacy Controls",
        @"Advanced Developer Tools", 
        @"Multi-Tab Isolation",
        @"macOS Native Integration",
        @"Performance Optimization",
        @"Modern WebKit Engine"
    ];
}

// ========== COMPATIBILITY ==========

+ (NSDictionary*)browserHeaders {
    return @{
        @"User-Agent": [self compatibilityUserAgent],
        @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8",
        @"Accept-Language": @"en-US,en;q=0.9",
        @"Accept-Encoding": @"gzip, deflate, br, zstd",
        @"Connection": @"keep-alive",
        @"Upgrade-Insecure-Requests": @"1",
        @"Cache-Control": @"no-cache"
    };
}

+ (NSDictionary*)securityHeaders {
    return @{
        @"DNT": @"1",
        @"Sec-Fetch-User": @"1",
        @"Sec-Fetch-Mode": @"navigate",
        @"Sec-Fetch-Dest": @"document", 
        @"Sec-Fetch-Site": @"none",
        @"Sec-CH-UA": [NSString stringWithFormat:@"\"%@\";v=\"%@\", \"Chromium\";v=\"128\", \"Not)A;Brand\";v=\"99\"", [self browserName], [self majorVersionString]],
        @"Sec-CH-UA-Mobile": @"?0",
        @"Sec-CH-UA-Platform": @"\"macOS\"",
        @"Sec-CH-UA-Platform-Version": @"\"15.0\""
    };
}

+ (NSDictionary*)performanceHeaders {
    return @{
        @"Priority": @"u=0, i"
    };
}

// ========== VERSIONING ==========

+ (NSInteger)majorVersion {
    return 1;
}

+ (NSInteger)minorVersion {
    return 0;
}

+ (NSInteger)patchVersion {
    return 0;
}

+ (NSString*)versionString {
    return [NSString stringWithFormat:@"%ld.%ld.%ld", 
            (long)[self majorVersion], 
            (long)[self minorVersion], 
            (long)[self patchVersion]];
}

+ (NSString*)majorVersionString {
    return [NSString stringWithFormat:@"%ld", (long)[self majorVersion]];
}

// ========== BRANDING ==========

+ (NSString*)browserDescription {
    return @"MacBird - The Modern Browser for macOS";
}

+ (NSString*)marketingName {
    return @"MacBird Browser";
}

+ (NSString*)developerName {
    return @"MacBird Development Team";
}

// ========== HELPER METHODS ==========

+ (void)logBrowserInfo {
    std::cout << "🐦 ========== MACBIRD BROWSER INFO ==========" << std::endl;
    std::cout << "📱 Name: " << [[self browserName] UTF8String] << std::endl;
    std::cout << "🔢 Version: " << [[self versionString] UTF8String] << std::endl;
    std::cout << "🏗️ Build: " << [[self browserBuild] UTF8String] << std::endl;
    std::cout << "🦅 Codename: " << [[self browserCodename] UTF8String] << std::endl;
    std::cout << "🖥️ Platform: " << [[self platformInfo] UTF8String] << std::endl;
    std::cout << "🏛️ Architecture: " << [[self architecture] UTF8String] << std::endl;
    std::cout << "🌐 User-Agent: " << [[self macBirdUserAgent] UTF8String] << std::endl;
    std::cout << "🐦 =============================================" << std::endl;
}

@end