//
//  Sunrise_AlarmAppDelegate.m
//  Sunrise Alarm
//
//  Created by finucane on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sunrise_AlarmAppDelegate.h"
#import "Global.h"
#import "Settings.h"
#import "insist.h"


@implementation Sunrise_AlarmAppDelegate

@synthesize window, tabBarController;


/*these 2 methods get called periodically to keep stuff up to date*/
-(void)updateClockLoop
{
  [clockViewController setDate:[NSDate date]];
  [self performSelector:@selector(updateClockLoop) withObject:nil afterDelay:1.0];
}


-(void)updateWeather
{
  /*if it's safe to, get the weather*/
  Settings*settings = [Settings sharedSettings];

  if (settings.weather && !gettingWeather && settings.lon != 0.0 && settings.lat != 0.0)
  {
    gettingWeather = YES;
    [weather goWithLatitude:settings.lat longitude:settings.lon];
  }
}

-(void)updateWeatherLoop
{
  [self updateWeather];
  
  /*reschedule for every 5 mins if the app is really left running.*/
  [self performSelector:@selector(updateWeatherLoop) withObject:nil afterDelay:5*60];
}

/*reset all the alarms. We call this whenever settings or locations have changed, whenever the app starts or wakes up.*/
-(void)updateAlarms
{
  Settings*settings = [Settings sharedSettings];
  [scheduler rescheduleLatitude:settings.lat longitude:settings.lon];
  
  /*also update the "on" indicator in the clock.*/
  [clockViewController setOnHidden:![settings on]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  
 // NSLog(@"didFinishLaunchingWithOptions");
  
  insist (self.tabBarController);
  self.tabBarController.view.backgroundColor = [UIColor blackColor];
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];
  
  /*get an alarm thing so we can play sounds*/
  alarm = [[Alarm alloc] init];
  insist (alarm);
  
  /*grab the clock view controller so we can fuck w/ it easily. we happen to know where it is*/
  clockViewController = [[[self.tabBarController viewControllers] objectAtIndex:0] retain];
  insist (clockViewController);
  
  /*make a weather thing and get a sample*/
  weather = [[YahooWeather alloc]initWithYahooWeatherDelegate:self];
  insist (weather);
  
  scheduler = [[Scheduler alloc] init];
  insist (scheduler);
  
    /*get a location manager*/
  locationManager = [[CLLocationManager alloc] init];
  insist (locationManager);
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;//we don't care about accuracy
  
  /*we keep track of if we are pending a weather update so we don't try it twice at the same time*/
  gettingWeather = NO;
  
  
  /*if we were launched because of an alarm, enter snooze*/
  UILocalNotification *notification =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
  if (notification)
  {
    //NSLog(@"didLaunch from notification, alarm should have been ringing.");
    
    [self updateAlarms];
    [scheduler snooze];
    [alarmViewController setSnoozeHidden:YES];
    [self.window.rootViewController presentModalViewController:alarmViewController animated:NO];
  }
  else
  {
    /*user launched app on his own*/
    /*start the process for updating location*/
    [self updateLocation];
  }
  
  /*this thing starts a continuous process of updating the weather every hour. it's the only
    time this method should be called. The other way to update weather uses the weather object
    directly, for instance after location changes.*/
  
  [self updateWeatherLoop];
  
  /*similar to updateWeather. start updating the clock every second*/
  [self updateClockLoop];
  
  return YES;
}

-(void)stop
{
  [alarm stop];
}

