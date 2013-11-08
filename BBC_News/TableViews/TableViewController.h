#import "BaseDataModelViewController.h"

@interface TableViewController : BaseDataModelViewController
<
	UITableViewDataSource,
	UITableViewDelegate
>
{
	NSInteger cellStyle;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *titles;

- (void)loadData;
- (NSString*) tableView: (UITableView*)tableView cellIdentifierForRowAtIndexPath: (NSIndexPath*)indexPath;
- (void) configureCell: (UITableViewCell*)theCell forRowAtIndexPath: (NSIndexPath*)indexPath;
- (void)reload;
@end
