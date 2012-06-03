//
//  TimePickerViewController.h
//  Sunrise Alarm
//
//  Created by finucane on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimePickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
}

-(void)setFromOffset:(int)offset;

@end
