#import "DevToolsStyles.h"

@implementation DevToolsStyles

// === CHROME DEVTOOLS DARK THEME COLORS ===
+ (NSColor*)backgroundColor {
    return [NSColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0];
}

+ (NSColor*)tabViewBackgroundColor {
    return [NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
}

+ (NSColor*)containerBackgroundColor {
    return [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
}

+ (NSColor*)toolbarBackgroundColor {
    return [NSColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0];
}

+ (NSColor*)buttonBackgroundColor {
    return [NSColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

+ (NSColor*)borderColor {
    return [NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
}

// === TEXT COLORS ===
+ (NSColor*)primaryTextColor {
    return [NSColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
}

+ (NSColor*)secondaryTextColor {
    return [NSColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
}

+ (NSColor*)accentTextColor {
    return [NSColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0];
}

+ (NSColor*)successTextColor {
    return [NSColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1.0];
}

+ (NSColor*)warningTextColor {
    return [NSColor colorWithRed:0.8 green:0.6 blue:0.2 alpha:1.0];
}

+ (NSColor*)errorTextColor {
    return [NSColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
}

// === SYNTAX HIGHLIGHTING COLORS ===
+ (NSColor*)htmlTagColor {
    return [NSColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
}

+ (NSColor*)htmlAttributeColor {
    return [NSColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:1.0];
}

+ (NSColor*)htmlStringColor {
    return [NSColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
}

+ (NSColor*)htmlCommentColor {
    return [NSColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
}

// === FONTS ===
+ (NSFont*)consoleFont {
    return [NSFont fontWithName:@"SF Mono" size:12] ?: [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
}

+ (NSFont*)codeFont {
    return [NSFont fontWithName:@"Monaco" size:11] ?: [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
}

+ (NSFont*)uiFont {
    return [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
}

// === LAYOUT CONSTANTS ===
+ (CGFloat)toolbarHeight {
    return 35.0;
}

+ (CGFloat)cornerRadius {
    return 8.0;
}

+ (CGFloat)borderWidth {
    return 0.5;
}

+ (CGFloat)padding {
    return 10.0;
}

@end