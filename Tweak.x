#import <UIKit/UIKit.h>

@interface WBAdSdkFlashAdView : UIView
- (void)closeAd:(unsigned long long)arg1;
@end

%hook WBAdSdkFlashAdView
- (void)didMoveToSuperview {
    %log;
    %orig;
    if (self.superview) {
        [self setHidden:YES];
        [self closeAd:2];
    }
}
%end

%hook WBReadRedPacketView
- (id)initWithFrame:(struct CGRect)arg1 completeCount:(long long)arg2 {
    return 0;
}
%end

%hook WBNavLotteryButton
- (id)initWithFrame:(struct CGRect)arg1 {
    return 0;
}
%end

// 移除左上角签到？WBNavigationBarButton

// 移除悬浮 Banner 广告
@interface WBAdFloatingBannerContainerView : UIView
@end
%hook WBAdFloatingBannerContainerView
- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}
%end

// 搜索页面 滑动卡片 WBS3CardCardView > WBPageCardBubbleView > WBPageCardGradientAnimateView
@interface WBPageCardGradientAnimateView : UIView
@end
%hook WBPageCardGradientAnimateView
- (id)initWithFrame:(struct CGRect)arg1 {
    return 0;
}
%end


// 搜索页面 WBPageCardBubbleView > WBPageDiscoverGridView
@interface WBPageDiscoverGridView : UIView
@end
%hook WBPageDiscoverGridView
- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}
%end

// 移除tab
@interface WBTabBarButton : UIView
@end

%hook WBTabBarButton
- (void)layoutSubviews {
    %orig;
    // 通过遍历子视图找到标题label
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text isEqualToString:@"视频"] 
                || [label.text isEqualToString:@"超话"]) {
                [self removeFromSuperview];
                break;
            }
        }
    }
}
%end

// 移除【视频tab】后，其他 tab 重排序
@interface WBTabBarOverlay : UIView
@property(nonatomic, readonly) NSArray *subviews;
- (void)layoutSubviews;
@end

%hook WBTabBarOverlay
- (void)layoutSubviews {
    %orig;
    NSMutableArray *tabButtons = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:%c(WBTabBarButton)]) {
            if (!CGRectEqualToRect(subview.frame, CGRectMake(85, 3, 64, 45))) {
                [tabButtons addObject:subview];
            }
        }
    }
    // 设置新布局
    CGFloat containerWidth = self.frame.size.width;
    NSInteger buttonCount = tabButtons.count;
    CGFloat buttonWidth = 64;
    CGFloat totalButtonsWidth = buttonWidth * buttonCount;
    CGFloat remainingSpace = containerWidth - totalButtonsWidth;
    CGFloat spacing = remainingSpace / (buttonCount + 1);
    // 应用新布局
    [tabButtons enumerateObjectsUsingBlock:^(UIView *button, NSUInteger idx, BOOL *stop) {
        CGRect frame = button.frame;
        frame.origin.x = spacing + (buttonWidth + spacing) * idx;
        button.frame = frame;
    }];
}
%end

// 移除信息流博文
@interface WBContentAuthView : UIView
@end
@interface WBStatusContentView : UIView
@end
@interface WBS3CellCollectionViewCell : UIView
@end
@interface WBS3RLCollectionView : UIView
@end

// 广告、推荐 WBContentAuthView
%hook WBContentAuthView
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // 检查 frame 是否不为 CGRectZero
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            // 从当前视图向上查找父视图
            UIView *superview = self;
            while (superview != nil) {
                if ([superview isKindOfClass:NSClassFromString(@"WBS3CellCollectionViewCell")]) {
                    // 找到 WBS3CellCollectionViewCell 移除
                    [superview removeFromSuperview];
                    break;
                } else if ([superview isKindOfClass:NSClassFromString(@"WBS3RLCollectionView")]) {
                    // 如果找到 WBS3RLCollectionView 还未找到 WBS3CellCollectionViewCell，则停止查找
                    break;
                }
                superview = superview.superview;
            }
        }
    }
    return self;
}
%end
// 广告、推荐 WBStatusContentView
%hook WBStatusContentView
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            UIView *superview = self;
            while (superview != nil) {
                if ([superview isKindOfClass:NSClassFromString(@"WBS3CellCollectionViewCell")]) {
                    [superview removeFromSuperview];
                    break;
                } else if ([superview isKindOfClass:NSClassFromString(@"WBS3RLCollectionView")]) {
                    break;
                }
                superview = superview.superview;
            }
        }
    }
    return self;
}
%end

