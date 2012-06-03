//
//  SettingsViewController_iPhone.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController_iPhone.h"
#import "TimeViewController.h"
#import "SoundViewController.h"
#import "RepeatViewController.h"
#import "SnoozeViewController.h"
#import "SettingsViewController.h"
#import "insist.h"

@implementation SettingsViewController_iPhone


- (void)viewDidLoad
{
  self.settingsTableViewController = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController_iPhone" bundle:nil timeViewControllerNibName:@"TimeViewController_iPhone"];

  [super viewDidLoad];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  
  int section = [indexPath section];
  int row = [indexPath row];
  
  UIViewController*vc = nil;
  
  if (section == 1 && row == 0)
    vc = [[TimeViewController alloc]initWithNibName:@"TimeViewController_iPhone" bundle:nil];
  else if (section == 1 && row == 1)
    vc = [[RepeatViewController alloc] init];
  else if (section == 1 && row == 2)
    vc = [[SnoozeViewController alloc] init];
  else if (section == 2  && row == 0)
    vc = [[SoundViewController alloc]init];
  
  if (vc)
  {
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
  }
}

@end
