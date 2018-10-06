//
//	ORSButtonBar.m
//  ORSButtonBar
//
//	Created by Andreas on 09.02.07.
//	Copyright 2007 Andreas Mayer. All rights reserved.
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
	NSShadow *result = [[[NSShadow alloc] init] autorelease];
	[result setShadowOffset:NSMakeSize(0.0, 1.0)];
	[result setShadowBlurRadius:1.0];
	[result setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.7]];
	return result;
}

@end


@interface ORSButtonBarView (Private)
- (void)am_commonInit;
- (void)setItems:(NSMutableArray *)newItems;
- (BOOL)delegateRespondsToSelectionDidChange;
- (void)setDelegateRespondsToSelectionDidChange:(BOOL)value;
- (void)setButtonCell:(ORSButtonBarCell *)value;
- (void)setSeparatorCell:(ORSButtonBarSeparatorCell *)value;
- (void)configureButtonCell;
- (ORSButtonBarItem *)itemAtPoint:(NSPoint)point;
- (NSRect)frameForItemAtIndex:(int)index;
- (void)drawItemAtIndex:(int)index;
- (void)drawItem:(ORSButtonBarItem *)item;
- (void)layoutItems;
- (void)removeTrackingRects;
- (void)removeToolTips;
- (void)calculateFrameSizeForItem:(ORSButtonBarItem *)item;
- (void)prepareCellWithItem:(ORSButtonBarItem *)item;
- (NSCell *)cellForItem:(ORSButtonBarItem *)item;
- (void)handleMouseDownForPointInWindow:(NSValue *)value;
- (void)didClickItem:(ORSButtonBarItem *)item;
- (void)sendActionForItem:(ORSButtonBarItem *)item;
@end


@implementation ORSButtonBarView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self am_commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	[self am_commonInit];
	delegate = [decoder decodeObjectForKey:@"AMBBDelegate"];
	delegateRespondsToSelectionDidChange = [decoder decodeBoolForKey:@"AMBBDelegateRespondsToSelectionDidChange"];
	[self setBackgroundGradient:[decoder decodeObjectForKey:@"AMBBBackgroundNSGradient"]];
	[self setBaselineSeparatorColor:[decoder decodeObjectForKey:@"AMBBBaselineSeparatorColor"]];
	showsBaselineSeparator = [decoder decodeBoolForKey:@"AMBBShowsBaselineSeparator"];
	allowsMultipleSelection = [decoder decodeBoolForKey:@"AMBBAllowsMultipleSelection"];
	[self setItems:[decoder decodeObjectForKey:@"AMBBItems"]];
	[self setButtonCell:[decoder decodeObjectForKey:@"AMBBButtonCell"]];
	[self setNeedsLayout:YES];
	return self;
}

- (void)am_commonInit
{
	[self setItems:[[[NSMutableArray alloc] init] autorelease]];
	[self setBackgroundGradient:[NSGradient grayButtonBarGradient]];
	//[self setBackgroundGradient:[CTGradient blueButtonBarGradient]];
	[self setBaselineSeparatorColor:[NSColor grayColor]];
	[self setShowsBaselineSeparator:YES];
	[self setButtonCell:[[[ORSButtonBarCell alloc] init] autorelease]];
	[self setSeparatorCell:[[[ORSButtonBarSeparatorCell alloc] init] autorelease]];
	[self configureButtonCell];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeConditionalObject:delegate forKey:@"AMBBDelegate"];
	[coder encodeBool:delegateRespondsToSelectionDidChange forKey:@"AMBBDelegateRespondsToSelectionDidChange"];
	[coder encodeObject:backgroundGradient forKey:@"AMBBBackgroundNSGradient"];
	[coder encodeObject:baselineSeparatorColor forKey:@"AMBBBaselineSeparatorColor"];
	[coder encodeBool:showsBaselineSeparator forKey:@"AMBBShowsBaselineSeparator"];
	[coder encodeBool:allowsMultipleSelection forKey:@"AMBBAllowsMultipleSelection"];
	[coder encodeObject:items forKey:@"AMBBItems"];
	[coder encodeObject:buttonCell forKey:@"AMBBButtonCell"];
}


- (void)dealloc
{
	[backgroundGradient release];
	[baselineSeparatorColor release];
	[items release];
	[buttonCell release];
	[separatorCell release];
	
	[focusedItem release];
	[super dealloc];
}


