//  Big Event
//  Created by Jonathan Willing

#import "BEFormTypeViewController.h"
#import "BEClientController.h"
#import "BEConstants.h"
#import "BEFormType.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BEFormTypeViewController ()

@property NSInteger currentSelection;
@property (strong) NSArray<BEFormType *> *formTypes;

@end

@implementation BEFormTypeViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.currentSelection = NSNotFound;
	
	if (!BEClientController.sharedController.client.authenticated) {
		[SVProgressHUD showErrorWithStatus:@"Not signed in"];
	} else {
		[self loadFormTypes];
	}
}


#pragma mark - Networking

- (void)loadFormTypes {
	[SVProgressHUD show];
	
	BEClient *client = BEClientController.sharedController.client;
	[client requestFormTypesWithCompletion:^(NSArray<BEFormType *> *types) {
		if (types != nil) {
			self.formTypes = types;
			
			[self.tableView reloadData];
			[self updateCurrentSelection];
			[SVProgressHUD dismiss];
		} else {
			[SVProgressHUD showErrorWithStatus:@"Error loading types"];
		}
	}];
}


#pragma mark - Selection

- (void)updateCurrentSelection {
	NSNumber *formTypeID = BEClientController.sharedController.client.currentFormTypeID;
	
	if (formTypeID == nil) {
		return;
	}
	
	NSInteger index = [self.formTypes indexOfObjectPassingTest:^BOOL(BEFormType *obj, NSUInteger idx, BOOL *stop) {
		return [obj.identifier isEqual:formTypeID];
	}];
	
	self.currentSelection = index;
	
	if (index != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.formTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.formTypes[section].detail;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	cell.textLabel.text = self.formTypes[indexPath.section].name;
	
	// Select if needed.
	if (indexPath.section == self.currentSelection) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:BEFormTypePopSegueIdentifier]) {
		BEFormType *selectedType = self.formTypes[self.tableView.indexPathForSelectedRow.section];
		BEClientController.sharedController.client.currentFormTypeID = selectedType.identifier;
	}
	
	return YES;
}

@end
