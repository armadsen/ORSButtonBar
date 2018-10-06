//
//    ORSButtonBar.m
//  ORSButtonBar
//
//    Created by Andreas on 09.02.07.
//    Copyright 2007 Andreas Mayer. All rights reserved.
//
//  2010-02-18  Andreas Mayer
//  - use NSGradient instead of CTGradient for 10.5 and above


#import "ORSButtonBarView.h"
#import "ORSButtonBarItem.h"
#import "ORSButtonBarCell.h"
#import "ORSButtonBarSeparatorCell.h"
#import "NSGradient+ORSButtonBar.h"

float const AM_START_GAP_WIDTH = 8.0;
float const AM_BUTTON_GAP_WIDTH = 2.0;
float const AM_BUTTON_HEIGHT = 20.0;

NSString *const ORSButtonBarSelectionDidChangeNotification = @"ORSButtonBarSelectionDidChangeNotification";

@interface NSShadow (ORSAdditions)
+ (NSShadow *)ORSButtonBarSelectedItemShadow;
@end

@implementation NSShadow (ORSAdditions)

+ (NSShadow *)ORSButtonBarSelectedItemShadow
{
    NSShadow *result = [[NSShadow alloc] init];
    result.shadowOffset = NSMakeSize(0.0, 1.0);
    result.shadowBlurRadius = 1.0;
    result.shadowColor = [NSColor colorWithCalibratedWhite:0 alpha:0.7];
    return result;
}

@end

@interface ORSButtonBarView ()

@property (nonatomic, readwrite, strong) ORSButtonBarCell *buttonCell;
@property (nonatomic, readwrite, strong) ORSButtonBarSeparatorCell *separatorCell;

@property (nonatomic, strong, readwrite) NSArray *items;

@property (nonatomic) BOOL delegateRespondsToSelectionDidChange;

@end


@implementation ORSButtonBarView

- (void)commonInit
{
    [self setItems:[[NSMutableArray alloc] init]];
    [self setBackgroundGradient:[NSGradient grayButtonBarGradient]];
    [self setBaselineSeparatorColor:[NSColor grayColor]];
    [self setShowsBaselineSeparator:YES];
    [self setButtonCell:[[ORSButtonBarCell alloc] init]];
    [self setSeparatorCell:[[ORSButtonBarSeparatorCell alloc] init]];
    [self configureButtonCell];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
        _delegate = [decoder decodeObjectForKey:@"AMBBDelegate"];
        _delegateRespondsToSelectionDidChange = [decoder decodeBoolForKey:@"AMBBDelegateRespondsToSelectionDidChange"];
        _backgroundGradient = [decoder decodeObjectForKey:@"AMBBBackgroundNSGradient"];
        _baselineSeparatorColor = [decoder decodeObjectForKey:@"AMBBBaselineSeparatorColor"];
        _showsBaselineSeparator = [decoder decodeBoolForKey:@"AMBBShowsBaselineSeparator"];
        _allowsMultipleSelection = [decoder decodeBoolForKey:@"AMBBAllowsMultipleSelection"];
        _items = [decoder decodeObjectForKey:@"AMBBItems"];
        _buttonCell = [decoder decodeObjectForKey:@"AMBBButtonCell"];
        [self setNeedsLayout:YES];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeConditionalObject:_delegate forKey:@"AMBBDelegate"];
    [coder encodeBool:_delegateRespondsToSelectionDidChange forKey:@"AMBBDelegateRespondsToSelectionDidChange"];
    [coder encodeObject:_backgroundGradient forKey:@"AMBBBackgroundNSGradient"];
    [coder encodeObject:_baselineSeparatorColor forKey:@"AMBBBaselineSeparatorColor"];
    [coder encodeBool:_showsBaselineSeparator forKey:@"AMBBShowsBaselineSeparator"];
    [coder encodeBool:_allowsMultipleSelection forKey:@"AMBBAllowsMultipleSelection"];
    [coder encodeObject:_items forKey:@"AMBBItems"];
    [coder encodeObject:_buttonCell forKey:@"AMBBButtonCell"];
}

