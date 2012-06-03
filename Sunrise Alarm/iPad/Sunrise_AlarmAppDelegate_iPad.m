//
//  Sunrise_AlarmAppDelegate_iPad.m
//  Sunrise Alarm
//
//  Created by finucane on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sunrise_AlarmAppDelegate_iPad.h"

@implementation Sunrise_AlarmAppDelegate_iPad

- (void)dealloc
{
	[super dealloc];
}


/*do app level device specific setup here*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  alarmViewController = [[AlarmViewController alloc] initWithNibName:@"AlarmViewController_iPad" bundle:nil];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
