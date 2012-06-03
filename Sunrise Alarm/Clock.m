//
//  Clock.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Clock.h"
#import "insist.h"

@implementation Clock

@synthesize view;
@synthesize bigTimeLabel, smallTimeLabel;
@synthesize colonLabel;
@synthesize sunLabel, monLabel, tueLabel, wedLabel, thuLabel, friLabel, satLabel, amLabel, pmLabel;
@synthesize dateLabel, weatherLabel, onLabel;


#define FADED 0.2

/*encapsulate what we care about from a date here*/
-(NSDateComponents*)componentsFromDate:(NSDate*)date
{
  return [[NSCalendar autoupdatingCurrentCalendar]
          components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];  
}

-(void)setTimeFromComponents:(NSDateComponents*)components
{
  insist (components);

  /*set the hours and minutes*/
  int hour = [components hour];
  
  /*hour is number of hours since midnight. is it really this hard to convert to standard?*/
  if (hour < 1)
    hour = 12;
  else if (hour > 12)
    hour -= 12;
  
  bigTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", hour, [components minute]];
  
  /*toggle the colon*/
  colonLabel.hidden = ![colonLabel isHidden];
  
  /*set the seconds*/
  smallTimeLabel.text = [NSString stringWithFormat:@"%02d", [components second]];
}

-(void)setDayFromComponents:(NSDateComponents*)components
{
  /*get the localized strings for the days of the week*/
  NSArray*symbols = [dateFormatter shortWeekdaySymbols];
  insist (symbols);
  
  /*set the weekday labels and fade all the days except the weekday we are on*/
  
  for (int i = 0; i < [days count]; i++)
  {
    UILabel*day = [days objectAtIndex:i];
    
    /*handle evil calendars, if they exist, but just not showing any days*/
    if ([symbols count] != [days count])
    {
      day.hidden = YES;
      continue;
    }
    day.text = [symbols objectAtIndex:i];
    day.alpha = [components weekday] == i+1 ? 1.0 : FADED; 
  }
}

-(BOOL)isPM:(NSDateComponents*)components
{
  return [components hour] > 12 || ([components hour] == 12 && ([components minute] || [components second]));
}
-(void)setAMPMFromComponents:(NSDateComponents*)components
{
  insist (dateFormatter && components);
  
  /*first set the localized am/pm strings*/
  amLabel.text = [dateFormatter AMSymbol];
  pmLabel.text = [dateFormatter PMSymbol];
  
  /*now illuminate just the right one*/
  if ([self isPM:components])
  {
    amLabel.alpha = FADED;
    pmLabel.alpha = 1.0;
  }
  else
  {
    amLabel.alpha = 1.0;
    pmLabel.alpha = FADED;
  }
}

-(void)setDateFromDate:(NSDate*)date
{
  insist (date);
  
  NSString*s = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
  dateLabel.text =  s ? s : @"";
}
 
- (id)init
{
  self = [super init];
  insist (self);
    
  /*get a date formatter for use later*/
  dateFormatter = [[NSDateFormatter alloc] init];
  insist (dateFormatter);
    
  /*we always keep around the last date / components so we know what needs changing every second*/
  currentDate = [[NSDate date]retain];
  insist (currentDate);
  currentComponents = [[self componentsFromDate:currentDate]retain];
  insist (currentComponents);

  return self;
}

/*call this to finish initing stuff that dependsd on ui elements having been loaded*/
-(void)didLoad
{
  insist (dateFormatter && currentDate && currentComponents);
    
  /*so we can deal w/ the day labels by index*/
  days = [[NSArray arrayWithObjects:sunLabel, monLabel, tueLabel, wedLabel, thuLabel, friLabel, satLabel, nil] retain];
  insist (days);

  /*set up the clock with values for right now*/
  [self setTimeFromComponents:currentComponents];
  [self setDayFromComponents:currentComponents];
  [self setAMPMFromComponents:currentComponents];
  [self setDateFromDate:currentDate];
  self.weatherLabel.text = @"";
  self.onLabel.text =@"$";
  [self setOnHidden:YES];
}

-(void)dealloc
{
  [currentComponents release];
  [currentDate release];
  [dateFormatter release];
  [days release];
  
  
  [view release];
  [bigTimeLabel release];
  [smallTimeLabel release];
  [colonLabel release];
  [sunLabel release];
  [monLabel release];
  [tueLabel release];
  [wedLabel release];
  [thuLabel release];
  [friLabel release];
  [satLabel release];
  [amLabel release];
  [pmLabel release];
  [dateLabel release];
  [weatherLabel release];
  [onLabel release];

  [super dealloc];
}

/*this sets the font sizes and the font for the elements in a clock.
  we can't do this in IB because the font is non standard
*/

-(void)setFontBig:(float)big medium:(float)medium small:(float)small tiny:(float)tiny symbol:(float)symbol
{
  UIFont*symbolFont = [UIFont fontWithName:@"Guifxv2Transports" size:symbol];
  insist (symbolFont);
  
  UIFont*bigFont = [UIFont fontWithName:@"LED" size:big];
  insist (bigFont);
  
  UIFont*smallFont = [UIFont fontWithName:@"LED" size:small];
  insist (smallFont);
  
  UIFont*mediumFont = [UIFont fontWithName:@"LED" size:medium];
  insist (mediumFont);
  
  UIFont*tinyFont = [UIFont fontWithName:@"LED" size:tiny];
  insist (tinyFont);
   
  onLabel.font = symbolFont;
  bigTimeLabel.font = bigFont;
  smallTimeLabel.font = mediumFont;
  colonLabel.font = mediumFont;
  amLabel.font = mediumFont;
  pmLabel.font = mediumFont;
  sunLabel.font = smallFont;
  monLabel.font = smallFont;
  tueLabel.font = smallFont;
  wedLabel.font = smallFont;
  thuLabel.font = smallFont;
  friLabel.font = smallFont;
  satLabel.font = smallFont;
  dateLabel.font = tinyFont;
  weatherLabel.font = tinyFont;
}

-(void)setDate:(NSDate*)date
{
  insist (date && currentDate && currentComponents);
  
  /*get the calendar.*/
  NSCalendar*calendar = [NSCalendar autoupdatingCurrentCalendar];
  insist (calendar);

  NSDateComponents*components = [self componentsFromDate:date];
  insist (components);
  
  /*no matter what, set the time*/
  [self setTimeFromComponents:components];
  
  /*set the rest of the stuff only if it has changed*/
  if ([components weekday] != [currentComponents weekday])
    [self setDayFromComponents:components];
  
  if ([self isPM:components] != [self isPM:currentComponents])
    [self setAMPMFromComponents:components];
  
  /*this is either an approximation or it's overkill. not sure which. probably day of a year is fine.
     but that's not what day is here probably.
   */
  if ([components day] != [currentComponents day] || [components month] != [currentComponents month] || [components year] != [currentComponents year])
    [self setDateFromDate:date];
  
  /*update current date for next time*/
  [currentComponents release];
  currentComponents = [components retain];
  [currentDate release];
  currentDate = [date retain];
}

-(void)setOnHidden:(BOOL)hidden
{
  self.onLabel.hidden = hidden;
}

@end