-(void)play
{
  [alarm stop];//anything currently running
  [alarm play];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
  
  /*make sure we don't have any location stuff going on that might trigger updates during
    a snooze when the app comes back to life*/
  
  [locationManager stopMonitoringSignificantLocationChanges];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */

  [[Settings sharedSettings]archive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  //NSLog(@"didBecomeActive");
  /*we might have been in the background for ages. try and get an updated location*/
  [self updateLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  
  /*should never be called*/
  
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

- (void)dealloc
{
  [alarm release];
  [window release];
  [tabBarController release];
  [clockViewController release];
  [scheduler release];
  [locationManager release];
  
  [weather release];
  [super dealloc];
}

- (void)weather:(YahooWeather*)weather gotWeather :(NSString*)weatherString
{
  insist (clockViewController);
  if (weatherString)
    [clockViewController setWeather:weatherString];
  gettingWeather = NO;
}

/*whenever we have a new location we have to update the weather, recompute dawn, and reset all the timers.*/
- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  insist (newLocation);
  
  /*save the location permanently so whenever the app starts it has something to reschedule alarms with.*/
  Settings*settings = [Settings sharedSettings];
  settings.lat = newLocation.coordinate.latitude;
  settings.lon = newLocation.coordinate.longitude;
  
  /*this will set the initial weather string, and also keep it up to date*/
  [self updateWeather];  
  [self updateAlarms];
  
  /*we have an updated location. turn off the location manager*/
  [locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if (status == kCLAuthorizationStatusAuthorized)
    [locationManager startMonitoringSignificantLocationChanges];
  else
    [locationManager stopMonitoringSignificantLocationChanges];
}


- (void)updateLocation
{
#if TARGET_IPHONE_SIMULATOR
  CLLocation*fakeLocation = [[[CLLocation alloc] initWithLatitude:34.052 longitude:-118.2478] autorelease];
  [self locationManager:locationManager didUpdateToLocation:fakeLocation fromLocation:nil];
#else   
  [locationManager startMonitoringSignificantLocationChanges];
#endif
}




- (void)hideTabBar:(BOOL)hide animated:(BOOL)animated
{
  UIView*tabBar = self.tabBarController.tabBar;
  
  if (animated)
  {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDuration:0.5];
  }
  [tabBar setAlpha:hide ? 0.0 : 1.0];       
  
  if (animated)
  {
    [UIView commitAnimations];
  }
}


- (void)toggleTabBarAnimated:(BOOL)animated
{
  UIView*tabBar = self.tabBarController.tabBar;
  [self hideTabBar: tabBar.alpha == 1.0 animated:animated];
}


/*called when the user touches snooze/stop buttons from the red/green buttoned view thing in the app.*/
- (void)snooze
{
  [alarm stop];
  [scheduler snooze];

  /*get rid of the snooze/stop modal. it will come back up after the snooze recurrs, that's the only
    way the user can ever finally stop the snooze. this makes more sense because it lets the user
    actually look at the clock.*/

  [self.window.rootViewController dismissModalViewControllerAnimated:YES];

  /*this was for when we didn't hide the modal, leave it in for posterity*/
  [alarmViewController setSnoozeHidden:YES];
}
- (void)stopAlarm
{
  /*make sure to prevent any snooze notifications as soon as possible,
    we are getting extra alarms even when the user presses stop*/
  
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
   
  [self.window.rootViewController dismissModalViewControllerAnimated:YES];
  [alarm stop];
  
  /*this will kill any pending snooze wakup notification*/
  [self updateAlarms];
  
  /*use this chance to update our location. there's a corner case,
    if we are waiting for an update and we are suspended in the background
   we can come up much later after an alarm and -- maybe - the location
   will finish then, triggering a reschedule of alarms which could kill
   a snooze. we handle this when the app goes to background by aborting
   any location stuff*/
  
  [self updateLocation];
}


/*
 this is called when an alarm goes off while the application is currently already launched.
 either it's running in the foreground, in which case we play the alarm,
 or was backgrounded, in which case we came in from the notification dialog box when the
 user pressed "snooze".
*/

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  /*
   we can't updateLocation because that can trigger resetting alarms which would kill the snooze.
   but at least we did reschedule any alarms with updateAlarms above, so we aren't going to
   drop any.
   */
  
  /*for testing when we stupidly are setting duplicate alarms*/
  if (self.window.rootViewController.modalViewController == alarmViewController)
    return;
  
  /*our strategy in this app is whenever we get a chance make sure the alarm scheduling is up to date*/
  [self updateAlarms];  
  
  /*try and get a weather string*/
  [self updateWeather];  

  if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
  {
    //NSLog(@"didReceiveLocalNotification already in foreground, ring alarm");
    /*we were already up. play the alarm and bring up the alarm view (stop/snooze)*/
    [alarm play];

    [alarmViewController setSnoozeHidden:NO];
    [self.window.rootViewController presentModalViewController:alarmViewController animated:YES];
  }
  else
  {
    /*we were in the background. bring dialog and schedule a snooze wakeup*/
    //NSLog(@"didReceiveLocalNotification in background, alarm should have been ringing.");
    [scheduler snooze];
    [alarmViewController setSnoozeHidden:YES];
    [self.window.rootViewController presentModalViewController:alarmViewController animated:NO];
  }
}

-(NSString*)timeString
{
  
  Settings*settings = [Settings sharedSettings];
  insist (settings);
  
  /*if we don't know where we are, we can't compute dawn*/
  if (settings.lon == 0.0 && settings.lat == 0)
    return @"";

  return [scheduler timeStringLat:settings.lat lon:settings.lon];
}

@end




/*
 
 dont be an ass and try to add appDelegate methods after this
 
 
*/





/*
  shim to get to some global functionality we're having appDelegate do. there must be
  a better way of doing this...but not on this app.
*/

static Global* sharedGlobal = nil;
@implementation Global

/*this is magic stuff for the singleton class*/
- (void) release
{
}

- (id) autorelease
{
  return self;
}


+(Global*)sharedGlobal
{
  if (sharedGlobal) return sharedGlobal;
  sharedGlobal = [[Global alloc] init];
  insist (sharedGlobal);
  return sharedGlobal;
}

-(void)updateLocation
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d updateLocation];
}

-(void)updateAlarms
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d updateAlarms];
}
-(void)hideTabBar:(BOOL)hide animated:(BOOL)animated
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d hideTabBar:hide animated:animated];
}
-(void)toggleTabBarAnimated:(BOOL)animated
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d toggleTabBarAnimated:animated];
}

-(void)play
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d play];
}

-(void)stop
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d stop];
}
-(void)snooze
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d snooze];
}

-(void)stopAlarm
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d stopAlarm];
}
-(void)updateWeather
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  [d updateWeather];
}

-(NSString*)timeString
{
  Sunrise_AlarmAppDelegate*d = (Sunrise_AlarmAppDelegate*)[[UIApplication sharedApplication] delegate];
  return [d timeString];
}


@end
