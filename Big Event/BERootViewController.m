//  Big Event
//  Created by Jonathan Willing

#import "BERootViewController.h"
#import "BEClient.h"

@interface BERootViewController ()

@end

@implementation BERootViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
	[self registerNotifications];
}


#pragma mark - Account Segue

- (IBAction)accountDone:(UIStoryboardSegue *)segue {
	NSLog(@"%s",__PRETTY_FUNCTION__);
}


#pragma mark - Notifications

- (void)registerNotifications {
	NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
	[nc addObserver:self selector:@selector(clientDidLogout:) name:BEClientDidLogoutNotification object:nil];
}

- (void)clientDidLogout:(NSNotification *)note {
	// remove forms
	NSLog(@"%s",__PRETTY_FUNCTION__);
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	cell.textLabel.text = @"test";
	
	return cell;
}

@end
