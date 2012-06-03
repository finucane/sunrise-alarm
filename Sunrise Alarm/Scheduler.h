//
//  Scheduler.h
//  Sunrise Alarm
//
//  Created by finucane on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scheduler : NSObject
{
}

-(void)rescheduleLatitude:(double)latitude longitude:(double)longitude;
-(void)snooze;
-(NSString*)timeStringLat:(double)lat lon:(double)lon;
@end
