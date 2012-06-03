//
//  HTTPFetcher.m
//
//  Created by finucane on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPFetcher.h"
#import "insist.h"

@implementation HTTPFetcher   
  
/* the way we have designed this class is, after fetch: is called, however it ends, if it's
   a user cancel, a timeout, or success, the connection and data are no longer valid after
   the HTTPFetcher delegate method is called. cleanup is used internally to do this.
 
   it is a programmer error to release HTTPFetcher while it's still working. at least call
   cancel first.
*/

- (void) cleanup
{
  insist (data && connection);

  [data release];
  data = nil;
  [connection release]; 
  connection = nil;
}

/*this is called when our timer expires. it's the only way to determine if we've timed out. NSURLConnection doesn't
  know about timeouts*/

- (void) timeout:(NSTimer*)aTimer
{
  insist (aTimer && aTimer == timer && delegate);
  insist (connection && data);
  
  /*once cancel is called, its delegate will no longer get any calls. it should be ok to call go: again after this or release us.*/
    
  [connection cancel];
  
  [delegate didTimeout:self];
  [self cleanup];
}

/*handy methods for ourselves so we can clear and set timeouts*/
- (void) setTimer
{
  insist (!timer);
  timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeout:) userInfo:nil repeats:NO] retain];
  insist (timer);
}

- (void) clearTimer
{
  if (timer)
  {
    [timer invalidate];
    [timer release];
    timer = nil;
  }
}

/*these are the delegate methods that NSURLConnection calls to do its stuff*/

/*we aren't caching*/
-(NSCachedURLResponse *) connection:(NSURLConnection*) connection willCacheResponse:(NSCachedURLResponse*) cachedResponse
{
  return nil;
}

/*the connection got a reply. reset our timeout since we know the server is alive*/
- (void) connection:(NSURLConnection*) aConnection didReceiveResponse:(NSURLResponse*) response
{ 
  [self clearTimer];
  [self setTimer];
  
  insist (data);

  /*because of redirects, this method might be called more than once, before we get the right data. so in any case
    make sure whatever else we might have collected in data is cleared*/
  
  [data setLength:0];
}


/*we got some data. append to it and reset the timers. timers are called on the same thread runloop as we are on, so our timer
  cannot go off inside this function.*/
- (void) connection:(NSURLConnection*) aConnection didReceiveData:(NSData*) someData
{
  insist (data);
  
  [data appendData:someData];
  
  [self clearTimer];
  [self setTimer];
}


/*the entire load finished. clean up timers and stuff and notify our HTTPFetcher delegate*/
 - (void) connectionDidFinishLoading:(NSURLConnection*) aConnection
{
  insist (delegate && connection && connection == aConnection);
  [self clearTimer];   
  
  NSData*d = [[data retain] autorelease];
  [self cleanup];
  [delegate didFinish:self withData:d];
}

/* there was an error. notify our HTTPFetcher delegate*/
- (void) connection:(NSURLConnection*) aConnection didFailWithError:(NSError*) error
{
  insist (delegate && connection && connection == aConnection);
  
  [self clearTimer];
  [self cleanup];
  [delegate didFail:self withError: [error localizedDescription]];
}


- (id)initWithDelegate:(id)aDelegate
{
  insist (aDelegate);
  
  self = [super init];
  insist (self);
  delegate = aDelegate;  //do not retain delegates
  return self;
}

- (void)dealloc
{
  insist (!data);
  insist (!timer);
  insist (!connection);
  [super dealloc];
}


/*get some kind of string, trying various encodings, from raw HTTP data. caller must retain if it wants to keep the string around.*/

- (NSString*)stringFromData:(NSData*)someData
{
  insist (someData);
  NSString*s = [[NSString alloc] initWithBytes:(void*)[someData bytes] length:[someData length] encoding:NSUTF8StringEncoding];
  if (!s)
    s = [[NSString alloc] initWithBytes:(void*)[someData bytes] length:[someData length] encoding:NSASCIIStringEncoding];
  return [s autorelease];
}


- (void) cancel
{
  insist (connection);
  [connection cancel];
  [self clearTimer];
  [self cleanup];
}


- (void)go:(NSString*)url withTimeout:(NSTimeInterval)aTimeout
{
  insist (delegate && !data && !connection && !timer);
  timeout = aTimeout;
  
  NSURL*aURL = [NSURL URLWithString:url];
  if (!aURL)
  {
    [delegate didFail:self withError:@"Malformed URL."];
    return;
  }
  
  /*in practice NSURLRequest timeouts are a mess. it's not clear what the error code is for timeout, and there's a minimum timeout
    which is not specified, and also we can do a more fine grained thing on our own, timing out on each interaction with the server, rather
    than on the entire transfer. (although, who knows? NSURLRequest might do this.) anyway we set the request's timeout as massive so it won't ever happen.*/
  
  NSURLRequest*request = [NSURLRequest requestWithURL:aURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60*60];
  insist(request);
  
  /*get a data object to collect the http data*/
  data = [[NSMutableData alloc] init];
  insist (data);
  
  /*start loading the url*/
  if (!(connection = [NSURLConnection connectionWithRequest:request delegate:self]))
  {
    [delegate didFail:self withError:@"Couldn't connect."];
    [data release]; data = nil;
    return;
  }
  [connection retain];
  /*done. the HTTPFetcherDelegate will be told when the load fails or succeeds*/
}

@end
