//
//  ORSButtonBarCell.h
//  ORSButtonBar
//
//  Created by Andreas on Sat 2007-02-10
//  Copyright (c) 2004 Andreas Mayer. All rights reserved.

//    different representations:
// - off
//        (no background, text, text shadow)
// - off + mouse over
//        (light background without shadow, text, text shadow)
// - on
//        (medium background, top shadow, bottom light (shadow), text, text shadow)
// - on + mouse over
//        (light background, top shadow, bottom light (shadow), text, text shadow)
// - on/off + mouse down
//        (dark background, top shadow, bottom light (shadow), text, text shadow)


#import <AppKit/AppKit.h>

@interface ORSButtonBarCell : NSButtonCell

+ (NSColor *)offControlColor;
+ (NSColor *)offTextColor;
+ (NSShadow *)offTextShadow;

+ (NSColor *)offMouseOverControlColor;
+ (NSColor *)offMouseOverTextColor;
+ (NSShadow *)offMouseOverTextShadow;

+ (NSColor *)onControlColor;
+ (NSShadow *)onControlUpperShadow;
+ (NSShadow *)onControlLowerShadow;
+ (NSColor *)onTextColor;
+ (NSShadow *)onTextShadow;

+ (NSColor *)onMouseOverControlColor;
+ (NSShadow *)onMouseOverControlUpperShadow;
+ (NSShadow *)onMouseOverControlLowerShadow;
+ (NSColor *)onMouseOverTextColor;
+ (NSShadow *)onMouseOverTextShadow;

+ (NSColor *)mouseDownControlColor;
+ (NSShadow *)mouseDownControlUpperShadow;
+ (NSShadow *)mouseDownControlLowerShadow;
+ (NSColor *)mouseDownTextColor;
+ (NSShadow *)mouseDownTextShadow;

@property (nonatomic) BOOL mouseOver;

@property (nonatomic) BOOL mouseDown;

- (float)widthForFrame:(NSRect)frameRect;

@property (nonatomic, getter=isFocused) BOOL focused;

@end
