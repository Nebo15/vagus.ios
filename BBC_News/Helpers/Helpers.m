//
//  Helpers.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 16.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "Helpers.h"

#define BTN_TITLE_INSET   8
#define BTN_PADDING       8

@implementation Helpers

+ (UIButton *)createRedButtonWithTitle:(NSString *)titleText delegate:(id)delegate selector:(SEL)selector
{
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redButton setTitle:titleText forState:UIControlStateNormal];
    redButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [redButton setBackgroundImage:[UIImage imageNamed:@"btnBackg"] forState:UIControlStateNormal];
    [redButton setBackgroundImage:[UIImage imageNamed:@"btnBackgHighlight"] forState:UIControlStateHighlighted];
    redButton.frame = CGRectMake(0, 0, [titleText sizeWithFont:redButton.titleLabel.font].width + BTN_TITLE_INSET * 2, 26);
    [redButton addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];
    return redButton;
}

+ (UIButton *)createButtonWithNormalImg:(UIImage *)normalImg highlightImg:(UIImage *)highlightImg delegate:(id)delegate selector:(SEL)selector
{
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [redButton setBackgroundImage:normalImg forState:UIControlStateNormal];
    [redButton setBackgroundImage:highlightImg forState:UIControlStateHighlighted];
    redButton.frame = CGRectMake(0, 0, normalImg.size.width, normalImg.size.height);
    [redButton addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];
    return redButton;
}

+ (UIView *)createViewWithButtons:(NSArray *)buttonsArray
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat x = 0;
    for(int i = 0; i < buttonsArray.count; i++)
    {
        UIButton *btn = buttonsArray[i];
        CGFloat padding = ((i + 1 < buttonsArray.count) ? BTN_PADDING : 0);
        btn.x = x;
        btn.y = 0;
        [view addSubview:btn];
        view.width += btn.width + padding;
        view.height = btn.height;
        x += btn.width + padding;
    }
    return view;
}


@end
