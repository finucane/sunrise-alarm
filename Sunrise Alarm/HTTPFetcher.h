//
//  HTTPFetcher.h
//
//  Created by finucane on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPFetcher : NSObject
{
  @private
  NSTimer*timer;
  NSTimeInterval timeout;
  NSMutableData*data;
  NSURLConnection*connection;
  id delegate;
}

- (id)initWithDelegate:(id)aDelegate;
- (NSString*)stringFromData:(NSData*)data;
- (void)go:(NSString*)url withTimeout:(NSTimeInterval)aTimeout;
- (void)cancel;
@end


/*classes that use HTTPFetcher implement these delegate methods.*/

@protocol HTTPFetcherDelegate <NSObject>
@required
- (void)didFinish:(HTTPFetcher*)fetcher withData:(NSData*)data;
- (void)didFail:(HTTPFetcher*)fetcher withError:(NSString*)error;
- (void)didTimeout:(HTTPFetcher*)fecher;
@end
