//
//  ALImageView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 14.07.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "ALImageView.h"

#define ANIMATION_DURATION .3

@implementation ALImageView

- (void)setupView
{
    if(!customActivityView)
    {
        customActivityView = [[UIImageView alloc] init];
        
        customActivityView.animationImages = @[[UIImage imageNamed:@"loadingNew1"],
                                               [UIImage imageNamed:@"loadingNew2"],
                                               [UIImage imageNamed:@"loadingNew3"],
                                               [UIImage imageNamed:@"loadingNew4"]];

        customActivityView.animationDuration = 0.5;
        CGSize activityViewSize = CGSizeMake(34, 34);
        customActivityView.frame = CGRectMake(0, 0, activityViewSize.width, activityViewSize.height);
        customActivityView.center = CGPointMake(self.width / 2, self.height / 2);
        [self addSubview:customActivityView];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setupView];        
    }
    return self;
}

#pragma mark Cancel and Clear

-(void)stopLoading {
    [cn cancel];
    cn = nil;
    [receivedData setLength:0];
}

- (void)clearDelegatesAndCancel {
    self.delegate = nil;
    [cn cancel];
}

-(void)dealloc {
    [self hideActivityView];
    [activityView removeFromSuperview];
    [self clearDelegatesAndCancel];
    placeholder = nil;
    receivedData = nil;
}


-(void)setImageCustom:(UIImage *)newImage {
    if (newImage){
        if ([self isAnimating]) {
            [self stopAnimating];
        }
        [receivedData setLength:0];
        self.image = newImage;
        newImage = nil;
        self.isLoaded = YES;
    }else {
        [self setImage:nil];
    }
}

#pragma mark ActivityView

-(void)showActivityView {
    if (!self.image) {
        customActivityView.hidden = NO;
        [customActivityView startAnimating];
    }
}

-(void)hideActivityView {
    customActivityView.hidden = YES;
    [customActivityView stopAnimating];
}

#pragma mark Connection

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection
                   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    /* this application does not use a NSURLCache disk or memory cache */
#ifdef NSLOG
    NSLog(@"LLI used cached response for link %@", [loadURL absoluteString]);
#endif
    NSCachedURLResponse *memOnlyCachedResponse =
    [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response
                                             data:cachedResponse.data
                                         userInfo:cachedResponse.userInfo
                                    storagePolicy:NSURLCacheStorageAllowed];
    return memOnlyCachedResponse;
    //    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)restartConnection {
    [self stopLoading];
    [self loadWithURL:self.loadURL];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self performSelector:@selector(restartConnection) withObject:nil afterDelay:3];
    if (_delegate && [_delegate respondsToSelector:@selector(loadingImageFailed:)]) {
        [_delegate performSelector:@selector(loadingImageFailed:) withObject:self];
    }
}

- (void)loadWithURL:(NSURL *)url andPlaceHolderImageNamed:(NSString*)placeholderImage{
    placeholderName = placeholderImage;
    [self loadWithURL:url];
}

- (void)loadWithURL:(NSURL *)url
{
//    self.image = nil;
    [self showActivityView];
	
    self.loadURL = url;
    self.isLoaded = NO;
    if (!receivedData)
        receivedData = [[NSMutableData alloc] init];
    if (cn) {
        [self stopLoading];
        cn = nil;
    }
    cn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5] delegate:self startImmediately:NO];
    [cn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode: NSRunLoopCommonModes];
    [cn start];
}

- (void)loadSynchWithURL:(NSURL *)url
{
    [self setContentMode:UIViewContentModeScaleAspectFill];
	self.loadURL = url;
    self.isLoaded = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData *data = nil;
        data = [NSData dataWithContentsOfURL:url];
        UIImage *image = nil;
        if (!data || [data length] == 0) {
            
        }else{
            @synchronized(data) {
                image = [UIImage imageWithData:data];
                self.isLoaded = YES;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image)
                self.alpha = 0;
            [self setImageCustom:image];
            self.isLoaded = YES;
        });
        
        [self finishCallBack];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideActivityView];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        @autoreleasepool {
            UIImage *image = nil;
            if (!receivedData || [receivedData length] == 0) {
                //            image = [UIImage imageNamed:placeholderName];
                NSRange range = [self.loadURL.absoluteString rangeOfString:@"iphone-retina"];
                if (range.length > 0) {
                    NSMutableString *mutableUrl = [self.loadURL.absoluteString mutableCopy];
                    [mutableUrl replaceCharactersInRange:range withString:@"iphone"];
                    [self loadWithURL:[NSURL URLWithString:mutableUrl]];
                }
            }else{
                @synchronized(receivedData) {
                    image = [UIImage imageWithData:receivedData];
                    if (!image) {
                        NSRange range = [self.loadURL.absoluteString rangeOfString:@"iphone-retina"];
                        if (range.length > 0) {
                            NSMutableString *mutableUrl = [self.loadURL.absoluteString mutableCopy];
                            [mutableUrl replaceCharactersInRange:range withString:@"iphone"];
                            [self loadWithURL:[NSURL URLWithString:mutableUrl]];
                        }
                    }
                    self.isLoaded = YES;
                }
            }
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setAlpha:0];
                if (image)
                    [self setImageCustom:image];
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    [self setAlpha:1];
                }];
            });
        }
            [self finishCallBack];
    });
}

-(void)finishCallBack {
    dispatch_async(dispatch_get_main_queue(), ^{
    if (_delegate && [_delegate respondsToSelector:@selector(loadingImageFinished:)]) {
        [_delegate performSelector:@selector(loadingImageFinished:) withObject:self];
    }
    });
}


@end
