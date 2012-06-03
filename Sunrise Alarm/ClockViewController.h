//
//  ClockViewController.h
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clock.h"

@interface ClockViewController : UIViewController
{
    
}

@property (nonatomic, retain) IBOutlet Clock*portraitClock;
@property (nonatomic, retain) IBOutlet Clock*landscapeClock;
-(void)setDate:(NSDate*)date;
-(void)setWeather:(NSString*)weatherString;
-(void)setOnHidden:(BOOL)hidden;
@end
