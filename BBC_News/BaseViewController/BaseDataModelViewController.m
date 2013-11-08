//
//  BaseDataModelNavigationView.m
//  BBC_News
//
//  Created by Edwin Zuydendorp on 3/12/12.
//  Copyright (c) 2012 QQQ. All rights reserved.
//

#import "BaseDataModelViewController.h"
#import "DataStoreAbstract.h"
#import "OnlineStoreController.h"

@implementation BaseDataModelViewController

- (void)dealloc
{
    [self.dataModel setDelegate:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self createModel];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibNameOrNil && [[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@".xib"]) {
        nibNameOrNil = NSStringFromClass([self class]);
    }
    if (nibNameOrNil && ![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSString *iPadNibNameOrNil = [NSString stringWithFormat:@"%@_iPad",nibNameOrNil];
        if ([[NSBundle mainBundle] pathForResource:iPadNibNameOrNil ofType:@"nib"]) {
            nibNameOrNil = iPadNibNameOrNil;
        }
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self createModel];
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


-(void)createMenuBtn{
//    UIBarButtonItem *left = [[UIBarButtonItem alloc]
//                             initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuSelected:)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 32)];
    [btn addTarget:self action:@selector(menuSelected:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateHighlighted];
    self.navigationItem.backBarButtonItem = nil;
    [btn setTintColor:[UIColor clearColor]];
//    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)createTitleImageWithImageName:(NSString*)name{
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    [self.navigationItem setTitleView:titleImage];
    [titleImage setAlpha:0.0];
    [UIView animateWithDuration:.1 animations:^{
        [titleImage setAlpha:1.0];
    }];
}

- (void)menuSelected:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryDoShow" object:nil];
}

#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    NSString *notificationKey = [self lastUpdateDateKey:self.dataModel];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dataBecomeObsolete)
                                                 name:notificationKey
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self createMenuBtn];
}

//Needs to be recolled in the subcalsses 
- (void)createModel{
    if (!self.dataModel) {
        self.dataModel = [[BaseDataModel alloc] initWithDelegate:self];
    }
}

- (void)dataBecomeObsolete{
    self.dataModel.isOutdated = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showModelDataIfPossible {    
    // Проверяем, была ли модель загружена
    // И находятся ли в ней актуальные данные
    if (! [[self dataModel] isLoaded]  && [[self dataModel] isOutdated]) {
        // Выполняем запрос асинхронно
        [self.dataModel loadData];
    } else {
        // В этом случае, у нас уже загруженная модель в который есть актуальные данные
        // Просто показываем ее содержимое
        [self showModelData:[self dataModel]];
    }
}

- (void)showModelData:(BaseDataModel*)model{
    
}

#pragma mark - Loading view showing

- (void)showLoading{
    [self showBackgroundInView:self.view animation:YES];
}

- (void)hideLoading{
    [super hideLoading];
}

- (void)showReloadScreen{
}

- (NSString*)lastUpdateDateKey:(id)model {
    return @"Default_LastRefresh";
}

#pragma mark - TTModelDelegate

- (void)modelDidStartLoad:(id)model {
    // Модель начала загрузку..
    // Здесь можно показать пользователю экран загрузки
    [self performSelectorInBackground:@selector(showLoading) withObject:nil];
//    [self showLoading];
}

- (void)modelDidFinishLoad:(id)model {
    // Не забываем убрать экран загрузки
    [self hideLoading];
    
    // Модель закончила загружаться
    // В ней теперь актуальные данные
    [self showModelData:self.dataModel];
}

- (void)model:(id)model didFailLoadWithError:(NSError*)error {
    // Не забываем убрать экран загрузки
    [self hideLoading];
    
    // Самый простой и совсем не User-Friendly вариант
//    [UIAlertView displayError:@"Error code #10"];
    NSLog(@"Error code #10");
    
    // Немного более User-Friendly вариант
    [self showReloadScreen];
//    self.reloadLabel.title = @"Something went wrong"
//    "But you could try to reload data";
}

- (void)modelDidCancelLoad:(id)model {
    // Не забываем убрать экран загрузки
    [self hideLoading];
    
    // Чаще всего этот метод обусловлен тем, 
    // что нам не нужна больше модель
    // и вообще, контроллер сейчас будет скрыт с экрана
    // По разному бывает
}

- (void)dataDidUpdated{
    
}

@end
