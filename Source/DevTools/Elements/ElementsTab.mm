#import "ElementsTab.h"
#import "Platform/macOS/BrowserWindow.h"
#import "../Common/DevToolsStyles.h"
#include <iostream>

@implementation ElementsTab

- (instancetype)initWithBrowserWindow:(BrowserWindow*)window frame:(NSRect)frame {
    self = [super init];
    if (self) {
        self.browserWindow = window;
        self.htmlNodes = [[NSMutableArray alloc] init];
        self.selectedElement = [[NSMutableDictionary alloc] init];
        self.containerView = [self createAdvancedElementsInspector:frame];
    }
    return self;
}

- (NSView*)createAdvancedElementsInspector:(NSRect)frame {
    // ===== CONTAINER PRINCIPALE =====
    NSView* inspectorContainer = [[NSView alloc] initWithFrame:frame];
    [inspectorContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [inspectorContainer setWantsLayer:YES];
    [inspectorContainer.layer setBackgroundColor:[DevToolsStyles containerBackgroundColor].CGColor];
    
    // ===== TOOLBAR SUPERIORE =====
    CGFloat toolbarHeight = [DevToolsStyles toolbarHeight];
    NSView* inspectorToolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, frame.size.height - toolbarHeight, frame.size.width, toolbarHeight)];
    [inspectorToolbar setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [inspectorToolbar setWantsLayer:YES];
    [inspectorToolbar.layer setBackgroundColor:[DevToolsStyles toolbarBackgroundColor].CGColor];
    [inspectorToolbar.layer setBorderWidth:[DevToolsStyles borderWidth]];
    [inspectorToolbar.layer setBorderColor:[DevToolsStyles borderColor].CGColor];
    
    // 🔄 Refresh Button
    NSButton* refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 6, 80, 23)];
    [refreshButton setTitle:@"Refresh"];
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(refreshElementTree)];
    [refreshButton setBezelStyle:NSBezelStyleRounded];
    [refreshButton setControlSize:NSControlSizeSmall];
    [refreshButton setWantsLayer:YES];
    [refreshButton.layer setBackgroundColor:[DevToolsStyles buttonBackgroundColor].CGColor];
    [refreshButton.layer setCornerRadius:3];
    
    // 🎯 Select Element Button  
    NSButton* selectButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 6, 100, 23)];
    [selectButton setTitle:@"Select Element"];
    [selectButton setTarget:self];
    [selectButton setAction:@selector(startElementSelection)];
    [selectButton setBezelStyle:NSBezelStyleRounded];
    [selectButton setControlSize:NSControlSizeSmall];
    [selectButton setWantsLayer:YES];
    [selectButton.layer setBackgroundColor:[NSColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1.0].CGColor];
    [selectButton.layer setCornerRadius:3];
    
    // 📍 Breadcrumb Navigation
    self.breadcrumbView = [[NSTextField alloc] initWithFrame:NSMakeRect(220, 10, frame.size.width - 240, 16)];
    [self.breadcrumbView setStringValue:@"html > body"];
    [self.breadcrumbView setBezeled:NO];
    [self.breadcrumbView setDrawsBackground:NO];
    [self.breadcrumbView setEditable:NO];
    [self.breadcrumbView setSelectable:YES];
    [self.breadcrumbView setTextColor:[DevToolsStyles accentTextColor]];
    [self.breadcrumbView setFont:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    [self.breadcrumbView setAutoresizingMask:NSViewWidthSizable];
    
    [inspectorToolbar addSubview:refreshButton];
    [inspectorToolbar addSubview:selectButton];
    [inspectorToolbar addSubview:self.breadcrumbView];
    
    // ===== SPLIT VIEW PRINCIPALE =====
    NSSplitView* mainSplitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - toolbarHeight)];
    [mainSplitView setVertical:YES];
    [mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    [mainSplitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // ===== LEFT PANEL - HTML TREE VIEW =====
    CGFloat leftPanelWidth = frame.size.width * 0.55; // 55% per il tree
    NSView* leftPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, leftPanelWidth, frame.size.height - toolbarHeight)];
    [leftPanel setWantsLayer:YES];
    [leftPanel.layer setBackgroundColor:[DevToolsStyles backgroundColor].CGColor];
    
    // 🌳 HTML Tree View con OutlineView
    NSScrollView* treeScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, leftPanelWidth, frame.size.height - toolbarHeight)];
    [treeScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [treeScrollView setHasVerticalScroller:YES];
    [treeScrollView setBorderType:NSNoBorder];
    [treeScrollView setDrawsBackground:YES];
    [treeScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    self.htmlTreeView = [[NSOutlineView alloc] initWithFrame:[[treeScrollView contentView] bounds]];
    [self.htmlTreeView setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.htmlTreeView setUsesAlternatingRowBackgroundColors:NO];
    [self.htmlTreeView setIndentationPerLevel:20];
    [self.htmlTreeView setDataSource:self];
    [self.htmlTreeView setDelegate:self];
    [self.htmlTreeView setTarget:self];
    [self.htmlTreeView setDoubleAction:@selector(editSelectedElement:)];
    
    // Colonne per il Tree View
    NSTableColumn* treeColumn = [[NSTableColumn alloc] initWithIdentifier:@"tree"];
    [treeColumn setTitle:@"Elements"];
    [treeColumn setWidth:leftPanelWidth - 20];
    [treeColumn setResizingMask:NSTableColumnAutoresizingMask];
    [self.htmlTreeView addTableColumn:treeColumn];
    [self.htmlTreeView setOutlineTableColumn:treeColumn];
    
    [treeScrollView setDocumentView:self.htmlTreeView];
    [leftPanel addSubview:treeScrollView];
    
    // ===== RIGHT PANEL - CSS STYLES & PROPERTIES =====
    CGFloat rightPanelWidth = frame.size.width * 0.45; // 45% per gli styles
    NSView* rightPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, rightPanelWidth, frame.size.height - toolbarHeight)];
    [rightPanel setWantsLayer:YES];  
    [rightPanel.layer setBackgroundColor:[DevToolsStyles backgroundColor].CGColor];
    
    // 📂 Tab View per separare Styles, Computed, etc.
    self.rightPanelTabs = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, rightPanelWidth, frame.size.height - toolbarHeight)];
    [self.rightPanelTabs setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.rightPanelTabs setTabViewType:NSTopTabsBezelBorder];
    
    // ===== STYLES TAB =====
    NSTabViewItem* stylesTab = [[NSTabViewItem alloc] initWithIdentifier:@"styles"];
    [stylesTab setLabel:@"Styles"];
    
    NSScrollView* stylesScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, rightPanelWidth - 20, frame.size.height - toolbarHeight - 30)];
    [stylesScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [stylesScrollView setHasVerticalScroller:YES];
    [stylesScrollView setBorderType:NSNoBorder];
    [stylesScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    self.cssStylesView = [[NSTextView alloc] initWithFrame:[[stylesScrollView contentView] bounds]];
    [self.cssStylesView setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.cssStylesView setTextColor:[DevToolsStyles primaryTextColor]];
    [self.cssStylesView setInsertionPointColor:[NSColor whiteColor]];
    [self.cssStylesView setFont:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    [self.cssStylesView setEditable:YES];
    [self.cssStylesView setSelectable:YES];
    [self.cssStylesView setString:@"/* CSS Styles for selected element will appear here */\n\n📝 Select an element from the tree to view its styles\n🎨 Double-click values to edit them live"];
    
    [stylesScrollView setDocumentView:self.cssStylesView];
    [stylesTab setView:stylesScrollView];
    [self.rightPanelTabs addTabViewItem:stylesTab];
    
    // ===== COMPUTED TAB =====
    NSTabViewItem* computedTab = [[NSTabViewItem alloc] initWithIdentifier:@"computed"];
    [computedTab setLabel:@"Computed"];
    
    NSScrollView* computedScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, rightPanelWidth - 20, frame.size.height - toolbarHeight - 30)];
    [computedScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [computedScrollView setHasVerticalScroller:YES];
    [computedScrollView setBorderType:NSNoBorder];
    [computedScrollView setBackgroundColor:[DevToolsStyles backgroundColor]];
    
    self.computedStylesView = [[NSTextView alloc] initWithFrame:[[computedScrollView contentView] bounds]];
    [self.computedStylesView setBackgroundColor:[DevToolsStyles backgroundColor]];
    [self.computedStylesView setTextColor:[DevToolsStyles primaryTextColor]];
    [self.computedStylesView setInsertionPointColor:[NSColor whiteColor]];
    [self.computedStylesView setFont:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    [self.computedStylesView setEditable:NO];
    [self.computedStylesView setSelectable:YES];
    [self.computedStylesView setString:@"/* Computed CSS values will appear here */\n\n🧮 Final computed styles for selected element\n📐 All inherited and calculated values"];
    
    [computedScrollView setDocumentView:self.computedStylesView];
    [computedTab setView:computedScrollView];
    [self.rightPanelTabs addTabViewItem:computedTab];
    
    // ===== BOX MODEL TAB =====
    NSTabViewItem* boxModelTab = [[NSTabViewItem alloc] initWithIdentifier:@"boxmodel"];
    [boxModelTab setLabel:@"Box Model"];
    
    NSView* boxModelView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, rightPanelWidth - 20, frame.size.height - toolbarHeight - 30)];
    [boxModelView setWantsLayer:YES];
    [boxModelView.layer setBackgroundColor:[DevToolsStyles backgroundColor].CGColor];
    
    // TODO: Implementeremo la visualizzazione del Box Model
    NSTextField* boxModelLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, (frame.size.height - toolbarHeight - 30) / 2, rightPanelWidth - 60, 60)];
    [boxModelLabel setStringValue:@"📦 Box Model Visualizer\n\n🔧 Coming Soon: Visual representation of\nmargin, border, padding, and content"];
    [boxModelLabel setBezeled:NO];
    [boxModelLabel setDrawsBackground:NO];
    [boxModelLabel setEditable:NO];
    [boxModelLabel setSelectable:NO];
    [boxModelLabel setTextColor:[DevToolsStyles secondaryTextColor]];
    [boxModelLabel setFont:[NSFont systemFontOfSize:12]];
    [boxModelLabel setAlignment:NSTextAlignmentCenter];
    [boxModelView addSubview:boxModelLabel];
    
    [boxModelTab setView:boxModelView];
    [self.rightPanelTabs addTabViewItem:boxModelTab];
    
    [rightPanel addSubview:self.rightPanelTabs];
    
    // ===== ASSEMBLY =====
    [mainSplitView addSubview:leftPanel];
    [mainSplitView addSubview:rightPanel];
    
    [inspectorContainer addSubview:mainSplitView];
    [inspectorContainer addSubview:inspectorToolbar];
    
    // Auto-refresh al primo caricamento
    [self performSelector:@selector(refreshElementTree) withObject:nil afterDelay:0.5];
    
    return inspectorContainer;
}