#pragma mark - Public

- (ORSButtonBarItem *)itemAtIndex:(int)index
{
    return self.items[index];
}

- (ORSButtonBarItem *)itemWithIdentifier:(NSString *) identifier;
{
    for (ORSButtonBarItem *item in self.items) {
        if ([[item itemIdentifier] isEqualToString: identifier])
        {
            return item;
        }
    }
    
    return nil;
}

- (NSInteger)indexOfItem: (ORSButtonBarItem *) item;
{
    if (!item) { return NSNotFound; }
    NSArray *allItems = [self.items copy];
    NSUInteger i, count = allItems.count;
    for (i = 0; i < count; i++)
    {
        ORSButtonBarItem *eachItem = allItems[i];
        if ([item isEqual:eachItem])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

- (void)insertItem:(ORSButtonBarItem *)item atIndex:(NSUInteger)index
{
    [(NSMutableArray *)[self items] insertObject:item atIndex:index];
    [item setParentButtonBar: self];
    [self setNeedsLayout:YES];
}

- (void)removeItem:(ORSButtonBarItem *)item
{
    if (item == nil) return;
    
    if ([item trackingRectTag] != 0)
    {
        //        NSLog(@"removeTrackingRect:");
        [self removeTrackingRect:[item trackingRectTag]];
    }
    if ([item tooltipTag] != 0)
    {
        [self removeToolTip: [item tooltipTag]];
    }
    [(NSMutableArray *)[self items] removeObject:item];
    [self setNeedsLayout:YES];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    [self removeItem:[self items][index]];
}

- (void)removeAllItems
{
    [self removeTrackingRects];
    [self removeToolTips];
    [(NSMutableArray *)[self items] removeAllObjects];
    [self setNeedsLayout:YES];
}

- (void)selectItemWithIdentifier:(NSString *)identifier
{
    for (ORSButtonBarItem *item in self.items) {
        if ([[item itemIdentifier] isEqualToString:identifier]) {
            [self didClickItem:item];
            break;
        }
    }
}

- (void)selectItemsWithIdentifiers:(NSArray *)identifierList
{
    if ([self allowsMultipleSelection] || (identifierList.count < 2)) {
        for (ORSButtonBarItem *item in self.items) {
            if ([identifierList containsObject:[item itemIdentifier]]) {
                [self didClickItem:item];
            }
        }
    }
}

-(BOOL) moveFocusToNextItem;
{
    NSArray *myItems = [self items];
    
    if ([self focusedItem] == nil)
    {
        return [self moveFocusToFirstItem];
    }
    
    NSUInteger indexOfCurrentFocus = [myItems indexOfObject: [self focusedItem]];
    NSUInteger i, count = myItems.count;
    for (i=indexOfCurrentFocus+1; i < count; i++)
    {
        ORSButtonBarItem *item = myItems[i];
        if (![item isSeparatorItem])
        {
            [self setFocusedItem: item];
            [self setNeedsDisplay: YES];
            return YES;
        }
    }
    
    // If we get here, there was no next item
    return NO;
}

-(BOOL) moveFocusToPreviousItem;
{
    NSArray *myItems = [self items];
    
    if ([self focusedItem] == nil)
    {
        return [self moveFocusToFirstItem];
    }
    
    NSUInteger indexOfCurrentFocus = [myItems indexOfObject: [self focusedItem]];
    if (indexOfCurrentFocus == 0) // already at the beginning
    {
        return NO;
    }
    
    NSInteger i;
    for (i=indexOfCurrentFocus-1; i >= 0; i--)
    {
        ORSButtonBarItem *item = myItems[i];
        if (![item isSeparatorItem])
        {
            [self setFocusedItem: item];
            [self setNeedsDisplay: YES];
            return YES;
        }
    }
    
    // If we get here, there was no previous item
    return NO;
}

-(BOOL) moveFocusToFirstItem;
{
    NSArray *myItems = [self items];
    if (myItems == nil) { [self setFocusedItem: nil]; return NO; }
    
    NSUInteger i, count = myItems.count;
    for (i = 0; i < count; i++)
    {
        ORSButtonBarItem *item = myItems[i];
        if (![item isSeparatorItem])
        {
            [self setFocusedItem: item];
            [self setNeedsDisplay: YES];
            return YES;
        }
    }
    
    // If we get here, there was no previous item
    return NO;
}

-(BOOL) moveFocusToLastItem;
{
    NSArray *myItems = [self items];
    if (myItems == nil) { [self setFocusedItem: nil]; return NO; }
    
    NSUInteger i, count = myItems.count;
    for (i = count-1; i > 0; i--)
    {
        ORSButtonBarItem *item = myItems[i];
        if (![item isSeparatorItem])
        {
            [self setFocusedItem: item];
            [self setNeedsDisplay: YES];
            return YES;
        }
    }
    
    // If we get here, there was no previous item
    return NO;
}

-(void) selectFocusedItem;
{
    if ([self focusedItem] == nil) return;
    
    [self selectItemWithIdentifier: [[self focusedItem] itemIdentifier]];
}

#pragma mark - Private

- (void)configureButtonCell
{
    ORSButtonBarCell *cell = [self buttonCell];
    cell.font = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]];
    cell = [self separatorCell];
    cell.font = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]];
}

