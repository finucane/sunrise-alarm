//
//  ClockViewController_iPhone.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockViewController_iPhone.h"
#import "insist.h"

@implementation ClockViewController_iPhone



- (void)viewDidLoad
{
  insist (self.portraitClock && self.portraitClock != self.landscapeClock);
  [self.portraitClock setFontBig:100 medium:40 small:20 tiny:15 symbol:20];
  [self.landscapeClock setFontBig:130 medium:60 small:23 tiny:18 symbol:23];
  [super viewDidLoad];
}

@end
