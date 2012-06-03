//
//  Global.h
//  Sunrise Alarm
//
//  Created by finucane on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface Global : NSObject
{
  
}
+(Global*)sharedGlobal;
-(void)updateLocation; //do we ever use this?
-(void)updateAlarms;
-(void)updateWeather;
-(void)hideTabBar:(BOOL)hide animated:(BOOL)animated;
-(void)toggleTabBarAnimated:(BOOL)animated;
-(void)play;
-(void)stop;
-(void)snooze;
-(void)stopAlarm;
-(NSString*)timeString;

@end