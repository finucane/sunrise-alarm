//
//  ScannerCategory.h 
//
//  Created by David Finucane on 12/9/05. 

#import <Foundation/Foundation.h>

@interface NSScanner (DFScannerCategory)

- (BOOL) scanPast:(NSString*)s;
- (BOOL) scanFrom:(unsigned)startLocation upTo:(unsigned)stopLocation intoString:(NSString**)aString;
- (BOOL) scanPast:(NSString*)s before:(NSString*)stopString;
- (int) distance:(NSString*)token;
- (BOOL) scanPastNearest:(NSString*) s, ...;
- (BOOL) scanIntoString:(NSString**)aString upToNearest:(NSString*) s, ...;
@end
