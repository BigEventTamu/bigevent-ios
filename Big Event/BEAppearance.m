//  Big Event
//  Created by Jonathan Willing

#import "BEAppearance.h"

UIColor * BENavigationBarBackgroundTintColor() {
	return [UIColor colorWithRed:2 / 255.f green:95 / 255.f blue:50 / 255.f alpha:1];
}

UIColor * BENavigationBarTintColor() {
	return UIColor.whiteColor;
}

UIStatusBarStyle BEStatusBarStyle() {
	return UIStatusBarStyleLightContent;
}

void BEApplyAppearance() {
	// Navigation bar.
	UINavigationBar.appearance.tintColor = BENavigationBarTintColor();
	UINavigationBar.appearance.barTintColor = BENavigationBarBackgroundTintColor();
	UINavigationBar.appearance.titleTextAttributes = @{
		NSForegroundColorAttributeName: BENavigationBarTintColor()
	};
	
	// Status bar.
	UIApplication.sharedApplication.statusBarStyle = BEStatusBarStyle();
}
