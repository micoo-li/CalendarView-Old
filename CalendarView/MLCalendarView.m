//
//  MLCalendarView.m
//  CalendarView
//
//  Created by Michael Li on 7/16/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import "MLCalendarView.h"

#import "MLCalendarDayCellView.h"
#import "MLScrollView.h"

#import "MLDateUtils.h"


@interface MLCalendarView () <NSTableViewDataSource, NSTableViewDelegate, MLScrollViewDelegate>
{
    NSMutableArray *calendarArray;
    NSCalendar *calendar;
    
    NSInteger currentMonth;
    NSInteger currentYear;

    NSDateComponents *todayDate;
    
    IBOutlet NSTableView *calendarTableView;
    //The top left field that displays the month and year
    IBOutlet NSTextField *monthLabel;
    
    int swiped;
    
}

-(void)load;
-(void)viewFrameDidChange;

-(IBAction)previousMonth:(id)sender;
-(IBAction)nextMonth:(id)sender;
-(IBAction)today:(id)sender;


-(void)setCurrentMonth:(NSInteger)month year:(NSInteger)year;
-(void)setCurrentMonth:(NSDateComponents *)date;

@end

@implementation MLCalendarView

#pragma mark Initializers

-(id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
        [self load];
    
    return self;
}

-(id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
        [self load];
    
    return self;
}

-(void)load
{
    NSArray *topLevelObjects;
    [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([MLCalendarView class]) owner:self topLevelObjects:&topLevelObjects];
    NSView *view = nil;
    
    for (id topLevelObject in topLevelObjects)
    {
        if ([topLevelObject isKindOfClass:[NSView class]])
        {
            view = topLevelObject;
            break;
        }
    }
    
    [view setFrame:self.frame];
    
    [self addSubview:view];
    [self setAutoresizesSubviews:YES];
    
    calendar = [NSCalendar currentCalendar];
    
    //Setup table column width
    NSArray *tableColumns = calendarTableView.tableColumns;
    
    int i = 1;
    for (NSTableColumn *tableColumn in tableColumns)
    {
        tableColumn.width = (calendarTableView.enclosingScrollView.frame.size.width - 24)/7;
        
        tableColumn.identifier = [NSString stringWithFormat:@"%i", i++];
        
        [tableColumn setMinWidth:0];
        [tableColumn setMaxWidth:99999999];
    }
    
    //Setup scrollers to be invisible
    [[calendarTableView.enclosingScrollView verticalScroller] setAlphaValue:0];
    
    //Add notifications for NSView
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewFrameDidChange) name:NSViewFrameDidChangeNotification object:self];
    
    //Set current month
    [self setCurrentMonth:[MLDateUtils currentMonth] year:[MLDateUtils currentYear]];
    todayDate = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:[NSDate date]];
    
    //Scroll View Delegate
    [(MLScrollView *)calendarTableView.enclosingScrollView setDelegate:self];
    
    
    
}

#pragma mark Calendar View Methods

