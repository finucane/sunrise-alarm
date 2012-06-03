//
//  Alarm.h
//  Sunrise Alarm
//
//  Created by finucane on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Alarm : NSObject
{
  BOOL playing;
  AVAudioPlayer*avPlayer;
}

-(void)play;
-(void)stop;

@end
