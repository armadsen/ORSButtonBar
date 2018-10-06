//
//  ORSButtonBarItem.m
//  ORSButtonBar
//
//  Created by Andreas on 09.02.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

#import "ORSButtonBarItem.h"
#import "ORSButtonBarView.h"

@implementation ORSButtonBarItem

- (instancetype)init
{
    [NSException raise:NSInternalInconsistencyException format:@"Use -initWithIdentifier:"];
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)theIdentifier;
{
    self = [super init];
    if (self != nil) {
        [self setItemIdentifier:theIdentifier];
        [self setFrame:NSZeroRect];
        [self setEnabled:YES];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *identifier = [decoder decodeObjectForKey:@"AMBBIItemIdentifier"];
    self = [self initWithIdentifier:identifier];
    if (self) {
        toolTip = [decoder decodeObjectForKey:@"AMBBIToolTip"];
        title = [decoder decodeObjectForKey:@"AMBBITitle"];
        alternateTitle = [decoder decodeObjectForKey:@"AMBBIAlternateTitle"];
        target = [decoder decodeObjectForKey:@"AMBBITarget"];
        action = NSSelectorFromString([decoder decodeObjectForKey:@"AMBBISelector"]);
        enabled = [decoder decodeBoolForKey:@"AMBBISelector"];
        active = [decoder decodeBoolForKey:@"AMBBIActive"];
        separatorItem = [decoder decodeBoolForKey:@"AMBBISeparatorItem"];
        overflowItem = [decoder decodeBoolForKey:@"AMBBIOverflowItem"];
        state = [decoder decodeIntForKey:@"AMBBIState"];
        tag = [decoder decodeIntForKey:@"AMBBITag"];
        frame = [decoder decodeRectForKey:@"AMBBIFrame"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:itemIdentifier forKey:@"AMBBIItemIdentifier"];
    [coder encodeObject:toolTip forKey:@"AMBBIToolTip"];
    [coder encodeObject:title forKey:@"AMBBITitle"];
    [coder encodeObject:alternateTitle forKey:@"AMBBIAlternateTitle"];
    [coder encodeConditionalObject:target forKey:@"AMBBITarget"];
    [coder encodeObject:NSStringFromSelector(action) forKey:@"AMBBISelector"];
    [coder encodeBool:enabled forKey:@"AMBBISelector"];
    [coder encodeBool:active forKey:@"AMBBIActive"];
    [coder encodeBool:separatorItem forKey:@"AMBBISeparatorItem"];
    [coder encodeBool:overflowItem forKey:@"AMBBIOverflowItem"];
    [coder encodeInt:state forKey:@"AMBBIState"];
    [coder encodeInt:tag forKey:@"AMBBITag"];
    [coder encodeRect:frame forKey:@"AMBBIFrame"];
}




- (id)target
{
    return target;
}

- (void)setTarget:(id)value
{
    if (target != value) {
        id old = target;
        target = value;
    }
}

- (SEL)action
{
    return action;
}

- (void)setAction:(SEL)value
{
    if (action != value) {
        action = value;
    }
}

- (BOOL)isEnabled
{
    return enabled;
}

- (void)setEnabled:(BOOL)value
{
    if ((enabled != value) && (![self isSeparatorItem])) {
        enabled = value;
    }
}

- (BOOL)isMouseOver
{
    return mouseOver;
}

- (void)setMouseOver:(BOOL)value
{
    if ((mouseOver != value) && (![self isSeparatorItem])) {
        mouseOver = value;
    }
}

- (BOOL)isActive
{
    return active;
}

- (void)setActive:(BOOL)value
{
    if ((active != value) && (![self isSeparatorItem])) {
        active = value;
    }
}

- (BOOL)isSeparatorItem
{
    return separatorItem;
}

- (void)setSeparatorItem:(BOOL)value
{
    if (separatorItem != value) {
        separatorItem = value;
    }
}

- (BOOL)isOverflowItem
{
    return overflowItem;
}

- (void)setOverflowItem:(BOOL)value
{
    if (overflowItem != value) {
        overflowItem = value;
    }
}

- (int)state
{
    return state;
}

- (void)setState:(int)value
{
    if (state != value) {
        state = value;
    }
}

- (NSString *)itemIdentifier
{
    return itemIdentifier;
}

- (void)setItemIdentifier:(NSString *)value
{
    if (itemIdentifier != value) {
        id old = itemIdentifier;
        itemIdentifier = value;
    }
}

- (int)tag
{
    return tag;
}

- (void)setTag:(int)value
{
    if (tag != value) {
        tag = value;
    }
}

- (NSString *)toolTip
{
    return toolTip;
}

- (void)setToolTip:(NSString *)value
{
    if (toolTip != value) {
        id old = toolTip;
        toolTip = [value copy];
    }
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
    NSString *result = [self toolTip];
    if (result == nil) result = [self title];
    if (result == nil) result = self.description;
    
    return result;
}

- (NSString *)title
{
    return title;
}

- (void)setTitle:(NSString *)value
{
    if (title != value) {
        id old = title;
        title = value;
        
        if ([[self parentButtonBar] respondsToSelector: @selector(setNeedsLayout:)])
        {
            [[self parentButtonBar] setNeedsLayout: YES];
        }
    }
}

- (NSString *)alternateTitle
{
    return alternateTitle;
}

- (void)setAlternateTitle:(NSString *)value
{
    if (alternateTitle != value) {
        id old = alternateTitle;
        alternateTitle = value;
    }
}

- (NSMenu *)overflowMenu
{
    return overflowMenu;
}

- (void)setOverflowMenu:(NSMenu *)value
{
    if (overflowMenu != value) {
        id old = overflowMenu;
        overflowMenu = value;
    }
}

- (NSTrackingRectTag)trackingRectTag
{
    return trackingRectTag;
}

- (void)setTrackingRectTag:(NSTrackingRectTag)value
{
    trackingRectTag = value;
}

- (NSToolTipTag)tooltipTag 
{
    return tooltipTag;
}

- (void)setTooltipTag:(NSToolTipTag)value 
{
    if (tooltipTag != value)
    {
        tooltipTag = value;
    }
}

- (NSRect)frame
{
    return frame;
}

- (void)setFrame:(NSRect)value
{
    frame = value;
}

- (void)setFrameOrigin:(NSPoint)origin
{
    frame.origin = origin;
}

- (ORSButtonBarView *)parentButtonBar 
{
    return parentButtonBar;
}

- (void)setParentButtonBar:(ORSButtonBarView *)value 
{
    parentButtonBar = value;
}

#pragma mark -
#pragma mark NSAccessibility Methods

-(NSArray *) accessibilityAttributeNames;
{
    static NSArray *attributes=nil;
    
    if (attributes == nil)
    {
        attributes = [[NSArray alloc] initWithObjects: NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityTitleAttribute, NSAccessibilityTitleAttribute, NSAccessibilityParentAttribute, nil];
    }
    
    return attributes;
}

-(id) accessibilityAttributeValue:(NSString *)attribute
{
    if ([attribute isEqualToString: NSAccessibilityRoleAttribute])
    {
        return NSAccessibilityButtonRole;
        //return @"Filter Button";
    }
    
    if ([attribute isEqualToString: NSAccessibilityRoleDescriptionAttribute])
    {
        NSAccessibilityRoleDescription(NSAccessibilityButtonRole, nil);
        //return NSLocalizedString(@"Filter bar button", @"Filter bar button accessibility role description (for blind users)");
    }
    
    if ([attribute isEqualToString: NSAccessibilityTitleAttribute])
    {
        return [self title];
    }
    
    if ([attribute isEqualToString: NSAccessibilityDescriptionAttribute])
    {
        return NSLocalizedString(@"Filter table items.", @"Filter bar accessibility description (for blind users)");
    }
    
    if ([attribute isEqualToString: NSAccessibilityParentAttribute])
    {
        return [self parentButtonBar];
    }
    
    return nil;
}

-(NSArray *) accessibilityActionNames;
{
    static NSArray *actions=nil;
    
    if (actions == nil)
    {
        actions = [[NSArray alloc] initWithObjects: NSAccessibilityPressAction, nil];
    }
    
    return actions;
}

-(NSString *) accessibilityActionDescription:(NSString *)theAction
{
    if (![theAction isEqualToString: NSAccessibilityPressAction]) return nil;
    
    return NSLocalizedString(@"Press", @"Press (as in ""Press a button""");
}

-(void)accessibilityPerformAction:(NSString *) anAction
{
    if (![anAction isEqualToString: NSAccessibilityPressAction]) return;
    
    [[self parentButtonBar] selectItemWithIdentifier: [self itemIdentifier]];
}

-(BOOL) accessibilityIsIgnored;
{
    if ([self isSeparatorItem]) return YES;
    
    return NO;
}

@end
