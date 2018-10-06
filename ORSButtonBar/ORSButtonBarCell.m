//
//  ORSButtonBarCell.m
//  ORSButtonBar
//
//  Created by Andreas on 2007-02-10
//  Copyright (c) 2004 Andreas Mayer. All rights reserved.

// assumes a flipped control

//  2010-02-12  Andreas Mayer
//  - replaced use of NSFont's deprecated -widthOfString with appropriate NSString method
//  2010-02-18  Andreas Mayer
//  - removed deprecated invocations of -setCachesBezierPath:

#import "ORSButtonBarCell.h"
#import "ORSButtonBarCell+SubclassMethods.h"
#import "NSBezierPath+ORSAdditons.h"
#import "NSGradient+ORSButtonBar.h"
#import "NSColor+ORSAdditions.h"
#import "NSFont+ORSFixes.h"
#import "NSShadow+ORSAdditions.h"
#import <math.h>

static float am_backgroundInset = 1.5;
static float am_textGap = 1.5;
static float am_bezierPathFlatness = 0.2;

@interface ORSButtonBarCell ()

@property (nonatomic, strong) NSBezierPath *innerControlPath;

@end

@implementation ORSButtonBarCell
{
    NSRect _textRect;
}

+ (NSColor *)offControlColor
{
    static NSColor *offControlColor = nil;
    if (!offControlColor) {
        offControlColor = [NSColor clearColor];
    }
    return offControlColor;
}

+ (NSColor *)offTextColor
{
    static NSColor *offTextColor = nil;
    if (!offTextColor) {
        offTextColor = [NSColor colorWithCalibratedWhite:0 alpha:1];
    }
    return offTextColor;
}

+ (NSShadow *)offTextShadow
{
    static NSShadow *offTextShadow = nil;
    if (!offTextShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:1 alpha:1];
        offTextShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, -1)];
    }
    return offTextShadow;
}


+ (NSColor *)offMouseOverControlColor
{
    static NSColor *offMouseOverControlColor = nil;
    if (!offMouseOverControlColor) {
        offMouseOverControlColor = [NSColor colorWithCalibratedWhite:.5 alpha:.5];
    }
    return offMouseOverControlColor;
}

+ (NSColor *)offMouseOverTextColor
{
    static NSColor *offMouseOverTextColor = nil;
    if (!offMouseOverTextColor) {
        offMouseOverTextColor = [NSColor colorWithCalibratedWhite:1 alpha:1];
    }
    return offMouseOverTextColor;
}

+ (NSShadow *)offMouseOverTextShadow
{
    static NSShadow *offMouseOverTextShadow = nil;
    //    if (!offMouseOverTextShadow) {
    //        NSColor *color = [NSColor colorWithCalibratedWhite:.2 alpha:1];
    //        offMouseOverTextShadow = [[NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)] retain];
    //    }
    return offMouseOverTextShadow;
}


+ (NSColor *)onControlColor
{
    static NSColor *onControlColor = nil;
    if (!onControlColor) {
        onControlColor = [NSColor colorWithCalibratedWhite:.6 alpha:1];
    }
    return onControlColor;
}

+ (NSShadow *)onControlUpperShadow
{
    static NSShadow *onControlUpperShadow = nil;
    if (!onControlUpperShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:.0 alpha:.5];
        onControlUpperShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0,  1)];
    }
    return onControlUpperShadow;
}

+ (NSShadow *)onControlLowerShadow
{
    static NSShadow *onControlLowerShadow = nil;
    if (!onControlLowerShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:1 alpha:.5];
        onControlLowerShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, -1)];
    }
    return onControlLowerShadow;
}

+ (NSColor *)onTextColor
{
    static NSColor *onTextColor = nil;
    if (!onTextColor) {
        onTextColor = [NSColor colorWithCalibratedWhite:1 alpha:1];
    }
    return onTextColor;
}

+ (NSShadow *)onTextShadow
{
    static NSShadow *onTextShadow = nil;
    if (!onTextShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:.6 alpha:1];
        onTextShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)];
    }
    return onTextShadow;
}


+ (NSColor *)onMouseOverControlColor
{
    static NSColor *onMouseOverControlColor = nil;
    if (!onMouseOverControlColor) {
        onMouseOverControlColor = [NSColor colorWithCalibratedWhite:.68 alpha:1];
    }
    return onMouseOverControlColor;
}

