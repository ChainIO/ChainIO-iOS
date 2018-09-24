//
//  ContentProvider.m
//  ChainIO
//
//  Created by Lihao Li on 2018/8/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

#import "CIContentProvider.h"
#import "CIContentProvider+Protected.h"


@interface CIContentProvider()

@property (nonatomic) NSHashTable<id<CIContentProviderListener>> *contentProviderListeners;

@property (nonatomic) id content;
@property (nonatomic) id contentToChangeTo;
@property (nonatomic) BOOL canChangeContent;

@end

@implementation CIContentProvider

- (instancetype)init {
    if (self = [super init]) {
        _contentProviderListeners = [NSHashTable weakObjectsHashTable];
        _canChangeContent = YES;
    }
    return self;
}


- (void)addContentProviderListener:(id<CIContentProviderListener>)contentProviderListener {
    [self.contentProviderListeners addObject:contentProviderListener];
    [self updateCanChangeContent];
}


- (void)removeContentProviderListener:(id<CIContentProviderListener>)contentProviderListener {
    [self.contentProviderListeners removeObject:contentProviderListener];
    [self updateCanChangeContent];
}


- (void)updateCanChangeContent {
    BOOL previousCanChangeContent = self.canChangeContent;
    
    BOOL canChangeContent = YES;
    
    for (id<CIContentProviderListener> listener in self.contentProviderListeners) {
        if ([listener respondsToSelector:@selector(contentProviderCanChangeContent:)]) {
            if (![listener contentProviderCanChangeContent:self]) {
                canChangeContent = NO;
                break;
            }
        }
    }
    self.canChangeContent = canChangeContent;
    if(previousCanChangeContent == NO && canChangeContent == YES) {
        [self changeContentIfNeeded];
    }
}


- (void)changeContentIfNeeded {
    if (self.content != self.contentToChangeTo) {
        for (id<CIContentProviderListener> listener in self.contentProviderListeners) {
            if ([listener respondsToSelector:@selector(contentProviderWillChangeContent:)]) {
                [listener contentProviderWillChangeContent:self];
            }
        }
        
        self.content = self.contentToChangeTo;
        self.contentToChangeTo = nil;
        
        for (id<CIContentProviderListener> listener in self.contentProviderListeners) {
            [listener contentProviderDidChangeContent:self];
        }
    }
}


- (void)addContentIfNeeded {
    if (self.content != self.contentToChangeTo) {
        for (id<CIContentProviderListener> listener in self.contentProviderListeners) {
            if ([listener respondsToSelector:@selector(contentProviderWillChangeContent:)]) {
                [listener contentProviderWillChangeContent:self];
            }
        }
        
        self.content = self.contentToChangeTo;
        self.contentToChangeTo = nil;
        
        for (id<CIContentProviderListener> listener in self.contentProviderListeners) {
            [listener contentProviderDidAddContent:self];
        }
    }
}


- (void(^)(void))defaultErrorBlock:(id)content {
    __typeof(self) __weak weakSelf = self;
    void(^errorOnMainThread)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^(void){
            for (id<CIContentProviderListener> listener in weakSelf.contentProviderListeners) {
                [listener contentProviderDidError:weakSelf];
            }
        });
    };
    return errorOnMainThread;
}


- (void)setContentOnMainThread:(id)content {
    __typeof(self) __weak weakSelf = self;
    void(^setContentBlock)(void) = ^(void){
        weakSelf.contentToChangeTo = content;
        if (weakSelf.canChangeContent) {
            [weakSelf changeContentIfNeeded];
        }
    };
    
    if ([NSThread isMainThread]) {
        setContentBlock();
    }else {
        dispatch_async(dispatch_get_main_queue(), setContentBlock);
    }
}


- (void)addNewContentOnMainThread:(id)content {
    __typeof(self) __weak weakSelf = self;
    void(^setContentBlock)(void) = ^(void){
        weakSelf.contentToChangeTo = content;
        if (weakSelf.canChangeContent) {
            [weakSelf addContentIfNeeded];
        }
    };
    if ([NSThread isMainThread]) {
        setContentBlock();
    }else {
        dispatch_async(dispatch_get_main_queue(), setContentBlock);
    }
}


- (_Nonnull dispatch_queue_t)processingQueue {
    if (!_processingQueue) {
        _processingQueue = dispatch_queue_create("com.blocain.processingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _processingQueue;
}

- (void)refresh {
    //subclasses should override
    [self doesNotRecognizeSelector:_cmd];
}

@synthesize Container;

@end
