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

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *identifier = [decoder decodeObjectForKey:@"AMBBIItemIdentifier"];
    self = [self initWithIdentifier:identifier];
    if (self) {
        _toolTip = [decoder decodeObjectForKey:@"AMBBIToolTip"];
        _title = [decoder decodeObjectForKey:@"AMBBITitle"];
        _alternateTitle = [decoder decodeObjectForKey:@"AMBBIAlternateTitle"];
        _target = [decoder decodeObjectForKey:@"AMBBITarget"];
        _action = NSSelectorFromString([decoder decodeObjectForKey:@"AMBBISelector"]);
        _enabled = [decoder decodeBoolForKey:@"AMBBISelector"];
        _active = [decoder decodeBoolForKey:@"AMBBIActive"];
        _separatorItem = [decoder decodeBoolForKey:@"AMBBISeparatorItem"];
        _overflowItem = [decoder decodeBoolForKey:@"AMBBIOverflowItem"];
        _state = [decoder decodeIntForKey:@"AMBBIState"];
        _tag = [decoder decodeIntForKey:@"AMBBITag"];
        _frame = [decoder decodeRectForKey:@"AMBBIFrame"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_itemIdentifier forKey:@"AMBBIItemIdentifier"];
    [coder encodeObject:_toolTip forKey:@"AMBBIToolTip"];
    [coder encodeObject:_title forKey:@"AMBBITitle"];
    [coder encodeObject:_alternateTitle forKey:@"AMBBIAlternateTitle"];
    [coder encodeConditionalObject:_target forKey:@"AMBBITarget"];
    [coder encodeObject:NSStringFromSelector(_action) forKey:@"AMBBISelector"];
    [coder encodeBool:_enabled forKey:@"AMBBISelector"];
    [coder encodeBool:_active forKey:@"AMBBIActive"];
    [coder encodeBool:_separatorItem forKey:@"AMBBISeparatorItem"];
    [coder encodeBool:_overflowItem forKey:@"AMBBIOverflowItem"];
    [coder encodeInt:_state forKey:@"AMBBIState"];
    [coder encodeInt:_tag forKey:@"AMBBITag"];
    [coder encodeRect:_frame forKey:@"AMBBIFrame"];
}

#pragma mark - Properties

- (void)setMouseOver:(BOOL)value
{
    if ((_mouseOver != value) && (![self isSeparatorItem])) {
        _mouseOver = value;
    }
}

- (void)setActive:(BOOL)value
{
    if ((_active != value) && (![self isSeparatorItem])) {
        _active = value;
    }
}


- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
    NSString *result = [self toolTip];
    if (result == nil) result = [self title];
    if (result == nil) result = self.description;
    
    return result;
}

- (void)setTitle:(NSString *)value
{
    if (_title != value) {
        _title = value;
        
        if ([self.parentButtonBar respondsToSelector:@selector(setNeedsLayout:)]) {
            [self.parentButtonBar setNeedsLayout: YES];
        }
    }
}

- (void)setFrameOrigin:(NSPoint)origin
{
    _frame.origin = origin;
}

#pragma mark - NSAccessibility Methods

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
        return self.parentButtonBar;
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
    
    [self.parentButtonBar selectItemWithIdentifier: [self itemIdentifier]];
}

-(BOOL) accessibilityIsIgnored;
{
    if ([self isSeparatorItem]) return YES;
    
    return NO;
}

@end