+ (NSShadow *)onMouseOverControlUpperShadow
{
    static NSShadow *onMouseOverControlUpperShadow = nil;
    if (!onMouseOverControlUpperShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:0 alpha:.5];
        onMouseOverControlUpperShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)];
    }
    return onMouseOverControlUpperShadow;
}

+ (NSShadow *)onMouseOverControlLowerShadow
{
    static NSShadow *onMouseOverControlLowerShadow = nil;
    if (!onMouseOverControlLowerShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:1 alpha:.5];
        onMouseOverControlLowerShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, -1)];
    }
    return onMouseOverControlLowerShadow;
}

+ (NSColor *)onMouseOverTextColor
{
    static NSColor *onMouseOverTextColor = nil;
    if (!onMouseOverTextColor) {
        onMouseOverTextColor = [NSColor colorWithCalibratedWhite:1 alpha:1];
    }
    return onMouseOverTextColor;
}

+ (NSShadow *)onMouseOverTextShadow
{
    static NSShadow *onMouseOverTextShadow = nil;
    //    if (!onMouseOverTextShadow) {
    //        NSColor *color = [NSColor colorWithCalibratedWhite:.7 alpha:1];
    //        onMouseOverTextShadow = [[NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)] retain];
    //    }
    return onMouseOverTextShadow;
}


+ (NSColor *)mouseDownControlColor
{
    static NSColor *mouseDownControlColor = nil;
    if (!mouseDownControlColor) {
        mouseDownControlColor = [NSColor colorWithCalibratedWhite:.5 alpha:1];
    }
    return mouseDownControlColor;
}

+ (NSShadow *)mouseDownControlUpperShadow
{
    static NSShadow *mouseDownControlUpperShadow = nil;
    if (!mouseDownControlUpperShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:0 alpha:.4];
        mouseDownControlUpperShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)];
    }
    return mouseDownControlUpperShadow;
}

+ (NSShadow *)mouseDownControlLowerShadow
{
    static NSShadow *mouseDownControlLowerShadow = nil;
    if (!mouseDownControlLowerShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:.9 alpha:.5];
        mouseDownControlLowerShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, -1)];
    }
    return mouseDownControlLowerShadow;
}

+ (NSColor *)mouseDownTextColor
{
    static NSColor *mouseDownTextColor = nil;
    if (!mouseDownTextColor) {
        mouseDownTextColor = [NSColor colorWithCalibratedWhite:1 alpha:1];
    }
    return mouseDownTextColor;
}

+ (NSShadow *)mouseDownTextShadow
{
    static NSShadow *mouseDownTextShadow = nil;
    if (!mouseDownTextShadow) {
        NSColor *color = [NSColor colorWithCalibratedWhite:.4 alpha:1];
        mouseDownTextShadow = [NSShadow shadowWithColor:color blurRadius:1 offset:NSMakeSize(0, 1)];
    }
    return mouseDownTextShadow;
}



- (instancetype)initTextCell:(NSString *)aString
{
    if ((self = [super initTextCell:aString])) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    super.bezelStyle = NSShadowlessSquareBezelStyle;
    self.alignment = NSCenterTextAlignment;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.alignment = NSCenterTextAlignment;
    return self;
}

