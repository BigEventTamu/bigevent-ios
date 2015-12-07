//  Big Event
//  Created by Jonathan Willing

#import "BERootViewController.h"
#import "BEFormViewController.h"
#import "BEClientController.h"
#import "BEOfflineQueue.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BERootViewController () <BEFormDelegate, BEOfflineQueueDelegate>

@property UILabel *toolbarLabel;
@property BEJobStubPage *currentJobStubsPage;

@end


@implementation BERootViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self configureHUD];
	[self registerNotifications];
	[self setupRefreshControl];
	[self setupOfflineQueue];
	
	// If not authenticated, present the accounts modal.
	if (!BEClientController.sharedController.client.authenticated) {
		[self performSegueWithIdentifier:BEAccountSegueIdentifier sender:nil];
	} else {
		[self reloadFormsCached:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self setupToolbar];
}

- (void)configureHUD {
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
	[SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
}

- (void)setupRefreshControl {
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refreshControlDidRefresh:) forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:refreshControl];
	self.refreshControl = refreshControl;
}

- (void)setupOfflineQueue {
	[BEClientController.sharedController.client.offlineQueue addDelegate:self];
}

- (void)setupToolbar {
	BEOfflineQueue *queue = BEClientController.sharedController.client.offlineQueue;
	if (queue.numberOfEnqueuedSubmissions > 0) {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
	
	UILabel *label = [[UILabel alloc] init];
	label.text = self.currentToolbarTitle;
	label.font = [UIFont systemFontOfSize:13];
	label.textAlignment = NSTextAlignmentCenter;
	label.frame = self.navigationController.toolbar.bounds;
	
	self.toolbarLabel = label;
	
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	NSArray *items = @[ spacer, labelItem, spacer ];
	
	self.navigationController.toolbar.items = items;
}


#pragma mark - Account Segue

- (IBAction)accountDone:(UIStoryboardSegue *)segue {
	NSAssert(BEClientController.sharedController.client.authenticated, @"accounts should not be dismissable unless authenticated");
	
	[self reloadFormsCached:NO];
}


#pragma mark - Notifications

- (void)registerNotifications {
	NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
	[nc addObserver:self selector:@selector(clientDidLogout:) name:BEClientDidLogoutNotification object:nil];
	[nc addObserver:self selector:@selector(clientDidSubmitForm:) name:BEClientDidSubmitFormNotification object:nil];
}

- (void)clientDidLogout:(NSNotification *)note {
	[self.tableView reloadData];
}

- (void)clientDidSubmitForm:(NSNotification *)note {
	[self reloadFormsCached:NO];
}


#pragma mark - Client

- (void)reloadFormsCached:(BOOL)shouldUseCache {
	[self.refreshControl beginRefreshing];
	
	BEClient *client = BEClientController.sharedController.client;
	client = shouldUseCache ? client.cache : client;
	
	[client requestJobStubsPageWithState:BEJobStubStateSurveyNeeded completion:^(BEJobStubPage *page) {
		if (page != nil) {
			[self handleReloadFormsSuccessWithPage:page];
		} else {
			[self handleReloadFormsFailureCached:shouldUseCache];
		}
	}];
}

- (void)handleReloadFormsSuccessWithPage:(BEJobStubPage *)page {
	self.currentJobStubsPage = page;
	
	[SVProgressHUD dismiss];
	[self.refreshControl endRefreshing];
	
	[self.tableView reloadData];
}

- (void)handleReloadFormsFailureCached:(BOOL)shouldUseCache {
	if (shouldUseCache) {
		// If we tried to use the cache and it didn't have anything, try to do
		// a normal network request.
		[self reloadFormsCached:NO];
	} else {
		[SVProgressHUD showErrorWithStatus:@"Unable to load latest jobs"];
		
		[self.refreshControl endRefreshing];
	}
}


#pragma mark - Offline Queue

- (NSString *)currentToolbarTitle {
	BEOfflineQueue *queue = BEClientController.sharedController.client.offlineQueue;
	return [NSString stringWithFormat:@"%li forms awaiting submission", queue.numberOfEnqueuedSubmissions];
}

- (void)offlineQueue:(BEOfflineQueue *)queue didEnqueueSubmission:(BEFormSubmission *)submission {
	self.toolbarLabel.text = self.currentToolbarTitle;
	
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)offlineQueue:(BEOfflineQueue *)queue didSubmitSubmission:(BEFormSubmission *)submission {
	self.toolbarLabel.text = self.currentToolbarTitle;

	if (queue.numberOfEnqueuedSubmissions == 0) {
		[self.navigationController setToolbarHidden:YES animated:YES];
	}
}


#pragma mark - Actions

- (void)refreshControlDidRefresh:(id)sender {
	[self reloadFormsCached:NO];
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
