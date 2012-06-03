//
//  AlarmViewController.m
//  Sunrise Alarm
//
//  Created by finucane on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "Global.h"
#import "insist.h"

@implementation AlarmViewController

@synthesize snoozeButton, stopButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
      snoozeHidden = NO;
    }
    return self;
}

/*if we have been loaded from nib already hide / show the snooze button.
  otherwise we'll do this when the view loads
*/

- (void)setSnoozeHidden:(BOOL)hidden
{
  snoozeHidden = hidden;
  if (snoozeButton)
    snoozeButton.hidden = hidden;
}
- (void)dealloc
{
  [snoozeButton release];
  [stopButton release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  insist (snoozeButton && stopButton);
  snoozeButton.hidden = snoozeHidden;
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

- (IBAction)snooze:(id)sender
{
  [[Global sharedGlobal]snooze];
}
- (IBAction)stop:(id)sender
{
  [[Global sharedGlobal]stopAlarm];
}

@end
