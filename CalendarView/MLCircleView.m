//
//  MLCircleView.m
//  CalendarView
//
//  Created by Michael Li on 7/28/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import "MLCircleView.h"

@implementation MLCircleView

- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor redColor] set];
    
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithOvalInRect:dirtyRect];
    [bezierPath fill];
    
}

@end
