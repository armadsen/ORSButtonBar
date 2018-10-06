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

@protocol ORSButtonBarDelegate <NSObject>

- (void)buttonBarSelectionDidChange:(NSNotification *)aNotification;

@end

@interface ORSButtonBarView : NSView

- (instancetype)initWithFrame:(NSRect)frame;

@property (nonatomic, readonly, strong) ORSButtonBarCell *buttonCell;
@property (nonatomic, readonly, strong) ORSButtonBarSeparatorCell *separatorCell;

@property (nonatomic, strong, readonly) NSArray *items;

@property (nonatomic, readonly, strong) ORSButtonBarItem *selectedItem;
@property (nonatomic, readonly, copy) NSArray *selectedItems;

@property (nonatomic, readonly, copy) NSString *selectedItemIdentifier;
@property (nonatomic, readonly, copy) NSArray *selectedItemIdentifiers;

- (ORSButtonBarItem *)itemAtIndex:(int)index;
- (ORSButtonBarItem *)itemWithIdentifier:(NSString *) identifier;
- (NSInteger)indexOfItem: (ORSButtonBarItem *) item;

- (void)insertItem:(ORSButtonBarItem *)item atIndex:(NSUInteger)index;

- (void)removeItem:(ORSButtonBarItem *)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeAllItems;

- (void)selectItemWithIdentifier:(NSString *)identifier;
- (void)selectItemsWithIdentifiers:(NSArray *)identifierList;

@property (nonatomic, readonly) BOOL moveFocusToNextItem;
@property (nonatomic, readonly) BOOL moveFocusToPreviousItem;
@property (nonatomic, readonly) BOOL moveFocusToFirstItem;
@property (nonatomic, readonly) BOOL moveFocusToLastItem;

@property (nonatomic, weak) id<ORSButtonBarDelegate> delegate;

@property (nonatomic) BOOL allowsMultipleSelection;

@property (nonatomic, copy) NSGradient *backgroundGradient;
@property (nonatomic, copy) NSColor *baselineSeparatorColor;
@property (nonatomic) BOOL showsBaselineSeparator;
@property (nonatomic) BOOL needsLayout;

@property (nonatomic, strong) ORSButtonBarItem *focusedItem;

@end