-(void)setCurrentMonth:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    dateComponent.month = month;
    dateComponent.year = year;
    
    calendarArray = [NSMutableArray array];
    
    currentMonth = month;
    currentYear = year;
    
    
    NSInteger numberOfWeeks = [MLDateUtils numberOfWeeksForMonth:dateComponent];
    NSDateComponents *date = [MLDateUtils startingWeekdayOfMonth:dateComponent];
    
    BOOL firstWeek = YES;
 
    //Initializing Array and load the array
    for (int i = 0; i < numberOfWeeks; i++)
    {
        [calendarArray addObject:[NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, nil]];
        
        for (int j = 0; j < 7; j++)
        {
            if (firstWeek == YES)
            {
                j = (int)date.weekday - 1;
                firstWeek = NO;
            }
            
            calendarArray[i][j] = date;
            date = [MLDateUtils componentsOfNextDay:date];
        }
    }
    
    //Load previous month
    
    date = [MLDateUtils startingWeekdayOfMonth:dateComponent];
    
    NSDateComponents *previousMonth = [MLDateUtils previousMonth:dateComponent];
    NSInteger numberOfWeeksPreviousMonth = [MLDateUtils numberOfWeeksForMonth:previousMonth];
    
    BOOL lastWeek = YES;
    
    for (int i = 0; i < numberOfWeeksPreviousMonth; i++)
    {
        
        for (int j = 6; j >= 0; j--)
        {
            if (lastWeek)
            {
                lastWeek = NO;
                if (date.weekday != 1)
                    j = (int)date.weekday - 2;
                else
                {
                    i--;
                    break;
                }
            }
            
            date = [MLDateUtils componentsOfPreviousDay:date];
            
            calendarArray[0][j] = date;
        }
        [calendarArray insertObject:[NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, nil] atIndex:0];
    }

    [calendarArray removeObjectAtIndex:0];
    
    NSInteger currentMonthStartWeek = numberOfWeeksPreviousMonth;
    if ([(NSDateComponents *)calendarArray[numberOfWeeksPreviousMonth][0] day] != 1)
        currentMonthStartWeek -= 1;
    
    
    //Load next month
    NSDateComponents *nextMonth = [MLDateUtils nextMonth:dateComponent];
    date = [MLDateUtils startingWeekdayOfMonth:nextMonth];
    
    NSInteger maxArray = calendarArray.count - 1;
    
    firstWeek = YES;
    
    //Change, as the 1st day must be on the first row
    
    for (int i = (int)maxArray; i < maxArray + 6; i++)
    {
        for (int j = 0; j < 7; j++)
        {
            if (firstWeek == YES)
            {
                firstWeek = NO;
                
                if (date.weekday == 1)
                {
                    break;
                }
                
                j = (int)date.weekday - 1;
                
            }
            calendarArray[i][j] = date;
            
            date = [MLDateUtils componentsOfNextDay:date];
        }
        [calendarArray addObject:[NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, nil]];
    }
    [calendarArray removeLastObject];
    
    if ([[[calendarArray lastObject] objectAtIndex:0] isKindOfClass:[NSNumber class]])
        [calendarArray removeLastObject];
    
    //Reload Table View
    
    [calendarTableView reloadData];
    
    
    //Set month label
    NSMutableAttributedString *monthAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %li", [MLDateUtils monthName:currentMonth], currentYear]];
    
    [monthAttrString setAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue-Bold" size:26]} range:NSMakeRange(0, 3)];
    [monthAttrString setAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue-Light" size:26]} range:NSMakeRange(4, 4)];
    [monthLabel setAttributedStringValue:monthAttrString];
    
    
    //Scroll view to the correct month
    [self scrollToRow:currentMonthStartWeek];
    
}

//To make things a bit simpler sometimes
-(void)setCurrentMonth:(NSDateComponents *)date
{
    [self setCurrentMonth:date.month year:date.year];
}

#pragma mark NSTableView Data Source

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [calendarArray count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    MLCalendarDayCellView *dayCellView = [tableView makeViewWithIdentifier:@"MLTableCellViewIdentifier" owner:self];
    
    //dayCellView.wantsLayer = YES;

    NSDateComponents *date = calendarArray[row][tableColumn.identifier.integerValue - 1];
    
    if (date.day == 1)
    {
        dayCellView.dayField.stringValue = [NSString stringWithFormat:@"%li", date.day];
        dayCellView.monthField.hidden = NO;
        dayCellView.monthField.stringValue = [MLDateUtils monthName:date.month];
    }
    else
    {
        dayCellView.dayField.stringValue = [NSString stringWithFormat:@"%li", date.day];
        dayCellView.monthField.hidden = YES;
    }
    
    if ([MLDateUtils compareDateComponents:date componentTwo:todayDate])
    {
        dayCellView.circleView.hidden = NO;
        dayCellView.dayField.textColor = [NSColor whiteColor];
    }
    else
    {
        dayCellView.circleView.hidden = YES;
        dayCellView.dayField.textColor = [NSColor blackColor];
    }
    
    //dayCellView.dayField.stringValue = [NSString stringWithFormat:@"%li", [calendarArray[row][tableColumn.identifier.integerValue - 1 ] day]];
    
 
    return dayCellView;
    
}

#pragma mark NSTableView Delegate

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return (tableView.enclosingScrollView.frame.size.height - 14)/6;
}

#pragma mark IBAction Methods

-(IBAction)previousMonth:(id)sender
{
    [self setCurrentMonth:[MLDateUtils previousMonth:[MLDateUtils dateComponent:0 month:currentMonth year:currentYear]]];
}