- (ORSButtonBarItem *)itemAtPoint:(NSPoint)point;
{
    ORSButtonBarItem *result = nil;
    for (ORSButtonBarItem *item in self.items) {
        if (![item isSeparatorItem]) {
            NSRect frame = [item frame];
            if (NSPointInRect(point, frame)) {
                result = item;
                break;
            }
            if (frame.origin.x > point.x) {
                break;
            }
        }
    }
    return result;
}

- (NSRect)frameForItemAtIndex:(int)index
{
    return [[self items][index] frame];
}

- (void)drawItemAtIndex:(int)index
{
    [self drawItem:[self itemAtIndex:index]];
}

- (void)drawItem:(ORSButtonBarItem *)item
{
    [self prepareCellWithItem:item];
    //    NSRect frame = [item frame];
    //    NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [[self cellForItem:item] drawWithFrame:[item frame] inView:self];
}

- (void)layoutItems
{
    [self setNeedsLayout:NO];
    NSPoint origin;
    origin.y = ((self.frame.size.height-1 - AM_BUTTON_HEIGHT) / 2.0);
    if (!self.flipped) {
        origin.y += 1;
    }
    origin.x = AM_START_GAP_WIDTH;
    for (ORSButtonBarItem *item in self.items) {
        [self calculateFrameSizeForItem:item];
        [item setFrameOrigin:origin];
        origin.x += [item frame].size.width;
        origin.x += AM_BUTTON_GAP_WIDTH;
        if ([item trackingRectTag] != 0)
        {
            //            NSLog(@"removeTrackingRect:");
            [self removeTrackingRect:[item trackingRectTag]];
        }
        if ([item tooltipTag] != 0)
        {
            [self removeToolTip: [item tooltipTag]];
        }
        //        NSLog(@"setTrackingRect:");
        if (![item isSeparatorItem]) {
            [item setTrackingRectTag:[self addTrackingRect:[item frame] owner:self userData:(void *)item assumeInside:NO]];  //... should check for mouse inside
            [item setTooltipTag: [self addToolTipRect: [item frame] owner: item userData: NULL]];
        }
        
        
    }
}

- (void)removeTrackingRects
{
    for (ORSButtonBarItem *item in self.items) {
        if ([item trackingRectTag] != 0)
        {
            [self removeTrackingRect: [item trackingRectTag]];
        }
    }
}

- (void)removeToolTips
{
    for (ORSButtonBarItem *item in self.items) {
        if ([item trackingRectTag] != 0)
        {
            [self removeToolTip: [item tooltipTag]];
        }
    }
}

