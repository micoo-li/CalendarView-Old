//
//  MLScrollView.h
//  CalendarView
//
//  Created by Michael Li on 7/28/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MLScrollViewDelegate <NSObject>

@optional

-(void)scrollingDidStart;
-(void)scrollingDidEnd;

@end

@interface MLScrollView : NSScrollView

@property id<MLScrollViewDelegate> delegate;

@end
