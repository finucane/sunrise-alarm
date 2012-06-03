//
//  AlarmViewController.h
//  Sunrise Alarm
//
//  Created by finucane on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlarmViewController : UIViewController
{
  BOOL snoozeHidden;
}

@property (nonatomic, retain) IBOutlet UIButton*snoozeButton;
@property (nonatomic, retain) IBOutlet UIButton*stopButton;

- (IBAction)snooze:(id)sender;
- (IBAction)stop:(id)sender;
- (void)setSnoozeHidden:(BOOL)hidden;
@end
