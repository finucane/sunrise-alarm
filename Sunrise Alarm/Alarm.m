//
//  Alarm.m
//  Sunrise Alarm
//
//  Created by finucane on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <AudioToolbox/AudioServices.h>
#import "Alarm.h"
#import "Settings.h"

#import "insist.h"


void soundCompletionProc(SystemSoundID  ssID,void*clientData);


@implementation Alarm

-(id)init
{
  self = [super init];
  insist (self);
  playing = NO;
  return self;
}


-(void)play
{
  /*make our life easy*/
  if (playing) return;
  
  Settings*settings = [Settings sharedSettings];
  
  /*if we are in vibrate mode, start vibrating*/
  if (settings.vibrate)
  {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    AudioServicesAddSystemSoundCompletion (kSystemSoundID_Vibrate, 0, 0, soundCompletionProc, self);
  }
  else
  {
    /*otherwise play the sound, looping*/
    
    NSURL*url = [settings urlForSound:[settings soundIndex]];
    insist (url);
    
    /*this should not exist, but ...*/
    [avPlayer release];
    avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    if (!avPlayer) return;//nothing we can do
    insist (avPlayer);

    avPlayer.volume = settings.volume;
    avPlayer.numberOfLoops = -1; //continuous
    [avPlayer play];
  }
  playing = YES;
}

/*it is safe to call this even when we aren't playing*/
-(void)stop
{
  /*do not trust the settings, they may have changed.*/
  if (avPlayer)
  {
    [avPlayer stop];
    [avPlayer release];
    avPlayer = nil;
  }

  /*in any case ...*/
  /*the vibration will just have to stop when it stops*/
  playing = NO;
}

/*if we are still supposed to be playing, play again, otherwise deregister the completion proc*/
-(void)soundCompletion: (SystemSoundID) ssID
{
  if (playing)
    AudioServicesPlaySystemSound (ssID);
  else
    AudioServicesRemoveSystemSoundCompletion (ssID);
}

/*this is called when a system sound -- just vibrate really -- ends.
  we use it to loop. one reason to only use this api for vibrate
  is that there's no volume control.
*/
void soundCompletionProc(SystemSoundID ssID, void*clientData)
{
  insist (clientData);
  Alarm*alarm = (Alarm*)clientData;
  [alarm soundCompletion:ssID];
}

@end