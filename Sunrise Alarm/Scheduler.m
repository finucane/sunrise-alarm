//
//  Scheduler.m
//  Sunrise Alarm
//
//  Created by finucane on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scheduler.h"
#import "Settings.h"
#import "insist.h"

/*
  this nice piece of ancient code we stole is all macros and stuff so it's hard to split it into
  a nice pair of .c and .h files. so just be lazy and include it here
*/

#include "sunriset_include"

@implementation Scheduler

/*get sunrise info for whatever type of sunrise the user is currently interested in*/
-(BOOL) getSunriseYear:(int)year month:(int)month day:(int)day lat:(double)lat lon:(double)lon rise:(double*)rise set:(double*)set
{  
  switch ([Settings sharedSettings].time)
  {
    case 0: return sun_rise_set (year, month, day, lon, lat, rise, set ) == 0;
    case 1: return civil_twilight (year, month, day, lon, lat, rise, set ) == 0;
    case 2: return nautical_twilight (year, month, day, lon, lat, rise, set ) == 0;
    case 3: return astronomical_twilight (year, month, day, lon, lat, rise, set ) == 0;
    default: insist (0);
  }  
  return NO;
}


-(void)scheduleAlarmForDate:(NSDate*)date
{
  insist (date);
  
  UILocalNotification*notification = [[UILocalNotification alloc] init];
  insist (notification);
  
 // date = [[NSDate date] dateByAddingTimeInterval:60];
  notification.fireDate = date;
  
  /*this will have the effect of sometimes doing nearly the right thing if the user travels*/
  notification.timeZone = [NSTimeZone defaultTimeZone];
  notification.alertBody = @"Alarm is ringing.";
  notification.alertAction = @"Snooze";
  notification.repeatInterval = 0;
  Settings*settings = [Settings sharedSettings];
  insist (settings);
  notification.soundName = [settings fileNameForSound:settings.soundIndex];
  
  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
  [notification release];
  
  
#if 0
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSString *dateString = [dateFormatter stringFromDate:date];
  NSLog(@"scheduled alarm at %@", dateString); 
#endif
}

/*find out what time we should fire an alarm*/
-(NSDate*)getDateForSunriseOfDay:(NSDate*)date lat:(double)lat longitude:(double)lon
{
  insist (date);
  
  Settings*settings = [Settings sharedSettings];
  insist(settings);

  /*all of our date math is done on a gregorian calendar that shouldn't have any timezone on it. so
    when we decompose a date into days and years it's all as if we are at UTC offset zero.*/
  
  NSCalendar*calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  insist (calendar);
  
  NSDateComponents*components = [calendar
                                 components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date]; 
   
  [calendar release];
  
  int year = [components year];
  int month = [components month];
  int day = [components day];
  
  /*get the time of sunrise, it's a UT time in fractional hours.*/
  double rise, set;
  [self getSunriseYear:year month:month day:day lat:lat lon:lon rise:&rise set:&set];
  
  /*if we are in vampire mode do everything based on sunset, rather than sunrise*/
  if (settings.vampire)
    rise = set;

  /*this time might have crossed over into the next day. correct this*/
  if (rise >= 24.0)
    rise -= 24.0;
  
  /*get a formatter so we can build up a date for the sunrise. this date will be at UTC offset zero.*/
  
  NSDateFormatter*formatter = [[[NSDateFormatter alloc] init] autorelease];
  formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

  /*convert floating point hour to hours and minutes and seconds. hopefully this is right.
    we aren't really accurate to the nearest second either, so it doesn't matter.*/
  int hour = rise;
  double rem = rise - (double)hour;
  int minute = rem * 60.0;
  rem = rem - (double) minute / 60.0;
  int second = rem * 60 * 60;
  
  /*get the date of the sunrise*/
  NSString*s;
  NSDate*alarmDate = [formatter dateFromString:s = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", 
                                                year, month, day, hour, minute, second]];  

  /*add the offset, which is in minutes*/
  return [alarmDate dateByAddingTimeInterval:[settings offset] * 60];
}

