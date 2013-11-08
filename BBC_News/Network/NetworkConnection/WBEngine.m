//
//  WBEngine.m
//  WebsiteBuilder
//
//  Created by Yuri Kotov on 19.10.09.
//  Copyright 2009 Yalantis. All rights reserved.
//

#import "WBEngine.h"
#import "WBRequest.h"
#import "WBConnection.h"
#import "AppDelegate.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <netdb.h>

@implementation WBEngine

@synthesize errorMessage,isRepeatedRequest,description,hashingFlag,hashingKey;
#pragma mark -
#pragma mark NSURLConnectionDelegate
static bool        errorFlag;

- (void)connection:(WBConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	WBRequest *request = connection.request;
	
    [self closeLoadingView];
	id delegate = request.delegate;
	if (delegate && [delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
	{
		[delegate performSelector:@selector(connection:didReceiveResponse:) withObject:connection];
	}
    
}

- (void) connection: (WBConnection*)connection didReceiveData: (NSData*)data
{
	[connection appendData:data];
}

- (void) connectionDidFinishLoading: (WBConnection*)connection
{
#ifndef __OPTIMIZE__
    NSString *response;
        response = [[NSString alloc] initWithData:connection.data
												   encoding:NSUTF8StringEncoding];
        if (connection.data) {
//            NSLog(@"Received: \n%@", response);
        }
	#endif
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self closeLoadingView];
	WBRequest *request = connection.request;
	id delegate = request.delegate;
    
//    NSData *value = [connection data];
//    response = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    
	if (delegate && [delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
	{
		[delegate performSelector:@selector(connectionDidFinishLoading:) withObject:connection];
	}
    
}

-(void) showLoadingViewIn:(UIView *)superView loadingText:(NSString *)text{
    if (!loadingView) {
        loadingView = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    }
    [superView addSubview:loadingView.view];
    loadingView.titleLabel.text = text;
}


- (void) closeLoadingView{
    if(loadingView){
        [loadingView.view removeFromSuperview];
    }
}

- (void) connection: (WBConnection*)connection didFailWithError: (NSError*)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[UIAlertView removeMessage];
	NSLog(@"NSURLConnection error: %@ with code:%i", [error localizedDescription], [error code]);
    [self closeLoadingView];
	WBRequest *request = connection.request;
	id delegate = request.delegate;
	if (delegate && [delegate respondsToSelector:@selector(connection:didFailWithError:)])
	{
		[delegate performSelector:@selector(connection:didFailWithError:) withObject:connection withObject:error];
        return;
	}
    if (!errorFlag) {
        errorFlag = YES;
        if (errorMessage && [errorMessage length] > 0) {
            [UIAlertView displayMessage:errorMessage];
        }else if([AppDelegate isNetwork]){
            [UIAlertView displayMessage:NSLocalizedString(@"There is problem with server connections.", @"Er is op dit moment geen verbinding mogelijk. Probeer het later opnieuw.")];
        }else if(![AppDelegate isNetwork]){
            [UIAlertView displayError:NSLocalizedString(@"You have not access to this options.", @"") title:NSLocalizedString(@"Network connection is not available.", @"")];
        }
    }
}

#pragma mark -

- (BOOL) performRequest: (WBRequest*)request withHashingKey:(NSString *)_hashingKey{
    hashingFlag = YES;
//    NSData *data = [OSDNHash loadDataWithURL:_hashingKey];
//    if ((!data || data.length == 0) && [BredemeijerAppDelegate isNetwork]) {
//        self.hashingKey = _hashingKey;
        return [self performRequest:request];
//    }
//    self.hashingKey = nil;
//    WBConnection *connection = [[WBConnection alloc] initWithRequest:request
//															delegate:nil];
//    [connection.data appendData:data];
//    
//	id delegate = request.delegate;    
//    [self closeLoadingView];
////    if (loadingView) {	
////        SEL selector = @selector(removeFromSuperview);
////        [loadingView.view performSelector:selector withObject:self afterDelay:0.3f];
////    }
//    SEL selector = @selector(connectionDidFinishLoading:);
//	if (delegate && [delegate respondsToSelector:selector])
//	{
//		[delegate performSelector:selector withObject:connection];
//	}
//
//    return YES;
}

- (BOOL) performRequest: (WBRequest*)request
{
	BOOL success = NO;
    errorFlag = NO;
	success = YES;
	WBConnection *connection = [[WBConnection alloc] initWithRequest:request
															delegate:self];
	[connection start];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	return success;
}

-(void)dealloc
{
    if (loadingView) {
        [loadingView.view removeFromSuperview];
    }
}

@end