//====================================================================
#pragma mark 		accessors
//====================================================================

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)value
{
	// do not retain delegate
	delegate = value;
	[self setDelegateRespondsToSelectionDidChange:[delegate respondsToSelector:@selector(buttonBarSelectionDidChange:)]];
}

- (BOOL)allowsMultipleSelection
{
	return allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)value
{
	if (allowsMultipleSelection != value) {
		allowsMultipleSelection = value;
	}
}

- (NSGradient *)backgroundGradient
{
	return backgroundGradient;
}

- (void)setBackgroundGradient:(NSGradient *)value
{
	if (backgroundGradient != value) {
		id old = backgroundGradient;
		backgroundGradient = [value retain];
		[old release];
	}
}

- (NSColor *)baselineSeparatorColor
{
	return baselineSeparatorColor;
}

- (void)setBaselineSeparatorColor:(NSColor *)value
{
	if (baselineSeparatorColor != value) {
		id old = baselineSeparatorColor;
		baselineSeparatorColor = [value retain];
		[old release];
	}
}

- (BOOL)showsBaselineSeparator
{
	return showsBaselineSeparator;
}

- (void)setShowsBaselineSeparator:(BOOL)value
{
	if (showsBaselineSeparator != value) {
		showsBaselineSeparator = value;
	}
}

- (NSArray *)items
{
	return [[items retain] autorelease];
}

- (void)setItems:(NSMutableArray *)newItems
{
	if (items != newItems) 
	 {
		[self removeTrackingRects];
		[self removeToolTips];
		id old = items;
		items = [newItems retain];
		[old release];
	}
}

-(ORSButtonBarItem *) selectedItem;
{
	ORSButtonBarItem *result = nil;
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) 
	 {
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
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) 
	 {
		if ([item state] == NSOnState) 
		 {
			[result addObject: item];
		 }
	 }
	return [[result copy] autorelease];	
}

- (NSString *)selectedItemIdentifier
{
	return [[self selectedItem] itemIdentifier];
}

- (NSArray *)selectedItemIdentifiers
{
	NSArray *selItems = [self selectedItems];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity: [selItems count]];
	NSEnumerator *itemsEnumerator = [selItems objectEnumerator];
	ORSButtonBarItem *eachItem=nil;
	
	while ((eachItem = [itemsEnumerator nextObject]))
	 {
		[result addObject: [eachItem itemIdentifier]];
	 }
	
	return [[result copy] autorelease];
}

- (ORSButtonBarCell *)buttonCell
{
	return buttonCell;
}

- (void)setButtonCell:(ORSButtonBarCell *)value
{
	if (buttonCell != value) {
		id old = buttonCell;
		buttonCell = [value retain];
		[old release];
	}
}

- (ORSButtonBarSeparatorCell *)separatorCell
{
	return separatorCell;
}

- (void)setSeparatorCell:(ORSButtonBarSeparatorCell *)value
{
	if (separatorCell != value) {
		id old = separatorCell;
		separatorCell = [value retain];
		[old release];
	}
}

- (BOOL)delegateRespondsToSelectionDidChange
{
	return delegateRespondsToSelectionDidChange;
}

- (void)setDelegateRespondsToSelectionDidChange:(BOOL)value
{
	delegateRespondsToSelectionDidChange = value;
}

- (BOOL)needsLayout
{
	return needsLayout;
}

- (void)setNeedsLayout:(BOOL)value
{
	if (needsLayout != value) {
		needsLayout = value;
	}
}

- (ORSButtonBarItem *)focusedItem 
{
    return focusedItem;
}

- (void)setFocusedItem:(ORSButtonBarItem *)value 
{
    if (focusedItem != value) 
	 {
        [focusedItem release];
        focusedItem = [value retain];
		
		NSAccessibilityPostNotification(focusedItem, NSAccessibilityFocusedUIElementChangedNotification);
	 }
}


//====================================================================
#pragma mark 		public methods
//====================================================================

- (ORSButtonBarItem *)itemAtIndex:(int)index
{
	return [(NSMutableArray *)[self items] objectAtIndex:index];
}

- (ORSButtonBarItem *)itemWithIdentifier:(NSString *) identifier;
{
	NSEnumerator *itemsEnumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *eachItem=nil;
	
	while ((eachItem = [itemsEnumerator nextObject]))
	 {
		if ([[eachItem itemIdentifier] isEqualToString: identifier])
		 {
			return eachItem;
		 }
	 }
	
	return nil;
}

