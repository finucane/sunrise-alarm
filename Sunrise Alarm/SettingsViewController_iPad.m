//
//  SettingsViewController_iPad.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController_iPad.h"
#import "SettingsViewController.h"

@implementation SettingsViewController_iPad


- (void)viewDidLoad
{
  self.settingsTableViewController = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController_iPad" bundle:nil timeViewControllerNibName:@"TimeViewController_iPad"];

  [super viewDidLoad];
}


@end
