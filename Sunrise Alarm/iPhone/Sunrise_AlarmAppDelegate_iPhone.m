//
//  Sunrise_AlarmAppDelegate_iPhone.m
//  Sunrise Alarm
//
//  Created by finucane on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sunrise_AlarmAppDelegate_iPhone.h"

@implementation Sunrise_AlarmAppDelegate_iPhone

- (void)dealloc
{
	[super dealloc];
}
 

/*do app level device specific setup here*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  alarmViewController = [[AlarmViewController alloc] initWithNibName:@"AlarmViewController_iPhone" bundle:nil];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
