//
//  ContentProvider.h
//  ChainIO
//
//  Created by Lihao Li on 2018/8/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CIContentProviderProtocol;

@protocol CIContentProviderListener <NSObject>

- (void)contentProviderDidChangeContent:(id<CIContentProviderProtocol>)contentProvider;
- (void)contentProviderDidError:(id<CIContentProviderProtocol>)contentProvider;

@optional
- (void)contentProviderWillChangeContent:(id<CIContentProviderProtocol>)contentProvider;
- (BOOL)contentProviderCanChangeContent:(id<CIContentProviderProtocol>)contentProvider;

@end

@protocol CIContentProviderProtocol <NSObject>

@property (nonatomic, readonly) id viewModel;

- (void)addContentProviderListener:(id<CIContentProviderListener>)contentProviderListener;
- (void)removeContentProviderListener:(id<CIContentProviderListener>)contentProviderListener;

- (void)updateCanChangeContent;

- (void)refresh;

@end