// ========== OUTLINE VIEW DATA SOURCE & DELEGATE ==========

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.htmlNodes count];
    }
    
    NSDictionary* node = (NSDictionary*)item;
    NSArray* children = node[@"children"];
    return children ? [children count] : 0;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [self.htmlNodes objectAtIndex:index];
    }
    
    NSDictionary* node = (NSDictionary*)item;
    NSArray* children = node[@"children"];
    return [children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {
    NSDictionary* node = (NSDictionary*)item;
    NSArray* children = node[@"children"];
    return children && [children count] > 0;
}

- (NSView*)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item {
    NSDictionary* node = (NSDictionary*)item;
    NSString* tagName = node[@"tagName"] ?: @"text";
    NSString* attributes = node[@"attributes"] ?: @"";
    NSString* textContent = node[@"textContent"];
    
    NSTableCellView* cellView = [[NSTableCellView alloc] init];
    NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 20)];
    
    // 🏷️ Formattazione tipo Chrome DevTools
    NSString* displayText;
    if ([tagName isEqualToString:@"text"]) {
        displayText = [NSString stringWithFormat:@"📄 \"%@\"", [textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [textField setTextColor:[DevToolsStyles secondaryTextColor]];
    } else {
        if ([attributes length] > 0) {
            displayText = [NSString stringWithFormat:@"<%@ %@>", tagName, attributes];
        } else {
            displayText = [NSString stringWithFormat:@"<%@>", tagName];
        }
        [textField setTextColor:[DevToolsStyles htmlTagColor]];
    }
    
    [textField setStringValue:displayText];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setFont:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    
    [cellView addSubview:textField];
    [cellView setTextField:textField];
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification*)notification {
    NSInteger selectedRow = [self.htmlTreeView selectedRow];
    if (selectedRow >= 0) {
        id selectedItem = [self.htmlTreeView itemAtRow:selectedRow];
        [self selectElement:selectedItem];
    }
}

// ========== ELEMENT SELECTION & INSPECTION ==========

- (void)selectElement:(NSDictionary*)element {
    self.selectedElement = [element mutableCopy];
    
    // 📍 Aggiorna breadcrumb
    [self updateBreadcrumb:element];
    
    // 🎨 Carica styles per l'elemento selezionato
    [self loadStylesForElement:element];
    
    // 🔍 Highlight l'elemento nella pagina
    [self highlightElementInPage:element];
}

- (void)updateBreadcrumb:(NSDictionary*)element {
    // TODO: Implementare breadcrumb navigation
    NSString* tagName = element[@"tagName"] ?: @"unknown";
    [self.breadcrumbView setStringValue:[NSString stringWithFormat:@"html > body > ... > %@", tagName]];
}

- (void)loadStylesForElement:(NSDictionary*)element {
    NSString* elementId = element[@"elementId"];
    if (!elementId) return;
    
    // 🎨 JavaScript per ottenere gli styles
    NSString* getStylesScript = [NSString stringWithFormat:@
    "try {"
    "  const element = document.querySelector('[data-macbird-id=\"%@\"]');"
    "  if (!element) { JSON.stringify({error: 'Element not found'}); }"
    "  else {"
    "    const styles = window.getComputedStyle(element);"
    "    const result = {"
    "      declared: {},"
    "      computed: {},"
    "      boxModel: {"
    "        width: element.offsetWidth,"
    "        height: element.offsetHeight,"
    "        margin: [styles.marginTop, styles.marginRight, styles.marginBottom, styles.marginLeft],"
    "        border: [styles.borderTopWidth, styles.borderRightWidth, styles.borderBottomWidth, styles.borderLeftWidth],"
    "        padding: [styles.paddingTop, styles.paddingRight, styles.paddingBottom, styles.paddingLeft]"
    "      }"
    "    };"
    "    "
    "    // Computed styles  "
    "    for (let i = 0; i < styles.length; i++) {"
    "      const property = styles[i];"
    "      result.computed[property] = styles.getPropertyValue(property);"
    "    }"
    "    "
    "    JSON.stringify(result);"
    "  }"
    "} catch (e) {"
    "  JSON.stringify({error: e.message});"
    "}", elementId];
    
    [self.browserWindow.webView evaluateJavaScript:getStylesScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayStyles:(NSString*)result];
            });
        }
    }];
}

