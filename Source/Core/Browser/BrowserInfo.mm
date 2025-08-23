#import "BrowserInfo.h"
#include <iostream>

// ✨ MACBIRD BROWSER IDENTITY - VERSIONE 1.0.0 ENHANCED
// Il sistema di identità più avanzato per browser nativi

@implementation BrowserInfo

// ========== BROWSER IDENTITY - ENHANCED ==========

+ (NSString*)browserName {
    return @"MacBird";
}

+ (NSString*)browserVersion {
    return @"1.0.0";
}

+ (NSString*)browserBuild {
    return @"2025.01.25";  // Data aggiornata
}

+ (NSString*)browserCodename {
    return @"Swift Eagle";
}

+ (NSString*)browserFullName {
    return [NSString stringWithFormat:@"%@ %@ (%@)", [self browserName], [self browserVersion], [self browserCodename]];
}

// ========== USER AGENT MANAGEMENT - ENHANCED ==========

+ (NSString*)macBirdUserAgent {
    // ✨ USER-AGENT AUTENTICO MACBIRD - FUTURO
    return [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel Mac OS X %@) AppleWebKit/%@ (KHTML, like Gecko) %@/%@ Safari/%@",
            [self macOSVersionForUA],
            [self webKitVersion],
            [self browserName],
            [self browserVersion],
            [self safariVersion]];
}

+ (NSString*)compatibilityUserAgent {
    // ✨ USER-AGENT PROMINENTE MACBIRD - PRODUZIONE ATTUALE
    // MacBird in PRIMA POSIZIONE per massima visibilità
    return [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel Mac OS X %@) AppleWebKit/%@ (KHTML, like Gecko) %@/%@ Version/%@ Safari/%@",
            [self macOSVersionForUA],
            [self webKitVersion], 
            [self browserName],
            [self browserVersion],
            [self safariVersion],
            [self safariVersion]];
}

+ (NSString*)webKitVersion {
    return @"618.3.7";  // WebKit più recente
}

+ (NSString*)safariVersion {
    return @"18.2.1";   // Safari più aggiornato
}

+ (NSString*)macOSVersionForUA {
    return @"14_7_1";   // macOS Sonoma
}

// ========== PLATFORM INFO - ENHANCED ==========

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

+ (NSString*)hardwareModel {
    #if defined(__arm64__)
        return @"Apple Silicon";
    #else
        return @"Intel Mac";
    #endif
}

// ========== FEATURE DETECTION - ENHANCED ==========

+ (NSDictionary*)supportedFeatures {
    return @{
        // ✨ CORE WEB STANDARDS
        @"html5": @YES,
        @"css3": @YES,
        @"es6": @YES,
        @"es2020": @YES,
        @"javascript": @YES,
        @"typescript": @YES,
        @"webassembly": @YES,
        
        // ✨ GRAPHICS & MEDIA
        @"webgl": @YES,
        @"webgl2": @YES,
        @"canvas": @YES,
        @"svg": @YES,
        @"webp": @YES,
        @"avif": @YES,
        @"heic": @YES,
        
        // ✨ NETWORK & APIS
        @"websockets": @YES,
        @"fetch": @YES,
        @"xhr": @YES,
        @"sse": @YES, // Server-Sent Events
        @"websocket": @YES,
        
        // ✨ MODERN WEB APIS
        @"serviceworker": @YES,
        @"pushapi": @NO,  // Future implementation
        @"notifications": @YES,
        @"geolocation": @YES,
        @"intersectionobserver": @YES,
        @"resizeobserver": @YES,
        @"mutationobserver": @YES,
        @"performanceobserver": @YES,
        
        // ✨ CSS MODERN FEATURES
        @"cssgrid": @YES,
        @"flexbox": @YES,
        @"customproperties": @YES,
        @"backdropfilter": @YES,
        @"borderradius": @YES,
        @"transforms": @YES,
        @"animations": @YES,
        @"transitions": @YES,
        @"gradients": @YES,
        
        // ✨ SECURITY & PRIVACY
        @"csp": @YES, // Content Security Policy
        @"hsts": @YES, // HTTP Strict Transport Security
        @"samesite": @YES,
        @"referrerpolicy": @YES,
        
        // ✨ MACBIRD UNIQUE FEATURES
        @"macbird_privacy": @YES,
        @"macbird_devtools": @YES,
        @"macbird_tabs": @YES,
        @"macbird_macos": @YES,
        @"macbird_performance": @YES,
        @"macbird_identity": @YES
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
        @"Multi-Tab Process Isolation",
        @"macOS Native Integration",
        @"Performance Optimization Engine",
        @"Modern WebKit with Custom Extensions",
        @"Smart User-Agent Management",
        @"Intelligent Site Compatibility"
    ];
}

// ========== COMPATIBILITY HEADERS - ENHANCED ==========

