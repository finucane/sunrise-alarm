//
//  SettingsTableViewController.m
//  Sunrise Alarm
//
//  Created by finucane on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TimeViewController.h"
#import "SoundViewController.h"
#import "RepeatViewController.h"
#import "SnoozeViewController.h"
#import "Global.h"
#import <AudioToolbox/AudioServices.h>

#import "insist.h"

@implementation SettingsTableViewController

@synthesize enableCell, enableSwitch, timeCell, snoozeCell, soundCell, repeatCell;
@synthesize volumeCell, volumeSlider, vibrateCell, vibrateSwitch;
@synthesize repeatLabel, soundLabel, snoozeLabel, timeLabel;
@synthesize weatherCell, weatherSwitch, vampireSwitch, vampireCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil timeViewControllerNibName:(NSString*)aName
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  insist (self);
  settings = [Settings sharedSettings];
  timeViewControllerNibName = [aName retain];
  self.navigationItem.title = @"Settings";
  return self;
}

- (void)dealloc
{
  [timeViewControllerNibName release];

  [enableCell release];
  [enableSwitch release];
  [volumeCell release];
  [volumeSlider release];
  [timeCell release];
  [repeatCell release];
  [snoozeCell release];
  [soundCell release];
  [vibrateCell release];
  [vibrateSwitch release];
  [weatherCell release];
  [weatherSwitch release];
  [repeatLabel release];
  [snoozeLabel release];
  [soundLabel release];
  [timeLabel release];
  [vampireSwitch release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


/*this is called every time we end up frontmost on the navigation stack. so when some view controller we call
  to change a setting gets done, we get a chance to update our own state here. and when we are pushed the first
  time, though we don't really need to worry about this case. but secondly we make sure the nav bar is hidden.*/

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{ 
  [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case 0: return 1;
    case 1: return 4;
    case 2: return 3;
    case 3: return 1;
  }
  return 0;
}

/*make a label of a list of abbreviated names for selected days*/
-(NSString*)getRepeatLabel
{
  int dayMask = settings.dayMask;
  NSMutableString*s = [[[NSMutableString alloc]init]autorelease];
  insist (s);
  
  NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
  insist (dateFormatter);
  NSArray*days = [dateFormatter shortWeekdaySymbols];
  insist (days);
  
  [dateFormatter release];
  
  /*handle the empty mask case*/
  if (!dayMask)
    return @"Never";
  if (dayMask == 0x7f) //111 1111
    return @"Everyday";
  
  for (int i = 0; i < 7; i++)
  {
    if (dayMask & (1 << i))
      [s appendString:[NSString stringWithFormat:@"%@ ", [days objectAtIndex:i]]];
  }
  return s;
}

/*
  each time we are requested a cell, make sure its state is up to date. this is somewhat lame,
  but it means whenever we change some setting in a subview from this one, we can just
  call reloadData to sync the table.
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int section = [indexPath section];
  int row = [indexPath row];
  
  switch (section)
  {
    case 0:
      enableSwitch.on = settings.enabled;
      return enableCell;
    case 1:
      if (row == 0)
      {
        timeLabel.text = [NSString stringWithFormat:@"%@ %@",
                          [Global sharedGlobal].timeString,
                          [[settings getTimeStrings] objectAtIndex:settings.time]];
        
        return timeCell;
      }
      if (row == 1)
      {
        repeatLabel.text = [self getRepeatLabel];
        return repeatCell;
      }
      if (row == 2)
      {
        snoozeLabel.text = [settings snoozeStringForInt:settings.snoozeMinutes];
        return snoozeCell;
      }
      vampireSwitch.on = settings.vampire;
      return vampireCell;
    case 2:
      if (row == 0) 
      {
        soundLabel.text = [[settings getSoundStrings]objectAtIndex:settings.soundIndex];
        return soundCell;
      }
      if (row == 1)
      {
        volumeSlider.value = settings.volume;
        return volumeCell;
      }
      vibrateSwitch.on = settings.vibrate;
      return vibrateCell;
    case 3:
      weatherSwitch.on = settings.weather;
      return weatherCell;
  }
  return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
  
  int section = [indexPath section];
  int row = [indexPath row];
  
  UIViewController*vc = nil;
  insist (timeViewControllerNibName);
  
 if (section == 1 && row == 0)
   vc = [[TimeViewController alloc]initWithNibName:timeViewControllerNibName bundle:nil];
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

- (IBAction)enabled:(id)sender
{
  settings.enabled = enableSwitch.on;
}
- (IBAction)vibrate:(id)sender
{
  settings.vibrate = vibrateSwitch.on;  
}
- (IBAction)weather:(id)sender
{
  /*remember the new setting, and if it's turning on, trigger a weather update*/
  if ((settings.weather = weatherSwitch.on))
    [[Global sharedGlobal]updateWeather];
}


/*when the vampire switch changes, recompute the alarm time because we are switching between am and pm.
  this is all just to get the time label in this table updated, when we leave settings this will all
  happen again, including all the scheduling. who cares?*/
- (IBAction)vampire:(id)sender
{
  insist (vampireSwitch && vampireSwitch == sender);
  settings.vampire = vampireSwitch.on;
  [[Global sharedGlobal] updateAlarms];
  [self.tableView reloadData];
  
}


- (IBAction)volume:(id)sender
{
  settings.volume = volumeSlider.value;
}

@end
