//
//  ClockViewController.m
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockViewController.h"
#import "Global.h"
#import "insist.h"


/*this thing is basically a wrapper around 2 views, portrait and landscape*/

@implementation ClockViewController
@synthesize portraitClock, landscapeClock;

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
  [portraitClock release];
  [landscapeClock release];
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


- (void)viewDidLoad
{
  [self.portraitClock didLoad];
  [self.landscapeClock didLoad];
  [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


/*
 when the app is running, the only time settings changes take effect is when the user dismisses the settings
 view. if the app goes to the background and comes back up, then the settings will also take effect, even
 if the settings view never went away. this is sort of ok, because we have no "save" button for settings.
 
 whenever settings goes away, clockview appears.
 */

- (void)viewWillAppear:(BOOL)animated
{ 
  [[Global sharedGlobal] updateAlarms];
  
  [super viewWillDisappear:animated];
  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if (!portraitClock.view) return YES; //this can be called before we are set up

  if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
  {
    self.view = portraitClock.view;
   // [[Global sharedGlobal] hideTabBar:NO animated:NO];
  }
  else
  {
    self.view = landscapeClock.view;
    //  [[Global sharedGlobal] hideTabBar:YES animated:NO];
  }
  return YES;
}

-(void)setWeather:(NSString*)weatherString
{
  if (!portraitClock.view) return; //this can be called before we are set up

  insist (portraitClock && landscapeClock && weatherString);
  portraitClock.weatherLabel.text = weatherString;
  landscapeClock.weatherLabel.text = weatherString;
}

-(void)setDate:(NSDate*)date
{
  if (!portraitClock.view) return; //this can be called before we are set up
  
  insist (portraitClock && landscapeClock && date);
  [portraitClock setDate:date];
  [landscapeClock setDate:date];
}

-(void)setOnHidden:(BOOL)hidden
{
  if (!portraitClock.view) return; //this can be called before we are set up
  insist (portraitClock && landscapeClock);
  [portraitClock setOnHidden:hidden];
  [landscapeClock setOnHidden:hidden];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [[Global sharedGlobal] toggleTabBarAnimated:YES];
}

@end