// 博文下方推荐 WBContentHeaderTrendCell
@interface WBContentHeaderTrendCell: UIView
@end
%hook WBContentHeaderTrendCell
- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}
%end

// 博文评论推荐 WBTrendCommentCell
@interface WBTrendCommentCell: UIView
@end
%hook WBTrendCommentCell
- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}
%end

// 热搜 tab
@interface WBS3PageChannelBarButton: UIView
@end

// 热搜过滤 WBPageCardSingleTextView > WBTimelineLargeCardTextView
@interface WBPageCardSingleTextView: UIView
@property (nonatomic, copy, readwrite) NSString *accessibilityIdentifier;
@end

@interface WBTimelineLargeCardTextView: UIView
@property (nonatomic, strong) NSString *accessibilityLabel;
@end

%hook WBTimelineLargeCardTextView
- (void)layoutSubviews {
    %orig;
    // 检查 accessibilityLabel 是否包含
    if ([self.accessibilityLabel containsString:@"慕"]) {
        self.accessibilityLabel = [NSString stringWithFormat:@"找到啦%@", self.accessibilityLabel];
    }
}
%end

// 禁止网络请求
@interface CustomURLProtocol: NSURLProtocol
@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 定义需要拦截的 URL 前缀数组
    static NSArray *blockedPrefixes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockedPrefixes = @[
            @"https://wbapp.uve.weibo.com/wbapplua/wbpullad.lua",
            @"https://bootpreload.uve.weibo.com/v2/ad/preload",
            @"https://adstrategy.biz.weibo.com/v3/strategy/ad",
            @"https://api.weibo.cn/2/video/tiny_stream",
            @"https://api.weibo.cn/2/video/tiny_stream_video_list",
            @"https://api.weibo.cn/2/video/!/multimedia/playback/batch_get"
        ];
    });
    
    // 检查 URL 是否匹配任何前缀
    NSString *urlString = request.URL.absoluteString;
    for (NSString *prefix in blockedPrefixes) {
        if ([urlString hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    // 创建一个空的 JSON 响应
    NSData *responseData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    
    // 创建一个 HTTP 响应
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type": @"application/json"}];
    
    // 通知客户端请求成功
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:responseData];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
    // 不需要实现，除非你需要在请求停止时执行某些操作
}

@end

// 拦截热搜
%hook NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([request.URL.absoluteString hasPrefix:@"https://api.weibo.cn/2/flowpage"]) {
        return YES;
    }
    return %orig;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    if ([self.request.URL.absoluteString hasPrefix:@"https://api.weibo.cn/2/flowpage"]) {
        // 创建会话配置
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        // 创建数据任务
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:self.request 
                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || !data) {
                [self.client URLProtocol:self didFailWithError:error];
                return;
            }
            
            // 解析 JSON
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError || !json) {
                [self.client URLProtocol:self didFailWithError:jsonError];
                return;
            }
            
            // 过滤数据
            NSMutableDictionary *filteredJson = [json mutableCopy];
            NSArray *items = json[@"items"];
            if ([items isKindOfClass:[NSArray class]]) {
                NSMutableArray *filteredItems = [NSMutableArray array];
                
                for (NSDictionary *item in items) {
                    // 检查是否需要过滤
                    BOOL shouldFilter = NO;
                    
                    // 检查 desc 字段
                    NSString *desc = item[@"data"][@"desc"];
                    if ([desc isKindOfClass:[NSString class]] && [desc containsString:@"慕"]) {
                        shouldFilter = YES;
                    }
                    
                    // 检查 desc_extr 字段
                    NSString *descExtr = item[@"data"][@"desc_extr"];
                    if ([descExtr isKindOfClass:[NSString class]] && [descExtr containsString:@"剧集"]) {
                        shouldFilter = YES;
                    }
                    
                    // 如果不需要过滤，添加到新数组
                    if (!shouldFilter) {
                        [filteredItems addObject:item];
                    }
                }
                
                // 更新过滤后的数据
                filteredJson[@"items"] = filteredItems;
            }
            
            // 创建新的响应数据
            NSData *filteredData = [NSJSONSerialization dataWithJSONObject:filteredJson options:0 error:nil];
            if (!filteredData) {
                [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"JSONSerializationError" code:-1 userInfo:nil]];
                return;
            }
            
            // 返回过滤后的数据
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:filteredData];
            [self.client URLProtocolDidFinishLoading:self];
        }];
        
        // 开始任务
        [dataTask resume];
    } else {
        // 处理其他请求
        %orig;
    }
}

- (void)stopLoading {
    %orig;
}

%end