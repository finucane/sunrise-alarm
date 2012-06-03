//
//  SettingsTableViewController.h
//  Sunrise Alarm
//
//  Created by finucane on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface SettingsTableViewController : UITableViewController
{
  Settings*settings;
  NSString*timeViewControllerNibName;
}

@property (nonatomic, retain) IBOutlet UITableViewCell*enableCell;
@property (nonatomic, retain) IBOutlet UISwitch*enableSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell*volumeCell;
@property (nonatomic, retain) IBOutlet UISlider*volumeSlider;
@property (nonatomic, retain) IBOutlet UITableViewCell*timeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*repeatCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*snoozeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*soundCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*vibrateCell;
@property (nonatomic, retain) IBOutlet UISwitch*vibrateSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell*weatherCell;
@property (nonatomic, retain) IBOutlet UISwitch*weatherSwitch;
@property (nonatomic, retain) IBOutlet UILabel*repeatLabel;
@property (nonatomic, retain) IBOutlet UILabel*snoozeLabel;
@property (nonatomic, retain) IBOutlet UILabel*soundLabel;
@property (nonatomic, retain) IBOutlet UILabel*timeLabel;
@property (nonatomic, retain) IBOutlet UISwitch*vampireSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell*vampireCell;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil timeViewControllerNibName:(NSString*)aName;

- (IBAction)enabled:(id)sender;
- (IBAction)vibrate:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)weather:(id)sender;
- (IBAction)vampire:(id)sender;

@end
