//
//  Helpers.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 16.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5         (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA           ([[UIScreen mainScreen] scale] == 2.0f)
#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SCREEN_ORIENTATION  [[UIApplication sharedApplication] statusBarOrientation]

#define DragViewClosedNotification  @"DragViewClosed"
#define DragViewOpenedNotification  @"DragViewOpened"

@interface Helpers : NSObject

+ (UIButton *)createGrayButtonWithTitle:(NSString *)titleText delegate:(id)delegate selector:(SEL)selector;
+ (UIButton *)createButtonWithNormalImg:(UIImage *)normalImg highlightImg:(UIImage *)highlightImg delegate:(id)delegate selector:(SEL)selector;
+ (UIView *)createViewWithButtons:(NSArray *)buttonsArray;

@end
