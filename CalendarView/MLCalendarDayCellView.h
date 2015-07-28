//
//  MLCalendarDayCellView.h
//  CalendarView
//
//  Created by Michael Li on 7/18/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLCalendarDayCellView : NSTableCellView

@property IBOutlet NSTextField *monthField;
@property IBOutlet NSTextField *dayField;
@property IBOutlet NSView *eventView;
@property IBOutlet NSView *circleView;

@end
