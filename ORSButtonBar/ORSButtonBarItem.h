//
//  ORSButtonBarItem.h
//  ORSButtonBar
//
//  Created by Andreas on 09.02.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

//  tool tips and special items like separators and overflow menus are not yet supported


#import <Cocoa/Cocoa.h>

@class ORSButtonBarView;

@interface ORSButtonBarItem : NSObject <NSCoding> {
    id target;
    SEL action;
    BOOL enabled;
    BOOL mouseOver;
    BOOL active;
    BOOL separatorItem;
    BOOL overflowItem;
    int state;
    NSString *itemIdentifier;
    int tag;
    NSString *toolTip;
    NSString *title;
    NSString *alternateTitle;
    NSMenu *overflowMenu;
    NSRect frame;
    NSTrackingRectTag trackingRectTag;
    NSToolTipTag tooltipTag;
    
    ORSButtonBarView *parentButtonBar;
}

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isMouseOver) BOOL mouseOver;
@property (nonatomic, getter=isActive) BOOL active;
@property (nonatomic, getter=isSeparatorItem) BOOL separatorItem;
@property (nonatomic, getter=isOverflowItem) BOOL overflowItem;
@property (nonatomic) int state;
@property (nonatomic, copy) NSString *itemIdentifier;
@property (nonatomic) int tag;
@property (nonatomic, copy) NSString *toolTip;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *alternateTitle;
@property (nonatomic, copy) NSMenu *overflowMenu;
@property (nonatomic) NSTrackingRectTag trackingRectTag;
@property (nonatomic) NSToolTipTag tooltipTag;
@property (nonatomic) NSRect frame;

- (void)setFrameOrigin:(NSPoint)origin;
@property (nonatomic, strong) ORSButtonBarView *parentButtonBar;

@end