- (void)calculateLayoutForFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // bezier path for plate background
    [self setLastFrameSize:cellFrame.size];
    NSRect innerRect = NSInsetRect(cellFrame, am_backgroundInset, am_backgroundInset);
    // text rect
    _textRect = innerRect;
    NSFont *font = self.font;
    NSDictionary *stringAttributes = @{NSFontAttributeName: font};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.title attributes:stringAttributes];
    NSSize textSize = [string size];
    float radius = (self.lastFrameSize.height/2.0)-am_backgroundInset;
    // calculate minimum text inset
    float textInset;
    float h = font.ascender/2.0;
    textInset = ceilf(radius-sqrt(radius*radius - h*h));
    _textRect = NSInsetRect(_textRect, textInset+am_textGap, 0);
    _textRect.size.height = textSize.height;
        
    float capHeight = [font fixed_capHeight];
    float ascender = font.ascender;
    float yOrigin = innerRect.origin.y;
    float offset = ((innerRect.size.height-_textRect.size.height) / 2.0);
    offset += (ascender-capHeight)-((_textRect.size.height-capHeight) / 2.0);
    yOrigin += floorf(offset);
    _textRect.origin.y = yOrigin;
    
    // bezier path for button background
    innerRect.origin.x = 0;
    innerRect.origin.y = 0;
    
    id returnValue;
    returnValue = [NSBezierPath bezierPathWithPlateInRect:innerRect];
    [self setControlPath:returnValue];
    
    // bezier path for pressed button (with gap for shadows)
    innerRect.size.height--;
    innerRect.origin.y++;
    
    returnValue = [NSBezierPath bezierPathWithPlateInRect:innerRect];
    [self setInnerControlPath:returnValue];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if ((self.lastFrameSize.width != cellFrame.size.width) || (self.lastFrameSize.height != cellFrame.size.height)) {
        [self calculateLayoutForFrame:cellFrame inView:controlView];
    }
    [self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath *path;
    NSColor *controlColor;
    NSShadow *upperShadow = nil;
    NSShadow *lowerShadow = nil;
    NSColor *textColor;
    NSShadow *textShadow;
    NSAffineTransform *transformation = [NSAffineTransform transform];
    [transformation translateXBy:cellFrame.origin.x+am_backgroundInset yBy:cellFrame.origin.y+am_backgroundInset];
    if (!self.enabled)  // disabled
     {
        if (self.state == NSOnState) // on 
         {
            controlColor = [ORSButtonBarCell onControlColor];
            upperShadow = [ORSButtonBarCell onControlUpperShadow];
            lowerShadow = [ORSButtonBarCell onControlLowerShadow];
            path = [self.innerControlPath copy];
            textColor = [ORSButtonBarCell onTextColor];
            textShadow = [ORSButtonBarCell onTextShadow];
         }
        else // off
         { 
             controlColor = [ORSButtonBarCell offControlColor];
             path = [self.controlPath copy];
             textColor = [ORSButtonBarCell offTextColor];
             textShadow = [ORSButtonBarCell offTextShadow];
         }
        controlColor = [controlColor disabledColor];
        textColor = [textColor disabledColor];
     }
    else  // enabled
     { // enabled
         if (self.highlighted) // mouse down
          { 
              controlColor = [ORSButtonBarCell mouseDownControlColor];
              upperShadow = [ORSButtonBarCell mouseDownControlUpperShadow];
              lowerShadow = [ORSButtonBarCell mouseDownControlLowerShadow];
              path = [self.innerControlPath copy];
              textColor = [ORSButtonBarCell mouseDownTextColor];
              textShadow = [ORSButtonBarCell mouseDownTextShadow];
          } 
         else if (self.state == NSOnState) // on
          { 
              if (self.mouseOver || self.highlighted) 
               {
                  controlColor = [ORSButtonBarCell onMouseOverControlColor];
                  upperShadow = [ORSButtonBarCell onMouseOverControlUpperShadow];
                  lowerShadow = [ORSButtonBarCell onMouseOverControlLowerShadow];
                  path = [self.innerControlPath copy];
                  textColor = [ORSButtonBarCell onMouseOverTextColor];
                  textShadow = [ORSButtonBarCell onMouseOverTextShadow];
               }
              else 
               {
                  controlColor = [ORSButtonBarCell onControlColor];
                  upperShadow = [ORSButtonBarCell onControlUpperShadow];
                  lowerShadow = [ORSButtonBarCell onControlLowerShadow];
                  path = [self.innerControlPath copy];
                  textColor = [ORSButtonBarCell onTextColor];
                  textShadow = [ORSButtonBarCell onTextShadow];
               }
          }
         else // off
          { 
              if (self.mouseOver || self.highlighted) 
               {
                  controlColor = [ORSButtonBarCell offMouseOverControlColor];
                  path = [self.controlPath copy];
                  textColor = [ORSButtonBarCell offMouseOverTextColor];
                  textShadow = [ORSButtonBarCell offMouseOverTextShadow];
               } 
              else  
               {
                  controlColor = [ORSButtonBarCell offControlColor];
                  path = [self.controlPath copy];
                  textColor = [ORSButtonBarCell offTextColor];
                  textShadow = [ORSButtonBarCell offTextShadow];
               }
          }
     }
    
    [NSGraphicsContext saveGraphicsState];
    [path transformUsingAffineTransform:transformation];
    path.lineWidth = 0.0;
    path.flatness = am_bezierPathFlatness;
    if (upperShadow)  // draw two halves with shadow
     {
        [controlColor set];
        [NSGraphicsContext saveGraphicsState];
        // adjust clipping rectangle
        NSRect halfFrame = cellFrame;
        halfFrame.size.height =  floorf(halfFrame.size.height/2);
        [NSBezierPath clipRect:halfFrame];
        [upperShadow set];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [NSGraphicsContext saveGraphicsState];
        halfFrame.origin.y = cellFrame.origin.y+halfFrame.size.height;
        [NSBezierPath clipRect:halfFrame];
        [lowerShadow set];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        // draw middle part without shadow
        halfFrame.origin.y = cellFrame.origin.y+floorf(cellFrame.size.height/2)-1;
        halfFrame.size.height = 2;
        [NSBezierPath clipRect:halfFrame];
        [path fill];
     } 
    else // draw one path only
     { 
         [controlColor set];
         [path fill];
     }
    [NSGraphicsContext restoreGraphicsState];
    
    if ([self isFocused])
     {
        NSRect focusRingFrame = cellFrame;
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithPlateInRect: NSInsetRect(focusRingFrame,2.5,2.5)] fill];
        [NSGraphicsContext restoreGraphicsState];        
     }
    
    [NSGraphicsContext saveGraphicsState];
    [textShadow set];
    // draw button title
    NSDictionary *stringAttributes;
    NSFont *font;
    NSMutableParagraphStyle *parapraphStyle = [[NSMutableParagraphStyle alloc] init];
    parapraphStyle.alignment = self.alignment;
    font = self.font;
    stringAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: parapraphStyle};
    [self.title drawInRect:_textRect withAttributes:stringAttributes];
    [NSGraphicsContext restoreGraphicsState];
}

