#import "TableViewController.h"
#import "OnlineStoreController.h"
@implementation TableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if (!nibNameOrNil){
        nibNameOrNil = @"TableView";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [OnlineStoreController addToListName:@"Favorites" withDataStr:@"Top Stories"];
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController
- (void) viewDidUnload
{
	self.table = nil;
	[super viewDidUnload];
}

-(void)viewDidLoad {
	[super viewDidLoad];
    [self loadData];
    if (!self.table) {
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.table setDelegate:self];
        [self.table setDataSource:self];
        [self.table setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
	cellStyle = UITableViewCellStyleDefault;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView*)tableView {
    return 1;
}

- (NSInteger) tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
    return self.data ? [self.data count] : 0;
}

- (UITableViewCell*) tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
    NSString *cellIdentifier = [self tableView:tableView cellIdentifierForRowAtIndexPath:indexPath];
    
    UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == theCell) {
		if (nil == cellIdentifier){
			theCell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:@"default"];
        }
		else {
			NSArray *items = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
			theCell = [items objectAtIndex:0];
		}
        if (tableView.style == UITableViewStyleGrouped && [self respondsToSelector:@selector(cellSelectedBackgroundViewWithIndexPath:)]) {
            //            theCell.backgroundView = [self cellSelectedBackgroundViewWithIndexPath:indexPath];
        }
        [theCell setSelectionStyle:UITableViewCellSelectionStyleGray];
	}
	[self configureCell:theCell forRowAtIndexPath:indexPath];
	return theCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
- (NSString*) tableView: (UITableView*)tableView cellIdentifierForRowAtIndexPath: (NSIndexPath*)indexPath {
	return nil;
}

- (void) configureCell: (UITableViewCell*)theCell forRowAtIndexPath: (NSIndexPath*)indexPath {
	// overrided in subclasses
}

- (void)loadData {
	// overrided in subclasses
}

-(void)reload {
	[self loadData];
	[self.table reloadData];
}

@end
