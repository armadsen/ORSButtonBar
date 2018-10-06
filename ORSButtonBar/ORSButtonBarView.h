//
//  ORSButtonBarView.h
//  ORSButtonBar
//
//  Created by Andreas on 09.02.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
//  2010-02-18  Andreas Mayer
//  - use NSGradient instead of CTGradient for 10.5 and above


#import <Cocoa/Cocoa.h>
#import "ORSButtonBarItem.h"
#import "ORSButtonBarCell.h"

@class ORSButtonBarSeparatorCell;

extern NSString *const ORSButtonBarSelectionDidChangeNotification;


@interface NSObject (ORSButtonBarDelegate)
- (void)buttonBarSelectionDidChange:(NSNotification *)aNotification;
@end


@interface ORSButtonBarView : NSView 
{
	id delegate;
	BOOL delegateRespondsToSelectionDidChange;
	NSGradient *backgroundGradient;
	NSColor *baselineSeparatorColor;
	BOOL showsBaselineSeparator;
	BOOL allowsMultipleSelection;
	NSMutableArray *items;
	ORSButtonBarCell *buttonCell;
	ORSButtonBarSeparatorCell *separatorCell;
	BOOL needsLayout;
	
	ORSButtonBarItem *focusedItem;
}


- (id)initWithFrame:(NSRect)frame;

- (ORSButtonBarCell *)buttonCell;
- (ORSButtonBarSeparatorCell *)separatorCell;

- (NSArray *)items;

-(ORSButtonBarItem *) selectedItem;
-(NSArray *) selectedItems;

- (NSString *)selectedItemIdentifier;
- (NSArray *)selectedItemIdentifiers;

- (ORSButtonBarItem *)itemAtIndex:(int)index;
- (ORSButtonBarItem *)itemWithIdentifier:(NSString *) identifier;
- (NSInteger)indexOfItem: (ORSButtonBarItem *) item;

- (void)insertItem:(ORSButtonBarItem *)item atIndex:(NSUInteger)index;

- (void)removeItem:(ORSButtonBarItem *)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeAllItems;

- (void)selectItemWithIdentifier:(NSString *)identifier;
- (void)selectItemsWithIdentifiers:(NSArray *)identifierList;

-(BOOL) moveFocusToNextItem;
-(BOOL) moveFocusToPreviousItem;
-(BOOL) moveFocusToFirstItem;
-(BOOL) moveFocusToLastItem;

- (id)delegate;
- (void)setDelegate:(id)value;

- (BOOL)allowsMultipleSelection;
- (void)setAllowsMultipleSelection:(BOOL)value;

- (NSGradient *)backgroundGradient;
- (void)setBackgroundGradient:(NSGradient *)value;

- (NSColor *)baselineSeparatorColor;
- (void)setBaselineSeparatorColor:(NSColor *)value;

- (BOOL)showsBaselineSeparator;
- (void)setShowsBaselineSeparator:(BOOL)value;

- (BOOL)needsLayout;
- (void)setNeedsLayout:(BOOL)value;

- (ORSButtonBarItem *)focusedItem;
- (void)setFocusedItem:(ORSButtonBarItem *)value;

@end