+ (NSDictionary*)browserHeaders {
    return @{
        @"User-Agent": [self compatibilityUserAgent],
        @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8",
        @"Accept-Language": @"en-US,en;q=0.9,it;q=0.8",
        @"Accept-Encoding": @"gzip, deflate, br, zstd",
        @"Connection": @"keep-alive",
        @"Upgrade-Insecure-Requests": @"1",
        @"Cache-Control": @"no-cache",
        @"DNT": @"1"
    };
}

+ (NSDictionary*)securityHeaders {
    return @{
        @"Sec-Fetch-User": @"?1",
        @"Sec-Fetch-Mode": @"navigate", 
        @"Sec-Fetch-Dest": @"document",
        @"Sec-Fetch-Site": @"none",
        @"Sec-CH-UA": [NSString stringWithFormat:@"\"%@\";v=\"%@\", \"Safari\";v=\"%@\", \"WebKit\";v=\"%@\"", 
                       [self browserName], [self majorVersionString], [self safariVersion], [self webKitVersion]],
        @"Sec-CH-UA-Mobile": @"?0",
        @"Sec-CH-UA-Platform": @"\"macOS\"",
        @"Sec-CH-UA-Platform-Version": @"\"14.0\"",
        @"Sec-CH-UA-Full-Version": [NSString stringWithFormat:@"\"%@\"", [self browserVersion]],
        @"X-MacBird-Version": [self browserVersion],
        @"X-MacBird-Build": [self browserBuild]
    };
}

+ (NSDictionary*)performanceHeaders {
    return @{
        @"Priority": @"u=0, i",
        @"X-MacBird-Optimization": @"enabled"
    };
}

// ========== VERSIONING - ENHANCED ==========

+ (NSInteger)majorVersion { return 1; }
+ (NSInteger)minorVersion { return 0; }  
+ (NSInteger)patchVersion { return 0; }

+ (NSString*)versionString {
    return [NSString stringWithFormat:@"%ld.%ld.%ld", 
            (long)[self majorVersion], 
            (long)[self minorVersion], 
            (long)[self patchVersion]];
}

+ (NSString*)majorVersionString {
    return [NSString stringWithFormat:@"%ld", (long)[self majorVersion]];
}

+ (NSString*)buildNumber {
    return @"20250125001"; // Build numerica
}

// ========== BRANDING - ENHANCED ==========

+ (NSString*)browserDescription {
    return @"MacBird - The Modern Native Browser for macOS";
}

+ (NSString*)marketingName {
    return @"MacBird Browser";
}

+ (NSString*)developerName {
    return @"MacBird Development Team";
}

+ (NSString*)copyrightNotice {
    return @"Copyright © 2025 MacBird Development Team. All rights reserved.";
}

+ (NSString*)websiteURL {
    return @"https://macbird.browser";
}

// ========== ENHANCED DETECTION METHODS ==========

+ (NSDictionary*)fullBrowserInfo {
    return @{
        @"name": [self browserName],
        @"version": [self browserVersion], 
        @"build": [self browserBuild],
        @"buildNumber": [self buildNumber],
        @"codename": [self browserCodename],
        @"fullName": [self browserFullName],
        @"userAgent": [self compatibilityUserAgent],
        @"webkitVersion": [self webKitVersion],
        @"safariVersion": [self safariVersion],
        @"platform": [self platformInfo],
        @"macosVersion": [self macOSVersion],
        @"architecture": [self architecture],
        @"hardwareModel": [self hardwareModel],
        @"features": [self supportedFeatures],
        @"uniqueFeatures": [self macBirdUniqueFeatures],
        @"headers": [self browserHeaders],
        @"securityHeaders": [self securityHeaders],
        @"performanceHeaders": [self performanceHeaders],
        @"description": [self browserDescription],
        @"copyright": [self copyrightNotice],
        @"website": [self websiteURL]
    };
}

// ========== HELPER METHODS - ENHANCED ==========

+ (void)logBrowserInfo {
    std::cout << "🐦 ========== MACBIRD BROWSER INFO V2 ==========" << std::endl;
    std::cout << "📱 Full Name: " << [[self browserFullName] UTF8String] << std::endl;
    std::cout << "🔢 Version: " << [[self versionString] UTF8String] << std::endl;
    std::cout << "🏗️ Build: " << [[self browserBuild] UTF8String] << " (" << [[self buildNumber] UTF8String] << ")" << std::endl;
    std::cout << "🦅 Codename: " << [[self browserCodename] UTF8String] << std::endl;
    std::cout << "🖥️ Platform: " << [[self platformInfo] UTF8String] << " (" << [[self hardwareModel] UTF8String] << ")" << std::endl;
    std::cout << "🏛️ Architecture: " << [[self architecture] UTF8String] << std::endl;
    std::cout << "🌐 User-Agent: " << [[self compatibilityUserAgent] UTF8String] << std::endl;
    std::cout << "🎯 WebKit: " << [[self webKitVersion] UTF8String] << " | Safari: " << [[self safariVersion] UTF8String] << std::endl;
    std::cout << "✨ Features: " << [[[self supportedFeatures] allKeys] count] << " supported" << std::endl;
    std::cout << "🐦 ===============================================" << std::endl;
}

@end