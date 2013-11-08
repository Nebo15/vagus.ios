//
//  ZoomPopoverView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomPopoverView : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *sliderView;

- (IBAction)valueChanged:(id)sender;

@end
