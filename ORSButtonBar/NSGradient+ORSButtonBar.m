//
//  NSGradient+ORSButtonBar.m
//  ORSButtonBar
//
//  Created by Andreas on 18.02.10.
//  Copyright 2010 Andreas Mayer. All rights reserved.
//

#import "NSGradient+ORSButtonBar.h"

@implementation NSGradient (ORSButtonBar)


+ (id)blueButtonBarGradient
{
    NSGradient *result;
    
    NSColor *color1 = [NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.85 alpha:1.00];
    NSColor *color2 = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.95 alpha:1.00];
    result = [[NSGradient alloc] initWithColors:@[color1, color2]];
    
    return [result autorelease];
}

+ (id)grayButtonBarGradient;
{
    NSGradient *result;
    
    NSColor *color1 = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.85 alpha:1.00];
    NSColor *color2 = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    result = [[NSGradient alloc] initWithColors:@[color1, color2]];
    
    return [result autorelease];
}

+ (id)lightButtonBarGradient
{
    NSGradient *result;
    
    NSColor *color1 = [NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.00];
    NSColor *color2 = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    result = [[NSGradient alloc] initWithColors:@[color1, color2]];
    
    return [result autorelease];
}

+ (id)unifiedDarkGradient
{
    NSGradient *result;
    
    NSColor *color1 = [NSColor colorWithCalibratedRed:0.68 green:0.68 blue:0.68 alpha:1.00];
    NSColor *color2 = [NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00];
    result = [[NSGradient alloc] initWithColors:@[color1, color2]];
    
    return [result autorelease];
}


@end
