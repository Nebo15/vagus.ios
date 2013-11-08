//
//  UIAlertView+Interaction.h
//  CountDown
//
//  Created by Yalantis on 14.01.10.
//  Copyright 2010 Yalantis. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define DEFAULT_VIEWTAG			2130

#define DEFAULT_DELAY			0.9
#define DEFAULT_DURATION		0.35
#define DEFAULT_STARTSCALE		0.8
#define DEFAULT_MIDDLESCALE		1.1
#define DEFAULT_ENDSCALE		1.2
#define DEFAULT_FONTNAME		@"Helvetica-Bold"
#define DEFAULT_FONTSIZE		15.0f
#define DEFAULT_TEXTCOLOR		whiteColor
#define DEFAULT_TEXTALIGNMENT	NSTextAlignmentCenter
#define DEFAULT_VTEXTOFFSET		10.0f
#define DEFAULT_HTEXTOFFSET		10.0f
#define DEFAULT_RADIUS			8.0f
#define DEFAULT_BORDERWIDTH		1.0f
#define DEFAULT_ACTIVITYOFFSET	5.0f
#define MESSAGE_TAG	4001
#define DEFAULT_MESSAGEWIDTH	160.0


@interface UIAlertView (Interaction)

+ (void)displayError:(NSString *)message;
+ (void)displaySuccesMessageWithResponce:(NSDictionary *)dict;
+ (void)displayErrorWithResponce:(NSDictionary *)dict;
+ (void)displayError:(NSString *)message title:(NSString *)title;
+ (void)displayMessage:(NSString *)message;
+ (UIAlertView *)showAlert:(NSString *)message withActivity:(BOOL)activity;
+ (void)displayMessage:(NSString *)message withDelegate:(id)delegate;
+ (void)displayMessage:(NSString *)message title:(NSString *)title;

+ (void) showMessage:(NSString *)message withColor:(UIColor *)color;
+ (void)showLoadingViewWithMwssage:(NSString*)message;
+ (void)showAlertViewWithMessage:(NSString*)message;
+ (void) showMessage:(NSString *)message
	   textAlignment:(UITextAlignment)textAlignment
		withDuration:(NSTimeInterval)duration
			andDelay:(NSTimeInterval)delay
	 backgroundColor:(UIColor *)backgroundColor
		 borderColor:(UIColor *)borderColor
		 shadowColor:(UIColor *)shadowColor
   massageOffsetSize:(CGSize)offsetSize
		 borderWidth:(CGFloat)borderWidth
		shadowRadius:(CGFloat)shadowRadius
		cornerRadius:(CGFloat)cornerRadius
		  startScale:(CGFloat)sScale
		 middleScale:(CGFloat)mScale
			endScale:(CGFloat)eScale
        activityView:(BOOL)isActivity
              inView:(UIView*)baseView;

+ (void)removeMessage;

@end
