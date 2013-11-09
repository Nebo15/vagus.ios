//
//  NetworkClient.h
//  BBC_News
//
//  Created by Evgen Bakumenko on 11/9/13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "AFHTTPClient.h"

@interface NetworkClient : AFHTTPClient
+ (NetworkClient*)sharedClient;
- (void)getFeedDataWithTag:(NSString*)tag completion:(void (^)(BOOL, NSData *))completion;
@end