- (void)calculateFrameSizeForItem:(ORSButtonBarItem *)item
{
    [self prepareCellWithItem:item];
    NSRect frame = [item frame];
    frame.size.height = AM_BUTTON_HEIGHT;
    frame.size.width = [(ORSButtonBarCell *)[self cellForItem:item] widthForFrame:frame];
    [item setFrame:frame];
}

- (void)prepareCellWithItem:(ORSButtonBarItem *)item
{
    // make a working copy
    if (![item isSeparatorItem]) {
        [self buttonCell].title = [item title];
        [[self buttonCell] setMouseOver:[item isMouseOver]];
        [self buttonCell].state = [item state];
        //        [[self buttonCell] setHighlighted:([item state] == NSOnState)];
        [self buttonCell].highlighted = [item isActive];
        [self buttonCell].enabled = [item isEnabled];
        [[self buttonCell] setFocused: [[self focusedItem] isEqual: item]];
    }
}

- (NSCell *)cellForItem:(ORSButtonBarItem *)item
{
    NSCell *result;
    if ([item isSeparatorItem]) {
        result = [self separatorCell];
    } else {
        result = [self buttonCell];
    }
    return result;
}

- (void)mouseOverItem:(ORSButtonBarItem *)mouseOverItem
{
    BOOL mouseOver;
    BOOL needsRedraw;
    for (ORSButtonBarItem *item in self.items) {
        mouseOver = (item == mouseOverItem);
        needsRedraw = ([item isMouseOver] != mouseOver);
        [item setMouseOver:mouseOver];
        if (needsRedraw) {
            [self setNeedsDisplayInRect:[item frame]];
        }
    }
}

- (void)handleMouseDownForPointInWindow:(NSValue *)value
{
    BOOL done = NO;
    NSEvent *theEvent = NSApp.currentEvent;
    NSPoint point = value.pointValue;
    point = [self convertPoint:point fromView:nil];
    ORSButtonBarItem *item = [self itemAtPoint:point];
    if (item && [item isEnabled]) {
        int oldState = [item state];
        [item setState:NSOnState];
        [item setActive:YES];
        [self prepareCellWithItem:item];
        [self setNeedsDisplayInRect:[item frame]];
        [self displayIfNeeded];
        if ([[self cellForItem:item] trackMouse:theEvent inRect:[item frame] ofView:self untilMouseUp:NO]) {
            // clicked
            //[item setState:((oldState == NSOnState) ? NSOffState : NSOnState)];
            done = YES;
            //        } else {
            //            [item setState:oldState];
        }
        [item setState:oldState];
        [item setActive:NO];
        [self setNeedsDisplayInRect:[item frame]];
    }
    if (done) {
        [self didClickItem:item];
    } else {
        point = self.window.mouseLocationOutsideOfEventStream;
        [self performSelector:@selector(handleMouseDownForPointInWindow:) withObject:[NSValue valueWithPoint:point] afterDelay:0.1];
    }
}

