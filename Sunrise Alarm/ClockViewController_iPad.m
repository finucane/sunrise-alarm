//
//  ClockViewController_iPad.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockViewController_iPad.h"
#import "insist.h"

@implementation ClockViewController_iPad


- (void)viewDidLoad
{
  insist (self.portraitClock && self.portraitClock != self.landscapeClock);
  [self.portraitClock setFontBig:200 medium:80 small:40 tiny:30 symbol:40];
  [self.landscapeClock setFontBig:260 medium:120 small:46 tiny:36 symbol:46];
  [super viewDidLoad];
}
@end