- (void)displayStyles:(NSString*)stylesJSON {
    NSData* jsonData = [stylesJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* stylesData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error || !stylesData) {
        [self.cssStylesView setString:@"❌ Error loading styles"];
        return;
    }
    
    if (stylesData[@"error"]) {
        [self.cssStylesView setString:[NSString stringWithFormat:@"❌ %@", stylesData[@"error"]]];
        return;
    }
    
    // 🎨 Format Computed Styles
    NSDictionary* computed = stylesData[@"computed"];
    NSMutableString* computedText = [[NSMutableString alloc] init];
    [computedText appendString:@"/* 🧮 COMPUTED STYLES */\n\n"];
    
    NSArray* sortedKeys = [[computed allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString* property in sortedKeys) {
        [computedText appendFormat:@"%@: %@;\n", property, computed[property]];
    }
    
    [self.computedStylesView setString:computedText];
    
    // 🎨 Format Styles (più selettivo per le properties importanti)
    NSMutableString* stylesText = [[NSMutableString alloc] init];
    [stylesText appendString:@"/* 🎨 ELEMENT STYLES */\n\n"];
    [stylesText appendString:@"element {\n"];
    
    // Properties più importanti first
    NSArray* importantProps = @[@"display", @"position", @"width", @"height", @"margin", @"padding", @"border", @"background", @"color", @"font-family", @"font-size", @"text-align"];
    
    for (NSString* prop in importantProps) {
        NSString* value = computed[prop];
        if (value && ![value isEqualToString:@""] && ![value isEqualToString:@"none"] && ![value isEqualToString:@"normal"]) {
            [stylesText appendFormat:@"  %@: %@;\n", prop, value];
        }
    }
    
    [stylesText appendString:@"}\n\n"];
    [stylesText appendString:@"/* 💡 TIP: Double-click values to edit them live */"];
    
    [self.cssStylesView setString:stylesText];
    
    // Apply syntax highlighting
    [self applyCSSHighlighting:self.cssStylesView];
    [self applyCSSHighlighting:self.computedStylesView];
}

- (void)applyCSSHighlighting:(NSTextView*)textView {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[textView string]];
    NSString* cssString = [textView string];
    
    // Base font
    [attributedString addAttribute:NSFontAttributeName value:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular] range:NSMakeRange(0, cssString.length)];
    
    // CSS properties (before colon)
    NSRegularExpression* propRegex = [NSRegularExpression regularExpressionWithPattern:@"\\s*(\\w+[\\w-]*)\\s*:" options:0 error:nil];
    [propRegex enumerateMatchesInString:cssString options:0 range:NSMakeRange(0, cssString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:1.0] range:[match rangeAtIndex:1]];
    }];
    
    // CSS values (after colon, before semicolon)
    NSRegularExpression* valueRegex = [NSRegularExpression regularExpressionWithPattern:@":\\s*([^;\\n]+)" options:0 error:nil];
    [valueRegex enumerateMatchesInString:cssString options:0 range:NSMakeRange(0, cssString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.9 green:0.9 blue:0.6 alpha:1.0] range:[match rangeAtIndex:1]];
    }];
    
    // Comments
    NSRegularExpression* commentRegex = [NSRegularExpression regularExpressionWithPattern:@"/\\*[^*]*\\*/" options:0 error:nil];
    [commentRegex enumerateMatchesInString:cssString options:0 range:NSMakeRange(0, cssString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.5 green:0.7 blue:0.5 alpha:1.0] range:match.range];
    }];
    
    [[textView textStorage] setAttributedString:attributedString];
}