- (void)didClickItem:(ORSButtonBarItem *)theItem
{
    BOOL didChangeSelection = NO;
    if (![self allowsMultipleSelection]) {
        if ([theItem state] == NSOffState) {
            for (ORSButtonBarItem *item in self.items) {
                [item setState:((item == theItem) ? NSOnState : NSOffState)];
            }
            [self setNeedsDisplay:YES];
            didChangeSelection = YES;
        }
    } else {
        [theItem setState:(([theItem state] == NSOnState) ? NSOffState : NSOnState)];
        [self setNeedsDisplayInRect:[theItem frame]];
        didChangeSelection = YES;
    }
    if (didChangeSelection) {
        NSNotification *notification = [NSNotification notificationWithName:ORSButtonBarSelectionDidChangeNotification object:self userInfo:@{@"selectedItems": [self selectedItemIdentifiers]}];
        NSAccessibilityPostNotification(self, NSAccessibilitySelectedChildrenChangedNotification);
        [self sendActionForItem:theItem];
        if ([self delegateRespondsToSelectionDidChange]) {
            [_delegate buttonBarSelectionDidChange:notification];
        }
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)sendActionForItem:(ORSButtonBarItem *)item
{
    if ([item target]) {
        [NSApp sendAction:[item action] to:[item target] from:item];
    }
}

#pragma mark - NSResponder Methods

- (void)mouseEntered:(NSEvent *)theEvent
{
    //NSLog(@"mouseEntered:");
    ORSButtonBarItem *item = theEvent.userData;
    if ([item isEnabled]) {
        [item setMouseOver:YES];
        [self setNeedsDisplayInRect:[item frame]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    //NSLog(@"mouseExited:");
    ORSButtonBarItem *item = theEvent.userData;
    [item setMouseOver:NO];
    [self setNeedsDisplayInRect:[item frame]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self handleMouseDownForPointInWindow:[NSValue valueWithPoint:theEvent.locationInWindow]];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // dangerous?
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *characters  = theEvent.charactersIgnoringModifiers;
    // Check to see if it's tab, shift-tab, or space, which we implement
    if ([characters isEqualToString: @"\t"]) // Tab
    {
        if (![self moveFocusToNextItem])
        {
            [super keyDown: theEvent];
        }
    }
    else if ([characters isEqualToString: @"\x19"]) // Shift tab
    {
        if (![self moveFocusToPreviousItem])
        {
            [super keyDown: theEvent];
        }
    }
    else if (theEvent.keyCode == 0x31) // Space bar
    {
        [self selectFocusedItem];
    }
    else
    {
        [super keyDown: theEvent];
    }
    
}

-(BOOL) acceptsFirstResponder;
{
    return YES;
}

- (BOOL)needsPanelToBecomeKey
{
    // We want to get focus via tabbing but not mouse down
    
    return NO;
}

-(BOOL) becomeFirstResponder;
{
    BOOL result = [super becomeFirstResponder];
    
    if (result)
    {
        NSSelectionDirection selectionDirection = self.window.keyViewSelectionDirection;
        
        if (selectionDirection==NSSelectingNext)
        {
            if (![self moveFocusToFirstItem])
            {
                // unable to focus on first item, so don't become first responder
                result = NO;
            }
        }
        else if (selectionDirection==NSSelectingPrevious)
        {
            if (![self moveFocusToLastItem])
            {
                // unable to focus on first item, so don't become first responder
                result = NO;
            }
        }
        else
        {
            // Direct selection
            
            if (![self moveFocusToFirstItem])
            {
                // unable to focus on first item, so don't become first responder
                result = NO;
            }
        }
    }
    
    return result;
}

-(BOOL) resignFirstResponder;
{
    [self setFocusedItem: nil];
    
    [self setNeedsDisplay: YES];
    
    return YES;
}

#pragma mark - NSView Methods

- (void)drawRect:(NSRect)rect
{
    NSRect gradientBounds = self.bounds;
    NSRect baselineRect = gradientBounds;
    if ([self showsBaselineSeparator]) {
        gradientBounds.size.height -= 1;
        baselineRect.size.height = 1;
        if (self.flipped) {
            baselineRect.origin.y = gradientBounds.size.height;
        } else {
            baselineRect.origin.y = 0;
            gradientBounds.origin.y += 1;
        }
    }
    float angle = 90;
    if (self.flipped) {
        angle = -90;
    }
    [[self backgroundGradient] drawInRect:gradientBounds angle:angle];
    if ([self showsBaselineSeparator]) {
        [[self baselineSeparatorColor] set];
        NSFrameRect(baselineRect);
    }
    if ([self needsLayout]) {
        [self layoutItems];
    }
    for (ORSButtonBarItem *item in self.items) {
        if (NSIntersectsRect([item frame], rect)) {
            [self drawItem:item];
        }
    }
}

- (void)viewDidMoveToWindow
{
    if (self.window)
    {
        [self setNeedsLayout:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSWindowDidResizeNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
    }
    else
    {
        [self removeTrackingRects];
        [self removeToolTips];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
    }
}

- (BOOL)postsFrameChangedNotifications
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

#pragma mark - NSView Notification Methods

- (void)frameDidChange:(NSNotification *)aNotification
{
    //NSLog(@"frameDidChange:");
    [self setNeedsLayout:YES];
}

#pragma mark - Properties

- (void)setDelegate:(id<ORSButtonBarDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        self.delegateRespondsToSelectionDidChange = [delegate respondsToSelector:@selector(buttonBarSelectionDidChange:)];
    }
}

- (void)setItems:(NSMutableArray *)newItems
{
    if (_items != newItems)
    {
        [self removeTrackingRects];
        [self removeToolTips];
        _items = newItems;
    }
}

-(ORSButtonBarItem *) selectedItem;
{
    ORSButtonBarItem *result = nil;
    for (ORSButtonBarItem *item in self.items) {
        if ([item state] == NSOnState)
        {
            result = item;
            break;
        }
    }
    return result;
}

-(NSArray *) selectedItems;
{
    NSMutableArray *result = [NSMutableArray array];
    for (ORSButtonBarItem *item in self.items) {
        if ([item state] == NSOnState)
        {
            [result addObject: item];
        }
    }
    return [result copy];
}

- (NSString *)selectedItemIdentifier
{
    return [[self selectedItem] itemIdentifier];
}

- (NSArray *)selectedItemIdentifiers
{
    NSArray *selItems = [self selectedItems];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: selItems.count];
    for (ORSButtonBarItem *item in self.items) {
        [result addObject: [item itemIdentifier]];
    }
    
    return [result copy];
}

- (void)setFocusedItem:(ORSButtonBarItem *)value
{
    if (_focusedItem != value)
    {
        _focusedItem = value;
        NSAccessibilityPostNotification(_focusedItem, NSAccessibilityFocusedUIElementChangedNotification);
    }
}

#pragma mark - NSAccessibility Methods

-(NSArray *) accessibilityAttributeNames;
{
    static NSArray *attributes=nil;
    
    if (attributes == nil)
    {
        attributes = [super accessibilityAttributeNames];
        attributes = [attributes arrayByAddingObject: NSAccessibilitySelectedChildrenAttribute];
    }
    
    return attributes;
}

-(id) accessibilityAttributeValue:(NSString *)attribute
{
    if ([attribute isEqualToString: NSAccessibilityRoleAttribute])
    {
        return [super accessibilityAttributeValue: attribute];
    }
    
    if ([attribute isEqualToString: NSAccessibilityRoleDescriptionAttribute])
    {
        return NSLocalizedString(@"Filter bar", @"Filter bar accessibility role description (for blind users)");
    }
    
    if ([attribute isEqualToString: NSAccessibilityTitleAttribute])
    {
        return nil;
    }
    
    if ([attribute isEqualToString: NSAccessibilityDescriptionAttribute])
    {
        return NSLocalizedString(@"Filter table items.", @"Filter bar accessibility description (for blind users)");
    }
    
    if ([attribute isEqualToString: NSAccessibilityChildrenAttribute])
    {
        return [self items];
    }
    
    if ([attribute isEqualToString: NSAccessibilitySelectedChildrenAttribute])
    {
        return [self selectedItems];
    }
    
    return [super accessibilityAttributeValue: attribute];
    
}

-(id) accessibilityHitTest:(NSPoint)point
{
    NSRect pointRect = NSMakeRect(point.x, point.y, 1, 1);
    NSPoint windowPoint = [self.window convertRectFromScreen:pointRect].origin;
    NSPoint localPoint = [self convertPoint: windowPoint fromView: nil];
    ORSButtonBarItem *hitItem = [self itemAtPoint: localPoint];
    
    if (hitItem == nil) return self;
    
    return hitItem;
}

-(id) accessibilityFocusedUIElement;
{
    if ([self focusedItem] == nil) return self;
    
    return [self focusedItem];
}

-(BOOL) accessibilityIsIgnored;
{
    return NO;
}

@end