/*
  schedule a notification for local sunrise on the day of "date", if it hasn't already happened.
  return YES if we did schedule something.
*/

-(BOOL)scheduleAlarmForSunriseOfDay:(NSDate*)day lat:(double)lat longitude:(double)lon
{
  NSDate*date = [self getDateForSunriseOfDay:day lat:lat longitude:lon];
  
  if ([date compare:[NSDate date]] != NSOrderedDescending)
    return NO;
  
  /*this method is not being called for snooze, it's being called when alarms are being rescheduled
    in general. this here is to prevent an alarm from being scheduled immediately after it's just
    gone off. timeIntervals are seconds*/
    
  if ([date timeIntervalSinceNow] < 60 * 3)
    return NO;

  [self scheduleAlarmForDate:date];
  return YES;
}
/*schedule an alarm for now + snooze delay*/
-(void)snooze
{
  NSLog(@"scheduling snooze");
  [self scheduleAlarmForDate:[[NSDate date] dateByAddingTimeInterval:[Settings sharedSettings].snoozeMinutes * 60]];
}

/*take whatever the current user settings are, and his location, and schedule the next alarm(s)*/
-(void)rescheduleLatitude:(double)lat longitude:(double)lon
{
  //NSLog(@"rescheduling alarms");
  
    
  UIApplication*application = [UIApplication sharedApplication];
  insist (application);
  
  /*get the date right now*/
  NSDate*now = [NSDate date];
  
  /*
    get a calendar that knows where we are, because days of the week depend on this. This should
    handle daylight savings time too for us. but who really knows? it shouldn't matter because we ought
    to be doing everything based on absolute dates. (NSDate).
  */
  
  NSCalendar*calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]autorelease];
  insist (calendar);
  [calendar setTimeZone:[NSTimeZone localTimeZone]];
  
  /*cancel any previous notifications*/
  [application cancelAllLocalNotifications];
  
#if 0
  //return;
  /*debug*/
  [self scheduleAlarmForDate:[[NSDate date] dateByAddingTimeInterval:[Settings sharedSettings].snoozeMinutes * 60]];
  return;
#endif
  
  /*get the mask of days. sunday is position 0*/
  int dayMask = [Settings sharedSettings].dayMask;

  /*if we have no alarms, we are done*/
  if (dayMask == 0)
    return;
  
  if (![[Settings sharedSettings] enabled])
    return;
  
  /*
    we are allowed 64 notifications. just go through and schedule at most 2 weeks worth. (i.e. 8 days), it
    might be slow to talk to the OS so don't over do it.
   
    this makes sure that if the user has only 1 day set, and the dawn has already happened on that day this week
    the alarm for next week will be scheduled, and the app will get a chance to wake up.
  */
  
  NSDateComponents*oneDay = [[[NSDateComponents alloc] init]autorelease];
  insist (oneDay);
  [oneDay setDay:1];
  int numAlarmsSet = 0;
  
  for (int i = 0; i < 8; i++)
  {
    /*get the day of the week for the date and only use the day if it's in the users settings mask*/
    NSDateComponents*components = [calendar components: NSWeekdayCalendarUnit fromDate:now];
    int weekday = [components weekday]; //1-7
   if (dayMask & (1 << (weekday - 1)))
    {    
      /*if we cared about this taking a long time we actually could escape out here at the first
        sucessful alarm set.*/
      if ([self scheduleAlarmForSunriseOfDay:now lat:lat longitude:lon])
        numAlarmsSet++;
    }
    /*increment the day*/
    now = [calendar dateByAddingComponents:oneDay toDate:now options:0];
  }
  insist (numAlarmsSet);
}

/*
  get a description of roughly the next wakeup time based on user settings.
  don't pay attention to what days are set, just do the time for today
*/

-(NSString*)timeStringLat:(double)lat lon:(double)lon
{
  NSDate*date = [self getDateForSunriseOfDay:[NSDate date] lat:lat longitude:lon];
  insist (date);
   
  /*this value includes the offset*/
  
  return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"HH:mm"];
 return [dateFormatter stringFromDate:date];

}
@end
