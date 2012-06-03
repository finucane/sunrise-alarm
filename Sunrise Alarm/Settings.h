//
//  Settings.h
//  Sunrise Alarm
//
//  Created by finucane on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject
{
  @private
  NSArray*sounds;
  NSArray*soundStrings;
}

@property (nonatomic, assign) int time;
@property (nonatomic, assign) BOOL vibrate;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float soundIndex;
@property (nonatomic, assign) int snoozeMinutes;
@property (nonatomic, assign) int dayMask;
@property (nonatomic, assign) int offset;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) BOOL weather;
@property (nonatomic, assign) BOOL vampire;



+(Settings*)sharedSettings;
-(void)archive;
-(NSArray*)getSoundStrings;
-(NSArray*)getTimeStrings;
-(NSString*)snoozeStringForInt:(int)minutes;
-(NSURL*)urlForSound:(int)index;
-(NSString*)fileNameForSound:(int)index;

-(bool)on;
@end
