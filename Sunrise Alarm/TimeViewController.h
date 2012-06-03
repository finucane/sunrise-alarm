//
//  TimeViewController.h
//  Sunrise Alarm
//
//  Created by finucane on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTableViewController.h"
#import "TimePickerViewController.h"

@interface TimeViewController : UIViewController
{
    
}

@property (retain, nonatomic) IBOutlet TimeTableViewController*timeTableViewController;
@property (retain, nonatomic) IBOutlet TimePickerViewController*timePickerViewController;

@end