-(IBAction)nextMonth:(id)sender
{
    [self setCurrentMonth:[MLDateUtils nextMonth:[MLDateUtils dateComponent:0 month:currentMonth year:currentYear]]];
}

-(IBAction)today:(id)sender
{
    [self setCurrentMonth:todayDate.month year:todayDate.year];
}

#pragma mark MLScrollView Delegate Notifications

-(void)scrollingDidEnd
{
    CGFloat currentY = calendarTableView.superview.bounds.origin.y;
    
    NSDateComponents *date = calendarArray[1][1];
    
    CGFloat ypos[3] = {0, 0, 0};
    
    ypos[0] = [self pointOfCalendarMonth:date.month].y;
    
    date = [MLDateUtils nextMonth:date];
    
    ypos[1] = [self pointOfCalendarMonth:date.month].y;
    
    date = [MLDateUtils nextMonth:date];
    
    ypos[2] = [self pointOfCalendarMonth:date.month].y;
    
    // NSLog (@"ypos: %f %f %f", ypos[0], ypos[1], ypos[2]);
    
    CGFloat difference[3] = {0, 0, 0};
    
    difference[0] = fabs((float)(currentY - ypos[0]));
    difference[1] = fabs((float)(currentY - ypos[1]));
    difference[2] = fabs((float)(currentY - ypos[2]));
    
    int minIndex = -1;
    
    if (difference[0] < difference[1])
        minIndex = 0;
    else
        minIndex = 1;
    
    if (difference[2] < difference[minIndex])
        minIndex = 2;
    
    //    NSLog (@"%i", calendarArray)
    
    //The conversion is just 1 more
    swiped = minIndex - 1;
    
    
    [self scrollToYPointAnimated:ypos[minIndex]];
     
}

#pragma mark NSView Notifications

-(void)viewFrameDidChange
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [calendarTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, calendarArray.count)]];
    [NSAnimationContext endGrouping];
    
    [self scrollToRow:[self rowOfCalendarMonth:currentMonth]];
    
}

#pragma mark Scrolling Methods

-(void)scrollToRow:(NSInteger)row
{
    [(NSClipView *)calendarTableView.superview scrollToPoint:NSMakePoint(0, [self positionOfRow:row])];
}

-(CGFloat)positionOfRow:(NSInteger)row
{
    return calendarTableView.superview.bounds.size.height/6 * row;
}

-(void)scrollToRowAnimated:(NSInteger)row
{
    [self scrollToYPointAnimated:[self positionOfRow:row]];
}

-(void)scrollToYPointAnimated:(CGFloat)y
{
    //Makes sure there is only one that is running and doesn't constantly take animated commands
    [NSAnimationContext beginGrouping];
    
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        // This block will be invoked when all of the animations
        //  started below have completed or been cancelled.
      //  [(MLScrollView *)calendarTableView.enclosingScrollView setScrollingDisabled:NO];
        
        if (swiped < 0)
        {
            NSDateComponents *dateComponents = [MLDateUtils previousMonth:[MLDateUtils dateComponent:0 month:currentMonth year:currentYear]];
            [self setCurrentMonth:dateComponents.month year:dateComponents.year];
        }
        else if (swiped > 0)
        {
            NSDateComponents *dateComponents = [MLDateUtils nextMonth:[MLDateUtils dateComponent:0 month:currentMonth year:currentYear]];
            [self setCurrentMonth:dateComponents.month year:dateComponents.year];
        }
        
    }];
    
 //   [(MLScrollView *)calendarTableView.enclosingScrollView setScrollingDisabled:YES];
    [[NSAnimationContext currentContext] setDuration:0.5];
    NSPoint newOrigin = [calendarTableView.superview bounds].origin;
    newOrigin.y = y;
    [[calendarTableView.superview animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
    
}

-(NSPoint)pointOfCalendarMonth:(NSInteger)month
{
    return NSMakePoint(0, [self positionOfRow:[self rowOfCalendarMonth:month]]);
}

//Optimize this later
-(NSInteger)rowOfCalendarMonth:(NSInteger)month
{
    for (int i = 0; i < calendarArray.count; i++)
    {
        for (int j = 0; j < 7; j++)
        {
            if ([(NSDateComponents *)calendarArray[i][j] month] == month)
                return i;
        }
    }
    
    return -1;
}


@end
