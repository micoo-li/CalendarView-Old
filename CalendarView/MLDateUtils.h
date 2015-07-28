//
//  MLDateUtils.h
//  CalendarView
//
//  Created by Michael Li on 7/16/15.
//  Copyright (c) 2015 Michael Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLDateUtils : NSObject

+(NSInteger)numberOfWeeksForMonth:(NSDateComponents *)dateComponent;
+(NSInteger)numberOfDaysForMonth:(NSDateComponents *)dateComponent;

+(NSInteger)currentMonth;
+(NSInteger)currentYear;

+(NSDateComponents *)startingWeekdayOfMonth:(NSDateComponents *)dateComponent;
+(NSDateComponents *)componentsOfNextDay:(NSDateComponents *)date;

+(NSDateComponents *)componentsOfPreviousDay:(NSDateComponents *)date;
+(NSDateComponents *)previousMonth:(NSDateComponents *)dateComponent;

+(NSDateComponents *)nextMonth:(NSDateComponents *)dateComponent;

+(NSString *)monthName:(NSInteger)month;

+(BOOL)compareDateComponents:(NSDateComponents *)a componentTwo:(NSDateComponents *)b;

+(NSDateComponents *)dateComponent:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;

@end
