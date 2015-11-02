//  Big Event
//  Created by Jonathan Willing

#import "BERootViewController.h"
#import "BEFormViewController.h"
#import "BEClientController.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BERootViewController () <BEFormDelegate>

@property (nonatomic, strong) BEJobStubPage *currentJobStubsPage;

@end


@implementation BERootViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self configureHUD];
	[self registerNotifications];
	
	// If not authenticated, present the accounts modal.
	if (!BEClientController.sharedController.client.authenticated) {
		[self performSegueWithIdentifier:BEAccountSegueIdentifier sender:nil];
	} else {
		[self reloadForms];
	}
}

- (void)configureHUD {
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
	[SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
}


#pragma mark - Account Segue

- (IBAction)accountDone:(UIStoryboardSegue *)segue {
	NSAssert(BEClientController.sharedController.client.authenticated, @"accounts should not be dismissable unless authenticated");
	
	[self reloadForms];
}


#pragma mark - Notifications

- (void)registerNotifications {
	NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
	[nc addObserver:self selector:@selector(clientDidLogout:) name:BEClientDidLogoutNotification object:nil];
}

- (void)clientDidLogout:(NSNotification *)note {
	[self.tableView reloadData];
}


#pragma mark - Client

- (void)reloadForms {
	BEClient *client = BEClientController.sharedController.client;
	[client requestJobStubsPageWithState:BEJobStubStateSurveyNeeded completion:^(BEJobStubPage *page) {
		if (page == nil) {
			[SVProgressHUD showErrorWithStatus:@"Could not load forms"];
			return;
		}
		
		self.currentJobStubsPage = page;
		[self.tableView reloadData];
	}];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// TODO: different sections for form state?
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentJobStubsPage.stubs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	BEJobStub *stub = self.currentJobStubsPage.stubs[indexPath.row];
	cell.textLabel.text = stub.location.address1;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Survey Needed";
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:BEFormShowSegueIdentifier]) {
		BEJobStub *stub = self.currentJobStubsPage.stubs[self.tableView.indexPathForSelectedRow.row];
		
		BEFormViewController *formViewController = segue.destinationViewController;
		formViewController.delegate = self;
		formViewController.stub = stub;
	}
}

@end