- (NSInteger)indexOfItem: (ORSButtonBarItem *) item;
{
	NSArray *allItems = [self items];
	
	NSUInteger i, count = [allItems count];
	for (i = 0; i < count; i++)
	 {
		ORSButtonBarItem *eachItem = [allItems objectAtIndex:i];
		if ([eachItem isEqual: item])
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
		//		NSLog(@"removeTrackingRect:");
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
	[self removeItem:[[self items] objectAtIndex:index]];
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
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) {
		if ([[item itemIdentifier] isEqualToString:identifier]) {
			[self didClickItem:item];
			break;
		}
	}
}

- (void)selectItemsWithIdentifiers:(NSArray *)identifierList
{
	if ([self allowsMultipleSelection] || ([identifierList count] < 2)) {
		NSEnumerator *enumerator = [[self items] objectEnumerator];
		ORSButtonBarItem *item;
		while ((item = [enumerator nextObject])) {
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
	NSUInteger i, count = [myItems count];
	for (i=indexOfCurrentFocus+1; i < count; i++)
	 {
		ORSButtonBarItem *eachItem = [myItems objectAtIndex:i];
		if (![eachItem isSeparatorItem])
		 {
			[self setFocusedItem: eachItem];
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
		ORSButtonBarItem *eachItem = [myItems objectAtIndex:i];
		if (![eachItem isSeparatorItem])
		 {
			[self setFocusedItem: eachItem];
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
	
	NSUInteger i, count = [myItems count];
	for (i = 0; i < count; i++)
	 {
		ORSButtonBarItem *eachItem = [myItems objectAtIndex:i];
		if (![eachItem isSeparatorItem])
		 {
			[self setFocusedItem: eachItem];
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
	
	NSUInteger i, count = [myItems count];
	for (i = count-1; i > 0; i--)
	 {
		ORSButtonBarItem *eachItem = [myItems objectAtIndex:i];
		if (![eachItem isSeparatorItem])
		 {
			[self setFocusedItem: eachItem];
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


//====================================================================
#pragma mark 		private methods
//====================================================================

- (void)configureButtonCell
{
	ORSButtonBarCell *cell = [self buttonCell];
	[cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
	cell = [self separatorCell];
	[cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
}

- (ORSButtonBarItem *)itemAtPoint:(NSPoint)point;
{
	ORSButtonBarItem *result = nil;
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) {
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
	return [[[self items] objectAtIndex:index] frame];
}

- (void)drawItemAtIndex:(int)index
{
	[self drawItem:[self itemAtIndex:index]];
}

- (void)drawItem:(ORSButtonBarItem *)item
{
	[self prepareCellWithItem:item];
	//	NSRect frame = [item frame];
	//	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	[[self cellForItem:item] drawWithFrame:[item frame] inView:self];
}

- (void)layoutItems
{
	[self setNeedsLayout:NO];
	NSPoint origin;
	origin.y = (([self frame].size.height-1 - AM_BUTTON_HEIGHT) / 2.0);
	if (![self isFlipped]) {
		origin.y += 1;
	}
	origin.x = AM_START_GAP_WIDTH;
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) {
		[self calculateFrameSizeForItem:item];
		[item setFrameOrigin:origin];
		origin.x += [item frame].size.width;
		origin.x += AM_BUTTON_GAP_WIDTH;
		if ([item trackingRectTag] != 0) 
		 {
			//			NSLog(@"removeTrackingRect:");
			[self removeTrackingRect:[item trackingRectTag]];
		 }
		if ([item tooltipTag] != 0)
		 {
			[self removeToolTip: [item tooltipTag]];
		 }
		//		NSLog(@"setTrackingRect:");
		if (![item isSeparatorItem]) {
			[item setTrackingRectTag:[self addTrackingRect:[item frame] owner:self userData:(void *)item assumeInside:NO]];  //... should check for mouse inside
			[item setTooltipTag: [self addToolTipRect: [item frame] owner: item userData: NULL]];
		}
		
		
	}
}

- (void)removeTrackingRects
{
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	id item;
	while ((item = [enumerator nextObject])) 
	 {
		if ([item trackingRectTag] != 0) 
		 {
			[self removeTrackingRect: [item trackingRectTag]];
		 }
	 }
}

- (void)removeToolTips
{
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	id item;
	while ((item = [enumerator nextObject])) 
	 {
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
		[[self buttonCell] setTitle:[item title]];
		[[self buttonCell] setMouseOver:[item isMouseOver]];
		[[self buttonCell] setState:[item state]];
		//		[[self buttonCell] setHighlighted:([item state] == NSOnState)];
		[[self buttonCell] setHighlighted:[item isActive]];
		[[self buttonCell] setEnabled:[item isEnabled]];
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
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	ORSButtonBarItem *item;
	while ((item = [enumerator nextObject])) {
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
	NSEvent *theEvent = [NSApp currentEvent];
	NSPoint point = [value pointValue];
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
			//		} else {
			//			[item setState:oldState];
		}
		[item setState:oldState];
		[item setActive:NO];
		[self setNeedsDisplayInRect:[item frame]];
	}
	if (done) {
		[self didClickItem:item];
	} else {
		point = [[self window] mouseLocationOutsideOfEventStream];
		[self performSelector:@selector(handleMouseDownForPointInWindow:) withObject:[NSValue valueWithPoint:point] afterDelay:0.1];
	}
}

- (void)didClickItem:(ORSButtonBarItem *)theItem
{
	BOOL didChangeSelection = NO;
	if (![self allowsMultipleSelection]) {
		if ([theItem state] == NSOffState) {
			NSEnumerator *enumerator = [[self items] objectEnumerator];
			ORSButtonBarItem *item;
			while ((item = [enumerator nextObject])) {
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
		NSNotification *notification = [NSNotification notificationWithName:ORSButtonBarSelectionDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:[self selectedItemIdentifiers] forKey:@"selectedItems"]];
		NSAccessibilityPostNotification(self, NSAccessibilitySelectedChildrenChangedNotification);
		[self sendActionForItem:theItem];
		if ([self delegateRespondsToSelectionDidChange]) {
			[delegate buttonBarSelectionDidChange:notification];
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


//====================================================================
#pragma mark 		NSResponder methods
//====================================================================

- (void)mouseEntered:(NSEvent *)theEvent
{
	//NSLog(@"mouseEntered:");
	ORSButtonBarItem *item = [theEvent userData];
	if ([item isEnabled]) {
		[item setMouseOver:YES];
		[self setNeedsDisplayInRect:[item frame]];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	//NSLog(@"mouseExited:");
	ORSButtonBarItem *item = [theEvent userData];
	[item setMouseOver:NO];
	[self setNeedsDisplayInRect:[item frame]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self handleMouseDownForPointInWindow:[NSValue valueWithPoint:[theEvent locationInWindow]]];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self]; // dangerous?
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *characters  = [theEvent charactersIgnoringModifiers];
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
	else if ([theEvent keyCode] == 0x31) // Space bar
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
		NSSelectionDirection selectionDirection = [[self window] keyViewSelectionDirection];
		
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

//====================================================================
#pragma mark 		NSView methods
//====================================================================

- (void)drawRect:(NSRect)rect
{
	NSRect gradientBounds = [self bounds];
	NSRect baselineRect = gradientBounds;
	if ([self showsBaselineSeparator]) {
		gradientBounds.size.height -= 1;
		baselineRect.size.height = 1;
		if ([self isFlipped]) {
			baselineRect.origin.y = gradientBounds.size.height;
		} else {
			baselineRect.origin.y = 0;
			gradientBounds.origin.y += 1;
		}
	}
	float angle = 90;
	if ([self isFlipped]) {
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
	NSEnumerator *enumerator = [[self items] objectEnumerator];
	id item;
	while ((item = [enumerator nextObject])) {
		if (NSIntersectsRect([item frame], rect)) {
			[self drawItem:item];
		}
	}
}

- (void)viewDidMoveToWindow
{
	if ([self window]) 
	 {
		[self setNeedsLayout:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSWindowDidResizeNotification object:[self window]];
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


//====================================================================
#pragma mark 		NSView notification methods
//====================================================================

- (void)frameDidChange:(NSNotification *)aNotification
{
	//NSLog(@"frameDidChange:");
	[self setNeedsLayout:YES]; 
}


#pragma mark -
#pragma mark NSAccessibility Methods

-(NSArray *) accessibilityAttributeNames;
{
	static NSArray *attributes=nil;
	
	if (attributes == nil)
	 {
		attributes = [super accessibilityAttributeNames];
		attributes = [attributes arrayByAddingObject: NSAccessibilitySelectedChildrenAttribute];
		[attributes retain];
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
	NSPoint windowPoint = [[self window] convertRectFromScreen:pointRect].origin;
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
