//
//  DragViewController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "DragViewController.h"
#import <QuartzCore/QuartzCore.h>

#define DRAG_VIEW_PORTRAIT_WIDTH        260
#define DRAG_VIEW_LANDSCAPE_WIDTH       516
#define ANIM_DURATION                   0.2

@interface DragViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *shadowImg;

@end

@implementation DragViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RGBCOLOR(240, 240, 240)];
    [self enableDrag];
    [self setupView];
    
    if (UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
        self.canMove = YES;
    else
        self.canMove = NO;
}

#pragma mark - Methods

+ (CGFloat)getWidth
{
    if (UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
        return DRAG_VIEW_PORTRAIT_WIDTH;
    else
        return DRAG_VIEW_LANDSCAPE_WIDTH;
}

- (void)openView
{
    [UIView animateWithDuration:ANIM_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.x = self.view.superview.width - [DragViewController getWidth];
                     }
                     completion:^(BOOL finished) {
                         self.closed = NO;
                         [[NSNotificationCenter defaultCenter] postNotificationName:DragViewOpenedNotification object:nil];
                     }];
}

- (void)closeView
{
    [UIView animateWithDuration:ANIM_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.x = 0;
                     }
                     completion:^(BOOL finished) {
                         self.closed = YES;
                         [[NSNotificationCenter defaultCenter] postNotificationName:DragViewClosedNotification object:nil];
                     }];
}

- (void)setupView
{
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = NO;
    
    if(!self.shadowImg)
    {
        self.shadowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"borderShadow"]];
        [self.view addSubview:self.shadowImg];
        
        self.shadowImg.width = 10;
        self.shadowImg.height = self.view.height;
        self.shadowImg.x = -self.shadowImg.width;
        self.shadowImg.y = 0;
        self.shadowImg.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
}

- (void)enableDrag
{
    if(!panRecognizer)
    {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        panRecognizer.delegate = self;
    }
    self.canMove = YES;
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)disableDrag
{
    self.canMove = NO;
    [self.view removeGestureRecognizer:panRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)moveView:(id)sender
{    
    if (!self.canMove)
        return;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];

    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
    {
        firstX = [sender view].x;
        firstY = [sender view].y;
    }

    translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY);

    if(translatedPoint.x >= 0 && translatedPoint.x <= self.view.superview.width - [DragViewController getWidth])
    {
        self.view.x = translatedPoint.x;
        self.view.y = translatedPoint.y;
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
        CGFloat finalX = self.view.x;
        CGFloat finalY = self.view.y;
        
        if(finalX >= (self.view.superview.width - [DragViewController getWidth]) / 2)
        {
            finalX = self.view.superview.width - [DragViewController getWidth];
            self.closed = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DragViewOpenedNotification object:nil];
        }
        else
        {
            finalX = 0;
            self.closed = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:DragViewClosedNotification object:nil];
        }

        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;

        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGPoint position = CGPointMake(finalX, finalY);
                             [sender view].x = position.x;
                             [sender view].y = position.y;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}


@end
