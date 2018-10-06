//
//  NSShadow+ORSAdditions.m
//  ORSButtonBar
//
//  Created by Andreas on 10.02.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

#import "NSShadow+ORSAdditions.h"


@implementation NSShadow (ORSAdditions)

+ (NSShadow *)shadowWithColor:(NSColor *)color blurRadius:(float)radius offset:(NSSize)offset
{
	NSShadow *result = [[[NSShadow alloc] init] autorelease];
	[result setShadowOffset:offset];
	[result setShadowBlurRadius:radius];
	[result setShadowColor:color];
	return result;
}


@end
