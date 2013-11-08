//
//  DragViewController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragViewController : UIViewController
{
    int firstX, firstY;
    UIPanGestureRecognizer *panRecognizer;
}

@property (assign, nonatomic) CGFloat shadowWidth;
@property (assign, nonatomic) BOOL canMove;
@property (assign, nonatomic) BOOL closed;

+ (CGFloat)getWidth;
- (void)openView;
- (void)closeView;

-(void)moveView:(id)sender;
@end
