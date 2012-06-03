//
//  YahooWeather.h
//  Sunrise Alarm
//
//  Created by finucane on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPFetcher.h"

@interface YahooWeather : NSObject <HTTPFetcherDelegate>
{
  @private
  id delegate;
  BOOL gettingWoeid;
  HTTPFetcher*fetcher;
}

-(id)initWithYahooWeatherDelegate:(id)aDelegate;
-(void)goWithLatitude:(double)lat longitude:(double)lon;

@end


/*simple protocol, on any kind of failure string will be nil.
  the ways this can fail are, no internet, yahoo goes bankrupt
 */

@protocol YahooWeatherDelegate <NSObject>
@required
- (void)weather:(YahooWeather*)weather gotWeather:(NSString*)string;
@end
