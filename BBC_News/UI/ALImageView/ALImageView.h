//
//  ALImageView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 14.07.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALImageView;
@protocol ALImageLoadingProtocol <NSObject>
@optional
- (void)loadingImageFinished:(ALImageView *)imageView;
- (void)loadingImageFailed:(ALImageView *)imageView;
@end

@interface ALImageView : UIImageView{
    UIImage *placeholder;

    NSMutableData *receivedData;
    NSURLConnection *cn;
    NSString *placeholderName;
    UIActivityIndicatorView *activityView;
    UIImageView *customActivityView;
}

@property (weak) id <ALImageLoadingProtocol> delegate;
@property BOOL isLoaded;
@property (nonatomic,strong) NSURL *loadURL;

- (void)setImageCustom:(UIImage *)image;
- (void)loadWithURL:(NSURL *)url;
- (void)loadWithURL:(NSURL *)url andPlaceHolderImageNamed:(NSString*)placeholderImage;
- (void)loadSynchWithURL:(NSURL *)url;
@end
