//
//  UIView+Helpers.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helpers)

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

- (void)frameRoundToInt;
- (UIView *)findFirstResponder;

@end
