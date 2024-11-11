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
@interface WBS3CellCollectionViewCell : UIView
@end
@interface WBContentAuthView : UIView
@end
@interface WBS3RLCollectionView : UIView
@end

// 广告、推荐
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
                    // 找到 WBS3CellCollectionViewCell，移除它
                    [superview removeFromSuperview];
                    break; // 找到后停止查找
                } else if ([superview isKindOfClass:NSClassFromString(@"WBS3RLCollectionView")]) {
                    // 如果找到 WBS3RLCollectionView 还未找到 WBS3CellCollectionViewCell，则停止查找
                    break;
                }
                superview = superview.superview; // 向上查找
            }
        }
    }
    return self;
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
@interface CustomURLProtocol : NSURLProtocol
@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 检查是否是要拦截的 URL
    if ([request.URL.absoluteString hasPrefix:@"https://wbapp.uve.weibo.com/wbapplua/wbpullad.lua"]
        || [request.URL.absoluteString hasPrefix:@"https://bootpreload.uve.weibo.com/v2/ad/preload"]
        || [request.URL.absoluteString hasPrefix:@"https://api.weibo.cn/2/video/tiny_stream"]
        || [request.URL.absoluteString hasPrefix:@"https://api.weibo.cn/2/video/tiny_stream_video_list"]
        || [request.URL.absoluteString hasPrefix:@"https://api.weibo.cn/2/video/!/multimedia/playback/batch_get"]
        ) {
        return YES;
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