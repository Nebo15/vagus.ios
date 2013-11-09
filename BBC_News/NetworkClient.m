//
//  NetworkClient.m
//  BBC_News
//
//  Created by Evgen Bakumenko on 11/9/13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "NetworkClient.h"
#import <AFNetworking/AFXMLRequestOperation.h>

static NSString * const kVagusAPIBaseURLString = @"http://vagus.tv/feed/atom/";

@implementation NetworkClient

+ (NetworkClient *)sharedClient {
    static NetworkClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kVagusAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/atom+xml"];
    
    return self;
}

- (void)getFeedDataWithTag:(NSString *)tag completion:(void (^)(BOOL, NSData *))completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mimimi.me/?tag=video"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:tag];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        completion(YES, [NSData dataWithContentsOfFile:path]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(NO, nil);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = totalBytesRead / (float)totalBytesExpectedToRead;
        NSLog(@"Download Percentage: %f %%", progress*100);
    }];
    [operation start];

}

@end
