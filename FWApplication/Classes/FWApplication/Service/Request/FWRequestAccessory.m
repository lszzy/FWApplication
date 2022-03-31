//
//  FWRequestAccessory.m
//  FWNetwork
//
//  Created by Chuanren Shang on 2020/8/17.
//

#import "FWRequestAccessory.h"

@implementation FWRequestAccessory

- (void)requestWillStart:(id)request {
    if (self.willStartBlock != nil) {
        self.willStartBlock(request);
        self.willStartBlock = nil;
    }
}

- (void)requestWillStop:(id)request {
    if (self.willStopBlock != nil) {
        self.willStopBlock(request);
        self.willStopBlock = nil;
    }
}

- (void)requestDidStop:(id)request {
    if (self.didStopBlock != nil) {
        self.didStopBlock(request);
        self.didStopBlock = nil;
    }
}

@end

@implementation FWBaseRequest (FWRequestAccessory)

- (void)startWithWillStart:(nullable FWRequestCompletionBlock)willStart
                  willStop:(nullable FWRequestCompletionBlock)willStop
                   success:(nullable FWRequestCompletionBlock)success
                   failure:(nullable FWRequestCompletionBlock)failure
                   didStop:(nullable FWRequestCompletionBlock)didStop {
    FWRequestAccessory *accessory = [FWRequestAccessory new];
    accessory.willStartBlock = willStart;
    accessory.willStopBlock = willStop;
    accessory.didStopBlock = didStop;
    [self addAccessory:accessory];
    [self startWithCompletionBlockWithSuccess:success
                                      failure:failure];
}

@end

@implementation FWBatchRequest (FWRequestAccessory)

- (void)startWithWillStart:(nullable void (^)(FWBatchRequest *batchRequest))willStart
                  willStop:(nullable void (^)(FWBatchRequest *batchRequest))willStop
                   success:(nullable void (^)(FWBatchRequest *batchRequest))success
                   failure:(nullable void (^)(FWBatchRequest *batchRequest))failure
                   didStop:(nullable void (^)(FWBatchRequest *batchRequest))didStop {
    FWRequestAccessory *accessory = [FWRequestAccessory new];
    accessory.willStartBlock = willStart;
    accessory.willStopBlock = willStop;
    accessory.didStopBlock = didStop;
    [self addAccessory:accessory];
    [self startWithCompletionBlockWithSuccess:success
                                      failure:failure];
}

@end