- (void)highlightElementInPage:(NSDictionary*)element {
    NSString* elementId = element[@"elementId"];
    if (!elementId) return;
    
    // 🔍 JavaScript per highlight
    NSString* highlightScript = [NSString stringWithFormat:@
    "try {"
    "  // Remove existing highlights"
    "  const existingOverlay = document.getElementById('macbird-element-highlight');"
    "  if (existingOverlay) existingOverlay.remove();"
    "  "
    "  const element = document.querySelector('[data-macbird-id=\"%@\"]');"
    "  if (element) {"
    "    const rect = element.getBoundingClientRect();"
    "    const overlay = document.createElement('div');"
    "    overlay.id = 'macbird-element-highlight';"
    "    overlay.style.position = 'fixed';"
    "    overlay.style.top = rect.top + 'px';"
    "    overlay.style.left = rect.left + 'px';"
    "    overlay.style.width = rect.width + 'px';"
    "    overlay.style.height = rect.height + 'px';"
    "    overlay.style.border = '2px solid #007AFF';"
    "    overlay.style.backgroundColor = 'rgba(0, 122, 255, 0.1)';"
    "    overlay.style.pointerEvents = 'none';"
    "    overlay.style.zIndex = '999999';"
    "    document.body.appendChild(overlay);"
    "    "
    "    // Auto-remove dopo 3 secondi"
    "    setTimeout(() => {"
    "      if (overlay.parentNode) overlay.remove();"
    "    }, 3000);"
    "  }"
    "} catch (e) {}", elementId];
    
    [self.browserWindow.webView evaluateJavaScript:highlightScript completionHandler:nil];
}

