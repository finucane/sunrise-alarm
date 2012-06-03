//
//  Settings.m
//  Sunrise Alarm
//
//  Created by finucane on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "insist.h"

static Settings*sharedSettings = nil;
enum
{
  SUNRISE,
  CIVIL,
  NAUTICAL,
  ASTRONOMICAL
};


@implementation Settings

@synthesize time, vibrate, enabled, dayMask, snoozeMinutes, soundIndex, volume;
@synthesize offset, lat, lon, weather, vampire;

+ (NSString*)archivePath
{
  NSArray*paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  insist (paths && [paths count]);
  return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"settings"];

}


- (void)initTransient
{
  
  /*because we are playing these w/ notifications too these files are under 10 secs and all .wav*/
  sounds = [[NSArray arrayWithObjects:
             @"alarm_clock_ringing",
             @"card_reader_alarm",
             @"church_bells",
             @"police",
             @"baby_crying",  
             nil] retain];
  
  /*human readable names*/
  soundStrings = [[NSArray arrayWithObjects:
                   @"Alarm Clock Ring",
                   @"Annoying Beep",
                   @"Church Bells",
                   @"Police Siren",
                   @"Baby Crying",
                   nil] retain];
}

+(Settings*)sharedSettings
{
  if (sharedSettings == nil)
  {
    /*handle the case where we have been saved to disk before*/
    NSFileManager*fileManager = [NSFileManager defaultManager];
    insist (fileManager);

    if ([fileManager fileExistsAtPath:[Settings archivePath]])
    {
      sharedSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:[Settings archivePath]];
      [sharedSettings initTransient];
      return sharedSettings;
    }
    
    /*otherwise alloc an empty Settings object and init it with defaults*/
    sharedSettings = [[super allocWithZone:NULL] init];
  }
  return sharedSettings;
}
/*
+(id) allocWithZone:(NSZone*)zone
{
  return [[self sharedSettings] retain];
}
*/
- (void)archive
{
  [NSKeyedArchiver archiveRootObject:self toFile:[Settings archivePath]];
}
-(id)initWithCoder:(NSCoder*)coder
{
  insist (coder);
  self = [super init];
  insist(self);
  
  time = [coder decodeIntForKey:@"time"];
  dayMask = [coder decodeIntForKey:@"dayMask"];
  snoozeMinutes = [coder decodeIntForKey:@"snoozeMinutes"];
  soundIndex = [coder decodeIntForKey:@"soundIndex"];
  volume = [coder decodeFloatForKey:@"volume"];
  vibrate = [coder decodeBoolForKey:@"vibrate"];
  enabled = [coder decodeBoolForKey:@"enabled"];
  offset = [coder decodeIntForKey:@"offset"];
  lat = [coder decodeDoubleForKey:@"lat"];
  lon = [coder decodeDoubleForKey:@"lon"];
  weather = [coder decodeBoolForKey:@"weather"];
  vampire = [coder decodeBoolForKey:@"vampire"];
  return self;
}


-(void)encodeWithCoder:(NSCoder*)coder
{  
  insist (coder);
  
  [coder encodeInt:time forKey:@"time"];
  [coder encodeInt:dayMask forKey:@"dayMask"];
  [coder encodeInt:snoozeMinutes forKey:@"snoozeMinutes"];
  [coder encodeInt:soundIndex forKey:@"soundIndex"];
  [coder encodeFloat:volume forKey:@"volume"];
  [coder encodeBool:vibrate forKey:@"vibrate"];
  [coder encodeBool:enabled forKey:@"enabled"];
  [coder encodeInt:offset forKey:@"offset"];
  [coder encodeDouble:lat forKey:@"lat"];
  [coder encodeDouble:lon forKey:@"lon"];
  [coder encodeBool:weather forKey:@"weather"];
  [coder encodeBool:vampire forKey:@"vampire"];
}



/*this is called only when we aren't coming from an archive*/
- (id) init
{
  self = [super init];
  insist (self);

  time = SUNRISE;
  dayMask = 0x7f;  //7 set bits for all days on.
  snoozeMinutes = 1;
  soundIndex = 0;
  volume = 1.0;//max
  vibrate = NO;
  enabled = NO;
  offset = 0;  //is in minutes
  lat = lon = 0; //we start off not knowing where we were
  weather = YES; //check weather by default 
  vampire = NO;
  
  /*build stuff we don't archive*/
  [self initTransient];
  
  return self;
}

- (id) copyWithZone:(NSZone*)zone
{
  return self;
}

- (id) retain
{
  return self;
}

- (NSUInteger) retainCount
{
  return NSUIntegerMax;
}

/*this is magic stuff for the singleton class*/
- (void) release
{
}

- (id) autorelease
{
  return self;
}

- (int)getTime
{
  return time;
}

-(void)setTime:(int)aTime
{
  insist(time >= 0 && time < 4);
  time = aTime;
}

- (NSArray*)getTimeStrings
{
  return [NSArray arrayWithObjects:vampire ? @"Sunset" : @"Sunrise", @"Civil Twilight", @"Nautical Twilight", @"Astronomical Twilight", nil];
}

-(NSArray*)getSoundStrings
{
  return soundStrings;
}

-(NSURL*)urlForSound:(int)index
{
  return [[NSBundle mainBundle] URLForResource:[sounds objectAtIndex:index] withExtension:@"wav"];
}

-(NSString*)fileNameForSound:(int)index
{
  return [NSString stringWithFormat:@"%@.wav", [sounds objectAtIndex:index]];
}

-(NSString*)snoozeStringForInt:(int)minutes
{
  if (minutes == 1)
    return @"1 Minute";
  else
    return [NSString stringWithFormat:@"%d Minutes", minutes];
}

/*if the user has set at least 1 alarm*/
-(bool)on
{
  return enabled && dayMask;
}
@end
