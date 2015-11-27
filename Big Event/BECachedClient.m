//  Big Event
//  Created by Jonathan Willing

#import "BECachedClient.h"
#import <PINCache/PINCache.h>

@interface BECachedClient()

@property BOOL shouldUseCache;
- (void)performWithCache:(void (^)(void))block;

@end


@interface BECachedClientProxy : NSProxy

@property BECachedClient *client;

@end


@implementation BECachedClientProxy

- (instancetype)initWithClient:(BECachedClient *)client {
	self.client = client;
	
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
	return [self.client methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	// Disable the cache while we perform the request.
	[self.client performWithCache:^{
		[invocation invokeWithTarget:self.client];
	}];
}

@end


@implementation BECachedClient


#pragma mark - Proxy

- (instancetype)cache {
	// Return a proxy object that wraps all method call to enable the cache.
	return (BECachedClient *)[[BECachedClientProxy alloc] initWithClient:self];
}

- (void)performWithCache:(void (^)(void))block {
	self.shouldUseCache = YES; // disabled in each request to prevent nesting
	block();
}


#pragma mark - Keying

static NSString * BECacheKeyJobStubs(BEAccount *account) {
	return [NSString stringWithFormat:@"%@-stubs", account.username];
}

#pragma mark - Caching

- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *))completion {
	NSString *key = BECacheKeyJobStubs(self.currentAccount);
	
	if (self.shouldUseCache) {
		self.shouldUseCache = NO;
		
		completion([PINCache.sharedCache objectForKey:key]);
		
		return;
	}
	
	[super requestJobStubsPageWithState:state completion:^(BEJobStubPage *page) {
		[PINCache.sharedCache setObject:page forKey:key];
		
		completion(page);
	}];
}


@end
