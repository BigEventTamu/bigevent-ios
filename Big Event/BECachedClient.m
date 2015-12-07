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


@interface BECachedClient ()

@property PINCache *diskCache;

@end


#define BEReturnCachedResultIfPossible \
id obj = [self.diskCache objectForKey:key]; \
if (self.shouldUseCache) { \
	self.shouldUseCache = NO; \
	if (obj != nil) { \
		completion([self.diskCache objectForKey:key]); \
		return; \
	} \
}

@implementation BECachedClient


#pragma mark - Lifecycle

- (instancetype)init {
	self = [super init];
	
	self.diskCache = [[PINCache alloc] initWithName:NSStringFromClass(self.class)];
	
	return self;
}

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

static NSString * BECacheKeyFormTypes(BEAccount *account) {
	return [NSString stringWithFormat:@"%@-form-types", account.username];
}

static NSString * BECacheKeyForm(BEAccount *account, NSNumber *formType) {
	return [NSString stringWithFormat:@"%@-%@-form", account.username, formType];
}


#pragma mark - Cache Invalidation

- (void)logout {
	[self.diskCache removeAllObjects];
	
	[super logout];
}


#pragma mark - Job Stubs

- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *))completion {
	NSString *key = BECacheKeyJobStubs(self.currentAccount);
	BEReturnCachedResultIfPossible
	
	[super requestJobStubsPageWithState:state completion:^(BEJobStubPage *page) {
		[self.diskCache setObject:page forKey:key];
		
		completion(page);
	}];
}


#pragma mark - Form Type

- (void)requestFormTypesWithCompletion:(void (^)(NSArray<BEFormType *> *))completion {
	NSString *key = BECacheKeyFormTypes(self.currentAccount);
	BEReturnCachedResultIfPossible
	
	[super requestFormTypesWithCompletion:^(NSArray<BEFormType *> *formTypes) {
		[self.diskCache setObject:formTypes forKey:key];
		
		completion(formTypes);
	}];
}


#pragma mark - Jobs

- (void)requestFormWithFormType:(NSNumber *)formTypeID completion:(void (^)(BEForm *))completion {
	NSString *key = BECacheKeyForm(self.currentAccount, formTypeID);
	BEReturnCachedResultIfPossible
	
	[super requestFormWithFormType:formTypeID completion:^(BEForm *form) {
		[self.diskCache setObject:form forKey:key];
		
		completion(form);
	}];
}

@end
