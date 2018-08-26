//
//  CIContentProvider+Protected.h
//  ChainIO
//
//  Created by Lihao Li on 2018/8/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

#import "CIContentProvider.h"

@interface CIContentProvider ()

@property (nonatomic, readonly) dispatch_queue_t processingQueue;
@property (nonatomic, readonly) void(^defaultErrorBlock)(void);

- (void)setContentOnMainThread:(id)content;
- (void)addNewContentOnMainThread:(id)content;

@end
