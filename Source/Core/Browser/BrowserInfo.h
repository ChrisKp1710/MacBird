#ifndef BROWSERINFO_H
#define BROWSERINFO_H

#import <Foundation/Foundation.h>

// ✨ MACBIRD BROWSER IDENTITY SYSTEM
// Centralizza tutte le informazioni del browser MacBird

@interface BrowserInfo : NSObject

// ========== BROWSER IDENTITY ==========
+ (NSString*)browserName;
+ (NSString*)browserVersion;
+ (NSString*)browserBuild;
+ (NSString*)browserCodename;

// ========== USER AGENT MANAGEMENT ==========
+ (NSString*)macBirdUserAgent;          // User-Agent autentico MacBird
+ (NSString*)compatibilityUserAgent;    // User-Agent con compatibility
+ (NSString*)webKitVersion;
+ (NSString*)safariVersion;

// ========== PLATFORM INFO ==========
+ (NSString*)platformInfo;
+ (NSString*)macOSVersion;
+ (NSString*)architecture;

// ========== FEATURE DETECTION ==========
+ (NSDictionary*)supportedFeatures;
+ (BOOL)supportsFeature:(NSString*)featureName;
+ (NSArray*)macBirdUniqueFeatures;

// ========== COMPATIBILITY ==========
+ (NSDictionary*)browserHeaders;
+ (NSDictionary*)securityHeaders;
+ (NSDictionary*)performanceHeaders;

// ========== VERSIONING ==========
+ (NSInteger)majorVersion;
+ (NSInteger)minorVersion;
+ (NSInteger)patchVersion;
+ (NSString*)versionString;

// ========== BRANDING ==========
+ (NSString*)browserDescription;
+ (NSString*)marketingName;
+ (NSString*)developerName;

@end

#endif