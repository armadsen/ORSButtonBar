//
//  AMButtonBar.h
//  ButtonBarTest
//
//  Created by Andreas on 09.02.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
//  2010-02-18  Andreas Mayer
//  - use NSGradient instead of CTGradient for 10.5 and above


#import <Cocoa/Cocoa.h>
#import "AMButtonBarItem.h"
#import "AMButtonBarCell.h"
#import "AMButtonBarSeparatorCell.h"


extern NSString *const AMButtonBarSelectionDidChangeNotification;


@interface NSObject (AMButtonBarDelegate)
- (void)buttonBarSelectionDidChange:(NSNotification *)aNotification;
@end


@interface AMButtonBar : NSView 
{
	id delegate;
	BOOL delegateRespondsToSelectionDidChange;
	NSGradient *backgroundGradient;
	NSColor *baselineSeparatorColor;
	BOOL showsBaselineSeparator;
	BOOL allowsMultipleSelection;
	NSMutableArray *items;
	AMButtonBarCell *buttonCell;
	AMButtonBarSeparatorCell *separatorCell;
	BOOL needsLayout;
	
	AMButtonBarItem *focusedItem;
}


- (id)initWithFrame:(NSRect)frame;

- (AMButtonBarCell *)buttonCell;
- (AMButtonBarSeparatorCell *)separatorCell;

- (NSArray *)items;

-(AMButtonBarItem *) selectedItem;
-(NSArray *) selectedItems;

- (NSString *)selectedItemIdentifier;
- (NSArray *)selectedItemIdentifiers;

- (AMButtonBarItem *)itemAtIndex:(int)index;
- (AMButtonBarItem *)itemWithIdentifier:(NSString *) identifier;
- (NSInteger)indexOfItem: (AMButtonBarItem *) item;

- (void)insertItem:(AMButtonBarItem *)item atIndex:(NSUInteger)index;

- (void)removeItem:(AMButtonBarItem *)item;
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

- (AMButtonBarItem *)focusedItem;
- (void)setFocusedItem:(AMButtonBarItem *)value;

@end
