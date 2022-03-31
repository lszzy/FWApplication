//
//  FWChainRequest.m
//
//  Copyright (c) 2012-2016 FWNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "FWChainRequest.h"
#import "FWRequestAgent.h"
#import "FWNetworkPrivate.h"
#import "FWBaseRequest.h"

@interface FWChainRequest()<FWRequestDelegate>

@property (strong, nonatomic) NSMutableArray<FWBaseRequest *> *requestArray;
@property (strong, nonatomic) NSMutableArray<FWChainCallback> *requestCallbackArray;
@property (assign, nonatomic) NSUInteger nextRequestIndex;
@property (strong, nonatomic) FWChainCallback emptyCallback;

@end

@implementation FWChainRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _emptyCallback = ^(FWChainRequest *chainRequest, FWBaseRequest *baseRequest) {
            // do nothing
        };
    }
    return self;
}

- (void)start {
    if (_nextRequestIndex > 0) {
        FWRequestLog(@"Error! Chain request has already started.");
        return;
    }

    _failedRequest = nil;
    if ([_requestArray count] > 0) {
        [[FWRequestAgent sharedAgent] addChainRequest:self];
        [self toggleAccessoriesWillStartCallBack];
        [self startNextRequest];
    } else {
        FWRequestLog(@"Error! Chain request array is empty.");
    }
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    _delegate = nil;
    [self clearRequest];
    [self toggleAccessoriesDidStopCallBack];
    [[FWRequestAgent sharedAgent] removeChainRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(FWChainRequest *chainRequest))success
                                    failure:(void (^)(FWChainRequest *chainRequest))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(FWChainRequest *chainRequest))success
                              failure:(void (^)(FWChainRequest *chainRequest))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (void)dealloc {
    [self clearRequest];
}

- (void)addRequest:(FWBaseRequest *)request callback:(FWChainCallback)callback {
    [_requestArray addObject:request];
    if (callback != nil) {
        [_requestCallbackArray addObject:callback];
    } else {
        [_requestCallbackArray addObject:_emptyCallback];
    }
}

- (NSArray<FWBaseRequest *> *)requestArray {
    return _requestArray;
}

- (BOOL)startNextRequest {
    if (_nextRequestIndex < [_requestArray count]) {
        FWBaseRequest *request = _requestArray[_nextRequestIndex];
        _nextRequestIndex++;
        request.delegate = self;
        [request clearCompletionBlock];
        [request start];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(FWBaseRequest *)request {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    FWChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if (![self startNextRequest]) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(chainRequestFinished:)]) {
            [_delegate chainRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
        [self toggleAccessoriesDidStopCallBack];
        [[FWRequestAgent sharedAgent] removeChainRequest:self];
    }
}

- (void)requestFailed:(FWBaseRequest *)request {
    _failedRequest = request;
    [self toggleAccessoriesWillStopCallBack];
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:)]) {
        [_delegate chainRequestFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self);
    }
    [self clearCompletionBlock];
    [self toggleAccessoriesDidStopCallBack];
    [[FWRequestAgent sharedAgent] removeChainRequest:self];
}

- (void)clearRequest {
    if (_nextRequestIndex > 0) {
        NSUInteger currentRequestIndex = _nextRequestIndex - 1;
        if (currentRequestIndex < [_requestArray count]) {
            FWBaseRequest *request = _requestArray[currentRequestIndex];
            [request stop];
        }
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
    [self clearCompletionBlock];
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<FWRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
