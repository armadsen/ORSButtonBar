//
//  ORSButtonBarSeparatorCell.m
//  ORSButtonBar
//
//  Created by Andreas on 29.06.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
//  2010-02-18  Andreas Mayer
//  - removed deprecated invocations of -setCachesBezierPath:


#import "ORSButtonBarSeparatorCell.h"
#import "ORSButtonBarCell+SubclassMethods.h"
#import "NSColor+ORSAdditions.h"

static float am_backgroundInset = 1.5;

@implementation ORSButtonBarSeparatorCell

- (BOOL)mouseOver
{
    return NO;
}

- (void)setMouseOver:(BOOL)newMouseOver
{
}

- (BOOL)mouseDown
{
    return NO;
}

- (void)setMouseDown:(BOOL)value
{
}

- (void)calculateLayoutForFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // bezier path for plate background
    [self setLastFrameSize:cellFrame.size];
    NSRect innerRect = NSInsetRect(cellFrame, 0, am_backgroundInset);
    
    // bezier path for vertical line
    //innerRect.origin.x = floorf(cellFrame.size.width / 2.0)+0.5;
    innerRect.origin.x = 0.0;
    innerRect.origin.y = 0;
    innerRect.size.width = 0.5;
        
    id returnValue;
    returnValue = [NSBezierPath bezierPathWithRect:innerRect];
    [self setControlPath:returnValue];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath *path;
    NSColor *textColor;
    NSAffineTransform *transformation = [NSAffineTransform transform];
    [transformation translateXBy:cellFrame.origin.x+am_backgroundInset yBy:cellFrame.origin.y+am_backgroundInset];
    textColor = [ORSButtonBarCell offTextColor];
    textColor = [textColor disabledColor];
    path = [self.controlPath copy];
    
    [NSGraphicsContext saveGraphicsState];
    [path transformUsingAffineTransform:transformation];
    path.lineWidth = 0.0;
    [textColor set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

- (float)widthForFrame:(NSRect)frameRect
{
    float result=0;
    result += 2.0*am_backgroundInset;
    return result;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
    
    return NO;
}    


@end
