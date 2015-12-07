//  Big Event
//  Created by Jonathan Willing

#import "BEOfflineQueue.h"
#import "NSArray+BEHigherOrder.h"

#import <PINCache/PINCache.h>
#import <MSWeakTimer/MSWeakTimer.h>
#import <VCLReachability/VCLReachability.h>

static NSString * const BEOfflineQueueSubmissionsKey = @"submissions";

@interface BEOfflineQueue ()

@property PINCache *cache;
@property MSWeakTimer *reachabilityTimer;
@property id<NSCopying> currentSubmission;
@property NSMutableSet<BEFormSubmission *> *submissions;
@property NSHashTable<id<BEOfflineQueueDelegate>> *delegates;
@property (weak) id<BEOfflineQueueSubmissionDelegate> submissionDelegate;

@end


@implementation BEOfflineQueue

#pragma mark - Lifecycle

- (instancetype)initWithSubmissionDelegate:(id<BEOfflineQueueSubmissionDelegate>)delegate {
	self = [super init];
	
	self.submissionDelegate = delegate;
	self.delegates = [NSHashTable weakObjectsHashTable];
	self.cache = [[PINCache alloc] initWithName:NSStringFromClass(self.class)];
	
	NSSet *submissions = [self.cache objectForKey:BEOfflineQueueSubmissionsKey] ?: NSSet.set;
	self.submissions = submissions.mutableCopy;
	
	[self setupReachabilityMonitoring];
	
	return self;
}

- (void)setupReachabilityMonitoring {
	SEL selector = @selector(startSubmissionsIfReachable:);
	dispatch_queue_t queue = dispatch_get_main_queue();
	self.reachabilityTimer = [MSWeakTimer scheduledTimerWithTimeInterval:5.f target:self selector:selector userInfo:nil repeats:YES dispatchQueue:queue];
}

- (void)dealloc {
	[self.reachabilityTimer invalidate];
}


#pragma mark - Delegate

- (void)addDelegate:(id<BEOfflineQueueDelegate>)delegate {
	[self.delegates addObject:delegate];
	
	// Retroactively send delegate messages about already enqueued submissions.
	for (BEFormSubmission *submission in self.submissions) {
		[delegate offlineQueue:self didEnqueueSubmission:submission];
	}
}


#pragma mark - Submission Queue

- (NSInteger)numberOfEnqueuedSubmissions {
	return self.submissions.count;
}

- (NSArray<BEFormSubmission *> *)allSubmissions {
	return self.submissions.allObjects;
}

- (BOOL)submissionExistsWithRequestID:(NSString *)requestID {
	id obj = [self.submissions.allObjects be_findFirst:^BOOL(BEFormSubmission *submission) {
		return [submission.requestID isEqualToString:requestID];
	}];
	
	return (obj != nil);
}

- (void)addSubmission:(BEFormSubmission *)submission {
	[self.submissions addObject:submission];
	[self.cache setObject:self.submissions forKey:BEOfflineQueueSubmissionsKey];
	
	for (id<BEOfflineQueueDelegate> delegate in self.delegates) {
		[delegate offlineQueue:self didEnqueueSubmission:submission];
	}
}

- (void)submitNext {
	if (self.submissions.count > 0) {
		[self submit:self.submissions.anyObject];
	}
}

- (void)submit:(BEFormSubmission *)submission {
	self.currentSubmission = submission;
	NSLog(@"[offline] attempting to submit submission with ID: %@", submission.requestID);
	
	[self.submissionDelegate offlineQueue:self submitObject:submission completion:^(BOOL success) {
		self.currentSubmission = nil;

		if (success) {
			[self finalizeSubmission:submission];
			[self submitNext];
		} else {
			NSLog(@"[offline] submission not successful, re-enqueueing ID: %@", submission.requestID);
		}
	}];
}

- (void)finalizeSubmission:(BEFormSubmission *)submission {
	[self.submissions removeObject:submission];
	[self.cache setObject:self.submissions forKey:BEOfflineQueueSubmissionsKey];
	
	for (id<BEOfflineQueueDelegate> delegate in self.delegates) {
		[delegate offlineQueue:self didSubmitSubmission:submission];
	}
}

#pragma mark - Reachability

- (void)startSubmissionsIfReachable:(id)timer {
	if (self.currentSubmission == nil && self.internetReachable) {
		[self submitNext];
	}
}

- (BOOL)internetReachable {
	return (VCLReachability.currentReachabilityStatus != NotReachable);
}

@end
