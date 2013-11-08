//
//  TableHeadView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeadView : UIControl

@property (nonatomic, weak) id delegate;
@property int indexSection;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImView;
@property (weak, nonatomic) IBOutlet UIImageView *separateImView;
@property BOOL isSelected;


- (IBAction)didSelect:(id)sender;
@end
