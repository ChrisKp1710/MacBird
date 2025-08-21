#ifndef DEVTOOLSSTYLES_H
#define DEVTOOLSSTYLES_H

#import <Cocoa/Cocoa.h>

@interface DevToolsStyles : NSObject

// === CHROME DEVTOOLS DARK THEME COLORS ===
+ (NSColor*)backgroundColor;           // Sfondo principale (0.11, 0.11, 0.11)
+ (NSColor*)tabViewBackgroundColor;    // Sfondo tab view (0.15, 0.15, 0.15)
+ (NSColor*)containerBackgroundColor;  // Sfondo container (0.13, 0.13, 0.13)
+ (NSColor*)toolbarBackgroundColor;    // Sfondo toolbar (0.16, 0.16, 0.16)
+ (NSColor*)buttonBackgroundColor;     // Sfondo pulsanti (0.2, 0.2, 0.2)
+ (NSColor*)borderColor;               // Colore bordi (0.25, 0.25, 0.25)

// === TEXT COLORS ===
+ (NSColor*)primaryTextColor;          // Testo principale (0.85, 0.85, 0.85)
+ (NSColor*)secondaryTextColor;        // Testo secondario (0.7, 0.7, 0.7)
+ (NSColor*)accentTextColor;           // Testo accento (0.4, 0.8, 1.0)
+ (NSColor*)successTextColor;          // Testo successo (0.2, 0.8, 0.2)
+ (NSColor*)warningTextColor;          // Testo warning (0.8, 0.6, 0.2)
+ (NSColor*)errorTextColor;            // Testo errore (0.8, 0.2, 0.2)

// === SYNTAX HIGHLIGHTING COLORS ===
+ (NSColor*)htmlTagColor;              // Tag HTML (rosso)
+ (NSColor*)htmlAttributeColor;        // Attributi HTML (blu)
+ (NSColor*)htmlStringColor;           // Stringhe HTML (verde)
+ (NSColor*)htmlCommentColor;          // Commenti HTML (grigio)

// === FONTS ===
+ (NSFont*)consoleFont;                // Font console (SF Mono)
+ (NSFont*)codeFont;                   // Font codice (Monaco)
+ (NSFont*)uiFont;                     // Font UI (System)

// === LAYOUT CONSTANTS ===
+ (CGFloat)toolbarHeight;              // Altezza toolbar (35px)
+ (CGFloat)cornerRadius;               // Raggio angoli (8px)
+ (CGFloat)borderWidth;                // Spessore bordi (0.5px)
+ (CGFloat)padding;                    // Padding standard (10px)

@end

#endif