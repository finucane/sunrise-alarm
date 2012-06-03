//
//  TimePickerViewController.m
//  Sunrise Alarm
//
//  Created by finucane on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePickerViewController.h"
#import "Settings.h"
#import "insist.h"


@implementation TimePickerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [self setFromOffset:[Settings sharedSettings].offset];
  [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 2;
}

/*
 hours   minutes
 +2      0
 +1      15
 +0      30
 -0
 -1      45
 -2
*/

#define num_elems(a)(sizeof(a)/sizeof(a[0]))
#define MINUS_ZERO 3
static int hours [] = { +2, +1, 0, 0, -1, -2};
static int minutes [] = {0, 15, 30, 45};

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return component == 0 ? num_elems(hours) : num_elems(minutes);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  if (component == 0)
  {
    insist (row < num_elems(hours));
    int hour = hours [row];
    if (hour)
      return [NSString stringWithFormat:@"%+d Hour%@", hour, hour!= 1 ? @"s":@""];
    else
      return row == MINUS_ZERO ? @"-0 Hours" : @"+0 Hours";
  }
  else
  {
    insist (row < num_elems(minutes));
    return [NSString stringWithFormat:@"%d Minute%@", minutes [row], minutes [row] != 1 ? @"s":@""];
  }
}

/*compute the seconds offset from the current state of the picker and update settings*/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  /*get the values -- 1 level of indirection*/
  int hour = [pickerView selectedRowInComponent:0];
  int minute = [pickerView selectedRowInComponent:1];
  int sign = hour == MINUS_ZERO ? -1 : +1;
  
  insist (hour < num_elems(hours));
  insist (minute < num_elems(minutes));
  hour = hours [hour];
  minute = minutes [minute];
  
  /*get rid of sign on hour*/
  if (hour < 0)
  {
    sign = -1;
    hour *= -1;
  }
  
  int offset = sign * (hour * 60 + minute);
//  NSLog(@"offset is %d", offset);
  [Settings sharedSettings].offset = offset;
}

-(void)setFromOffset:(int)offset
{
  /*get rid of the minus sign*/
  int sign = 1;
  if (offset < 0)
  {
    offset *= -1;
    sign = -1;
  }
  
  int hour = offset / 60;
  int minute = offset % 60;
  
  /*find out which slot in the picker component fits for hours and mins*/
  
  /*put the sign back into the hour.*/
  hour *= sign;
  
  /*hours*/
  int i;
  for (i = 0; i < num_elems(hours); i++)
  {
    if (hours [i] == hour)
    {
      if (hour == 0 && sign == -1)
        i = MINUS_ZERO;
      break;
    }
  }
  insist (i < num_elems(hours));
  
  [(UIPickerView*)self.view selectRow:i inComponent:0 animated:NO];
  
  
  /*mins*/
  for (i = 0; i < num_elems(minutes); i++)
  {
    if (minutes [i] == minute)
      break;
  }
  insist (i < num_elems(minutes));
  
  [(UIPickerView*)self.view selectRow:i inComponent:1 animated:NO];
}

@end
