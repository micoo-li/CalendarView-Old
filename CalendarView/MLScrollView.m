//
//  MLScrollView.m
//  CalendarView
//
//  Created by Michael Li on 7/28/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import "MLScrollView.h"

@implementation MLScrollView

-(id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
    {
        self.acceptsTouchEvents = YES;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        self.acceptsTouchEvents = YES;
    }
    
    return self;
}

-(void)touchesBeganWithEvent:(NSEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
    if (touches.count == 2)
    {
        if ([self.delegate respondsToSelector:@selector(scrollingDidStart)])
            [self.delegate scrollingDidStart];
    }
}

-(void)touchesEndedWithEvent:(NSEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
    if (touches.count == 2)
    {
        if ([self.delegate respondsToSelector:@selector(scrollingDidEnd)])
            [self.delegate scrollingDidEnd];
    }
}

@end
