//
//  ScannerCategory.m
//  
//
//  Created by David Finucane on 12/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ScannerCategory.h"
#import "insist.h"

@implementation NSScanner (ScannerCategory)

- (BOOL) scanPast:(NSString*)s
{
  [self scanUpToString:s intoString:nil];
  return ![self isAtEnd] && [self scanString:s intoString:nil];
}

- (BOOL) scanFrom:(unsigned)startLocation upTo:(unsigned)stopLocation intoString:(NSString**)aString
{
  insist (aString && stopLocation >= startLocation);
  
  NSString*string = [self string];
  insist (string);
  
  if (stopLocation <= startLocation || stopLocation > [string length]) return NO;
  
  *aString = [[string substringWithRange: NSMakeRange (startLocation, stopLocation - startLocation)]
    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  [self setScanLocation: stopLocation == [string length] ? stopLocation - 1: stopLocation];
  
  return YES;
}

- (BOOL) scanPast:(NSString*)s before:(NSString*)stopString
{
  unsigned location = [self scanLocation];
  
  /*find stop location*/
  [self scanUpToString:stopString intoString:nil];
  unsigned stopLocation = [self scanLocation];
  
  /*restore location*/
  [self setScanLocation:location];
  
  [self scanUpToString:s intoString:nil];
   
  /*see if we found something*/
  if (![self isAtEnd] && [self scanLocation] < stopLocation)
  {
    [self scanString:s intoString:nil];
    return YES;
  }
  /*not found. restore location*/
  [self setScanLocation: location];
  return NO;
}

- (int) getNearestLocationAndIndex:(int*)index among:(NSArray*)strings
{
  insist (strings && index && strings);
  
  int*distances = malloc (sizeof (unsigned) * [strings count]);
  insist (distances);
  
  /*now go and find the locations of all the strings*/
  for (int i = 0; i < [strings count]; i++)
  {
    int location = [self scanLocation];
    
    /*handle the case where the string is right at the scan location*/
    BOOL b = [self scanString:[strings objectAtIndex:i] intoString:nil];
    if (b)
    {
      [self setScanLocation:location];
      *index = i;
      return location;
    }
    b = [self scanUpToString:[strings objectAtIndex:i] intoString:nil] && ![self isAtEnd];
    distances [i] = b ? [self scanLocation] : -1;

    [self setScanLocation:location];
  }
  
  /*find the smallest location*/
  int location = -1;

  for (int i = 0; i < [strings count]; i++)
  {
    if (distances [i] < 0)
      continue;
    
    if (location < 0 || distances [i] < location)
    {
      location = distances [i];
      *index = i;
    }
  }
  
  free (distances);
  return location;  
}

- (BOOL) scanPastNearest:(NSString*) s, ...;
{
  va_list arg_list;
  id object;
  
  insist (s);
  
  /*first make an array to hold all the strings*/
  NSMutableArray*strings = [[[NSMutableArray alloc] init] autorelease];
  insist (strings);
  
  [strings addObject:s];
  va_start (arg_list, s);
  while ((object = va_arg (arg_list, NSString*)))
    [strings addObject:object];
  va_end (arg_list);
    
  /*now we have an array of strings. get the right string/location*/
  int index;
  int location = [self getNearestLocationAndIndex:&index among:strings];
  if (location < 0) return NO;
  
  /*scan past*/
  [self setScanLocation:location + [[strings objectAtIndex:index] length]];
  return YES;
}

- (BOOL) scanIntoString:(NSString**)aString upToNearest:(NSString*) s, ...;
{
  va_list arg_list;
  id object;
  
  insist (s);
  
  /*first make an array to hold all the strings*/
  NSMutableArray*strings = [[[NSMutableArray alloc] init] autorelease];
  insist (strings);
  
  [strings addObject:s];
  va_start (arg_list, s);
  while ((object = va_arg (arg_list, NSString*)))
    [strings addObject:object];
  va_end (arg_list);
  
  /*now we have an array of strings. get the right string/location*/
  int index;
  int location = [self getNearestLocationAndIndex:&index among:strings];
  if (location < 0) return NO;
  
  /*scan into*/
  if (!aString)
  {  
    [self setScanLocation:location];
    return YES;
  }
  return [self scanFrom:[self scanLocation] upTo:location intoString:aString];
}
@end