// ========== MAIN ACTIONS ==========

- (void)refreshElementTree {
    std::cout << "🔄 Refreshing element tree..." << std::endl;
    
    // 🌳 JavaScript per costruire l'albero DOM
    NSString* buildTreeScript = @
    "try {"
    "  let nodeId = 0;"
    "  function buildNodeTree(element) {"
    "    const node = {"
    "      elementId: 'macbird-' + (++nodeId),"
    "      tagName: element.tagName ? element.tagName.toLowerCase() : 'text',"
    "      textContent: element.nodeType === 3 ? element.textContent.trim() : null,"
    "      attributes: '',"
    "      children: []"
    "    };"
    "    "
    "    // Add data-macbird-id for selection"
    "    if (element.nodeType === 1) {"
    "      element.setAttribute('data-macbird-id', node.elementId);"
    "      "
    "      // Build attributes string"
    "      const attrs = [];"
    "      for (const attr of element.attributes) {"
    "        if (attr.name !== 'data-macbird-id') {"
    "          attrs.push(attr.name + '=\"' + attr.value + '\"');"
    "        }"
    "      }"
    "      node.attributes = attrs.join(' ');"
    "    }"
    "    "
    "    // Process children"
    "    for (const child of element.childNodes) {"
    "      if (child.nodeType === 1 || (child.nodeType === 3 && child.textContent.trim())) {"
    "        node.children.push(buildNodeTree(child));"
    "      }"
    "    }"
    "    "
    "    return node;"
    "  }"
    "  "
    "  JSON.stringify([buildNodeTree(document.documentElement)]);"
    "} catch (e) {"
    "  JSON.stringify({error: e.message});"
    "}";
    
    [self.browserWindow.webView evaluateJavaScript:buildTreeScript completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseHTMLTree:(NSString*)result];
            });
        }
    }];
}

