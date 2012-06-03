//
//  Clock.h
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Clock : NSObject
{
  @private
  NSDateComponents*currentComponents;
  NSDate*currentDate;
  NSDateFormatter*dateFormatter;
  NSArray*days;
}

@property (nonatomic, retain) IBOutlet UIView*view;
@property (nonatomic, retain) IBOutlet UILabel*bigTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel*smallTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel*colonLabel;
@property (nonatomic, retain) IBOutlet UILabel*sunLabel;
@property (nonatomic, retain) IBOutlet UILabel*monLabel;
@property (nonatomic, retain) IBOutlet UILabel*tueLabel;
@property (nonatomic, retain) IBOutlet UILabel*wedLabel;
@property (nonatomic, retain) IBOutlet UILabel*thuLabel;
@property (nonatomic, retain) IBOutlet UILabel*friLabel;
@property (nonatomic, retain) IBOutlet UILabel*satLabel;
@property (nonatomic, retain) IBOutlet UILabel*amLabel;
@property (nonatomic, retain) IBOutlet UILabel*pmLabel;
@property (nonatomic, retain) IBOutlet UILabel*dateLabel;
@property (nonatomic, retain) IBOutlet UILabel*weatherLabel;
@property (nonatomic, retain) IBOutlet UILabel*onLabel;


-(void)didLoad;
-(void)setFontBig:(float)big medium:(float)medium small:(float)small tiny:(float)tiny symbol:(float)symbol;
-(void)setDate:(NSDate*)date;
-(void)setOnHidden:(BOOL)hidden;

@end
