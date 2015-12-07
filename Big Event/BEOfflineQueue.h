//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import "BEFormSubmission.h"

@class BEOfflineQueue;
@protocol BEOfflineQueueDelegate <NSObject>

- (void)offlineQueue:(BEOfflineQueue *)queue didEnqueueSubmission:(BEFormSubmission *)submission;
- (void)offlineQueue:(BEOfflineQueue *)queue didSubmitSubmission:(BEFormSubmission *)submission;

@end


@protocol BEOfflineQueueSubmissionDelegate <NSObject>

- (void)offlineQueue:(BEOfflineQueue *)queue submitObject:(BEFormSubmission *)submission completion:(void (^)(BOOL success))completion;

@end


@interface BEOfflineQueue : NSObject

- (instancetype)initWithSubmissionDelegate:(id<BEOfflineQueueSubmissionDelegate>)delegate;
- (void)addSubmission:(BEFormSubmission *)submission;

@property (nonatomic, readonly) BOOL internetReachable;

@property (nonatomic, readonly) NSArray<BEFormSubmission *> *allSubmissions;
@property (nonatomic, readonly) NSInteger numberOfEnqueuedSubmissions;

- (BOOL)submissionExistsWithRequestID:(NSString *)requestID;

// Add a delegate for listening to submission events.
- (void)addDelegate:(id<BEOfflineQueueDelegate>)delegate; // weak ref

@end