- (void)parseHTMLTree:(NSString*)treeJSON {
    NSData* jsonData = [treeJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSArray* treeData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error || !treeData) {
        std::cout << "❌ Error parsing HTML tree" << std::endl;
        return;
    }
    
    [self.htmlNodes removeAllObjects];
    [self.htmlNodes addObjectsFromArray:treeData];
    [self.htmlTreeView reloadData];
    [self.htmlTreeView expandItem:[self.htmlNodes firstObject]]; // Espandi html
    
    std::cout << "✅ Element tree refreshed with " << [self.htmlNodes count] << " root nodes" << std::endl;
}

- (void)startElementSelection {
    // 🎯 Modalità "Select Element" come Chrome DevTools
    NSString* selectionScript = @
    "try {"
    "  if (window.macbirdElementSelector) {"
    "    document.removeEventListener('mouseover', window.macbirdElementSelector.mouseover);"
    "    document.removeEventListener('click', window.macbirdElementSelector.click);"
    "  }"
    "  "
    "  window.macbirdElementSelector = {"
    "    mouseover: function(e) {"
    "      e.stopPropagation();"
    "      const existingOverlay = document.getElementById('macbird-hover-highlight');"
    "      if (existingOverlay) existingOverlay.remove();"
    "      "
    "      const rect = e.target.getBoundingClientRect();"
    "      const overlay = document.createElement('div');"
    "      overlay.id = 'macbird-hover-highlight';"
    "      overlay.style.position = 'fixed';"
    "      overlay.style.top = rect.top + 'px';"
    "      overlay.style.left = rect.left + 'px';"
    "      overlay.style.width = rect.width + 'px';"
    "      overlay.style.height = rect.height + 'px';"
    "      overlay.style.border = '2px solid #FF6B35';"
    "      overlay.style.backgroundColor = 'rgba(255, 107, 53, 0.1)';"
    "      overlay.style.pointerEvents = 'none';"
    "      overlay.style.zIndex = '999999';"
    "      document.body.appendChild(overlay);"
    "    },"
    "    click: function(e) {"
    "      e.preventDefault();"
    "      e.stopPropagation();"
    "      "
    "      // Cleanup"
    "      const overlay = document.getElementById('macbird-hover-highlight');"
    "      if (overlay) overlay.remove();"
    "      document.removeEventListener('mouseover', window.macbirdElementSelector.mouseover);"
    "      document.removeEventListener('click', window.macbirdElementSelector.click);"
    "      "
    "      // Get element path"
    "      const elementId = e.target.getAttribute('data-macbird-id');"
    "      if (elementId) {"
    "        window.webkit.messageHandlers.elementSelected.postMessage({elementId: elementId});"
    "      }"
    "    }"
    "  };"
    "  "
    "  document.addEventListener('mouseover', window.macbirdElementSelector.mouseover);"
    "  document.addEventListener('click', window.macbirdElementSelector.click);"
    "  "
    "  'Element selection mode activated';"
    "} catch (e) {"
    "  'Error: ' + e.message;"
    "}";
    
    [self.browserWindow.webView evaluateJavaScript:selectionScript completionHandler:^(id result, NSError *error) {
        if (!error) {
            std::cout << "🎯 Element selection mode activated" << std::endl;
        }
    }];
}

- (void)editSelectedElement:(id)sender {
    // TODO: Implementare editing in-place
    std::cout << "✏️ Edit element functionality - coming soon!" << std::endl;
}

// ========== LEGACY METHODS (Manteniamo per compatibilità) ==========

- (NSView*)createElementsTabView {
    return self.containerView;
}

- (void)refreshHTMLSource {
    // Legacy method - ora usa il nuovo refreshElementTree
    [self refreshElementTree];
}

@end