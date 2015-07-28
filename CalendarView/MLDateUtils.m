//
//  MLDateUtils.m
//  CalendarView
//
//  Created by Michael Li on 7/16/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import "MLDateUtils.h"


@implementation MLDateUtils

+(NSInteger)numberOfWeeksForMonth:(NSDateComponents *)dateComponent
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    dateComponent.day = 1;
    dateComponent.hour = 0;
    dateComponent.minute = 0;
    dateComponent.second = 0;
    
    NSDate *date = [calendar dateFromComponents:dateComponent];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
    NSInteger numberOfDays = weekday + [self numberOfDaysForMonth:dateComponent] - 1;
    
    return (NSInteger)ceil((float)numberOfDays / 7.0);
}

+(NSInteger)numberOfDaysForMonth:(NSDateComponents *)dateComponent
{
    NSArray *monthDays = @[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31];
    
    if (dateComponent.year % 100 && dateComponent.month == 2 && dateComponent.year%400 != 0)
        return 28;
    
    if (dateComponent.month == 2 && dateComponent.year%4 == 0 )
        return 29;
    
    return [monthDays[dateComponent.month - 1] intValue];
}


+(NSInteger)currentMonth
{
    return [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:[NSDate date]];
}

+(NSInteger)currentYear
{
    return [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]];
}

+(NSDateComponents *)startingWeekdayOfMonth:(NSDateComponents *)dateComponent
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    dateComponent.day = 1;
    dateComponent.hour = 0;
    dateComponent.minute = 0;
    dateComponent.second = 0;
    
    NSDate *date = [calendar dateFromComponents:dateComponent];
    
    return [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:date];
}

+(NSDateComponents *)componentsOfNextDay:(NSDateComponents *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *newDate = [calendar dateFromComponents:date];
    newDate = [newDate dateByAddingTimeInterval:86400];
    
    NSDateComponents *newComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:newDate];
    return newComponents;
}

+(NSDateComponents *)componentsOfPreviousDay:(NSDateComponents *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *newDate = [calendar dateFromComponents:date];
    newDate = [newDate dateByAddingTimeInterval:-86400];
    
    NSDateComponents *newComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:newDate];
    
    return newComponents;
}

+(NSDateComponents *)previousMonth:(NSDateComponents *)dateComponent
{
    NSDateComponents *date = [[NSDateComponents alloc] init];
    if (dateComponent.month == 1)
    {
        date.month = 12;
        date.year = dateComponent.year - 1;
    }
    else
    {
        date.month = dateComponent.month - 1;
        date.year = dateComponent.year;
    }
    return date;
}

+(NSDateComponents *)nextMonth:(NSDateComponents *)dateComponent
{
    NSDateComponents *date = [[NSDateComponents alloc] init];
    if (dateComponent.month == 12)
    {
        date.month = 1;
        date.year = dateComponent.year + 1;
    }
    else
    {
        date.month = dateComponent.month + 1;
        date.year = dateComponent.year;
    }
    return date;
}


+(NSString *)monthName:(NSInteger)month
{
    NSArray *monthName = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    return monthName[month - 1];
}

+(BOOL)compareDateComponents:(NSDateComponents *)a componentTwo:(NSDateComponents *)b
{
    if (a.day == b.day && a.month == b.month && a.year == b.year)
        return true;
    
    return false;
}

+(NSDateComponents *)dateComponent:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *date = [[NSDateComponents alloc] init];
    
    date.day = day;
    date.month = month;
    date.year = year;
    
    return date;
}


@end
