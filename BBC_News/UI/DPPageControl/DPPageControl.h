//
//  DPPageControl.h
//
//
//  Created by Vitalii Todorovych on 27.12.12.
//  Copyright (c) 2012  Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPPageControl : UIPageControl{
    UIImage* activeImage;
    UIImage* inactiveImage;
}

@property float offset;
@property float size;
-(void)updateDots;

@end