- (float)widthForFrame:(NSRect)frameRect
{
    float result;
    NSFont *font = self.font;
    //    result = ceilf([font widthOfString:[self title]]);
    NSDictionary *attributes = @{NSFontAttributeName: font};
    result = ceilf([self.title sizeWithAttributes:attributes].width);
    float radius = (frameRect.size.height/2.0)-am_backgroundInset;
    
    float textInset;
    float h = font.ascender/2.0;
    textInset = ceilf(radius-sqrt(radius*radius - h*h)+(radius*0.25));
    
    result += 2.0*(textInset+am_backgroundInset+am_textGap);
    if (self.menu != nil) {
        float arrowWidth = [NSFont systemFontSizeForControlSize:self.controlSize]*0.6;
        result += (radius*0.5)+arrowWidth;
    }
    return result;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
    
    BOOL result = NO;
    //NSLog(@"trackMouse:inRect:ofView:untilMouseUp:");
    NSDate *endDate;
    NSPoint currentPoint = theEvent.locationInWindow;
    BOOL done = NO;
    BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
    // catch next mouse-dragged or mouse-up event until timeout
    BOOL mouseIsUp = NO;
    NSEvent *event;
    while (!done) { // loop ...
        NSPoint lastPoint = currentPoint;
        endDate = [NSDate distantFuture];
        event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask) untilDate:endDate inMode:NSEventTrackingRunLoopMode dequeue:YES];
        if (event) { // mouse event
            currentPoint = event.locationInWindow;
            if (trackContinously) { // send continueTracking.../stopTracking...
                if (![self continueTracking:lastPoint at:currentPoint inView:controlView]) {
                    done = YES;
                    [self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
                }
                if (self.continuous) {
                    [NSApp sendAction:self.action to:self.target from:controlView];
                }
            }
            mouseIsUp = (event.type == NSLeftMouseUp);
            [self setMouseDown:mouseIsUp];
            done = done || mouseIsUp;
            if (untilMouseUp) {
                result = mouseIsUp;
            } else {
                // check, if the mouse left our cell rect
                result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
                if (!result) {
                    done = YES;
                    [self setMouseOver:NO];
                } else {
                    [self setMouseOver:YES];
                }
            }
            if (done && result && !self.continuous) {
                [NSApp sendAction:self.action to:self.target from:controlView];
            }
        } else { // show menu
            done = YES;
            result = YES;
            //            [self showMenuForEvent:theEvent controlView:controlView cellFrame:cellFrame];
        }
    } // while (!done)
    return result;
}


@end


