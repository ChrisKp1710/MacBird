#ifndef ELEMENTSTAB_H
#define ELEMENTSTAB_H

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserWindow;

@interface ElementsTab : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign, nonatomic) BrowserWindow* browserWindow;
@property (strong, nonatomic) NSView* containerView;

// ========== LEGACY PROPERTIES (manteniamo per compatibilità) ==========
@property (strong, nonatomic) NSTextView* htmlSource;

// ========== ADVANCED INSPECTOR COMPONENTS ==========
@property (strong, nonatomic) NSOutlineView* htmlTreeView;
@property (strong, nonatomic) NSTextView* cssStylesView;
@property (strong, nonatomic) NSTextView* computedStylesView;
@property (strong, nonatomic) NSMutableArray* htmlNodes;
@property (strong, nonatomic) NSMutableDictionary* selectedElement;
@property (strong, nonatomic) NSTabView* rightPanelTabs;
@property (strong, nonatomic) NSTextField* breadcrumbView;

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame;
- (NSView*)createElementsTabView;

// ========== ADVANCED INSPECTOR METHODS ==========
- (NSView*)createAdvancedElementsInspector:(NSRect)frame;

// Element Tree Management
- (void)refreshElementTree;
- (void)parseHTMLTree:(NSString*)treeJSON;

// Element Selection & Inspection
- (void)selectElement:(NSDictionary*)element;
- (void)updateBreadcrumb:(NSDictionary*)element;
- (void)loadStylesForElement:(NSDictionary*)element;
- (void)displayStyles:(NSString*)stylesJSON;
- (void)applyCSSHighlighting:(NSTextView*)textView;
- (void)highlightElementInPage:(NSDictionary*)element;

// Interactive Features
- (void)startElementSelection;
- (void)editSelectedElement:(id)sender;

// ========== LEGACY METHODS (manteniamo per compatibilità) ==========
- (void)refreshHTMLSource;

@end

#endif