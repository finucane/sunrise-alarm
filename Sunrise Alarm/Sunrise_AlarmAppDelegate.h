//
//  Sunrise_AlarmAppDelegate.h
//  Sunrise Alarm
//
//  Created by finucane on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "YahooWeather.h"
#import "ClockViewController.h"
#import "Scheduler.h"
#import "Alarm.h"
#import "AlarmViewController.h"

@interface Sunrise_AlarmAppDelegate : NSObject <UIApplicationDelegate,YahooWeatherDelegate, CLLocationManagerDelegate>
{
  @private
  YahooWeather*weather;
  ClockViewController*clockViewController;
  CLLocationManager*locationManager;
  BOOL gettingWeather;
  Scheduler*scheduler;
  Alarm*alarm;
  
  @protected //device specific subclasses create this
  AlarmViewController*alarmViewController;
}

-(void)updateLocation;
-(void)hideTabBar:(BOOL)hide animated:(BOOL)animated;
-(void)toggleTabBarAnimated:(BOOL)animated;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController*tabBarController;

@end