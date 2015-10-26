//  Big Event
//  Created by Jonathan Willing

#import "BERootViewController.h"
#import "BEClientController.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BERootViewController ()

@property (nonatomic, strong) BEJobStubPage *currentJobStubsPage;

@end


@implementation BERootViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Configure the shared progress HUD.
	[self configureHUD];
	
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
	[self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
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
	[client requestJobStubsPageWithState:BEJobStubStateSurveyNeeded completion:^(BEJobStubPage *page, BOOL success) {
		if (!success) {
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

@end
