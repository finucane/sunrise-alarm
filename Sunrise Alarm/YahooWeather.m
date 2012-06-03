//
//  YahooWeather.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YahooWeather.h"
#import "XMLReader.h"
#import "insist.h"

@implementation YahooWeather


#define TIMEOUT_SECONDS (60*3)

-(id)initWithYahooWeatherDelegate:(id)aDelegate
{
  self = [super init];
  insist (self);
  delegate = aDelegate;//don't retain delegates
  
  fetcher = [[HTTPFetcher alloc] initWithDelegate:self];
  insist (fetcher);
  return self;
}

-(void) dealloc
{
  [fetcher release];
  [super dealloc];
}

-(void)goWithLatitude:(double)lat longitude:(double)lon;
{

  insist (fetcher);
  
  [fetcher go:
   [NSString stringWithFormat:@"http://where.yahooapis.com/geocode?location=%.6f+%.6f&gflags=R&appid=xXYpZkHV34Eq6qmlPyYcTe5MDHWBKLuu_fHlW8blwcN3lD.pZgpvLlkyQ7qt7ZbtKFuUWJOqHePlBtkGb4iHjLG1F7OQ-",
               lat, lon]withTimeout:TIMEOUT_SECONDS];
   
  gettingWoeid = YES;
}
 

- (void)didFinish:(HTTPFetcher*)aFetcher withData:(NSData*)data
{
  if (gettingWoeid)
  {
    /*make the result into an xml tree and dig through it for the woeid*/
    NSDictionary*dict = [XMLReader dictionaryForXMLString:[aFetcher stringFromData:data] error:nil];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    dict = [dict objectForKey:@"ResultSet"];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    dict = [dict objectForKey:@"Result"];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSString*woeid = [dict objectForKey:@"woeid"];
    if (!woeid)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    /*we got our woeid, now we can try getting the weather*/
    gettingWoeid = NO;
    [fetcher go:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@", woeid] withTimeout:TIMEOUT_SECONDS];
  }
  else
  {
    /*we got an answer back from the weather query*/
    /*make the result into an xml tree and dig through it for the temp, conditions, and temp units*/
    NSDictionary*dict = [XMLReader dictionaryForXMLString:[aFetcher stringFromData:data] error:nil];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    dict = [dict objectForKey:@"rss"];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    dict = [dict objectForKey:@"channel"];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSDictionary*units = [dict objectForKey:@"yweather:units"];
    if (!units)
    { 
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSString*corf = [units objectForKey:@"@temperature"];
    if (!corf)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    dict = [dict objectForKey:@"item"];
    if (!dict)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSDictionary*condition = [dict objectForKey:@"yweather:condition"];
    if (!condition)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSString*text = [condition objectForKey:@"@text"];
    if (!text)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }
    NSString*temp = [condition objectForKey:@"@temp"];
    if (!temp)
    {
      [delegate weather:self gotWeather:nil];
      return;
    }

    /*it all worked. return the weather string, we wanted to do a nice degree sign, but our LED font doesn't have it, duh.*/
    [delegate weather:self gotWeather:[NSString stringWithFormat:@"%@ %@ %@", temp, corf, text]];
    return;

  }
}

- (void)didFail:(HTTPFetcher*)fetcher withError:(NSString*)error
{
  [delegate weather:self gotWeather:nil];
}

- (void)didTimeout:(HTTPFetcher*)fecher
{
  [delegate weather:self gotWeather:nil];
}

@end
