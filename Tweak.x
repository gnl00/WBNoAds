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

// 博文下方推荐 WBTimelineTrendContainerView > WBContentHeaderTrendCell
@interface WBContentHeaderTrendCell: UIView
@end
%hook WBContentHeaderTrendCell
- (void)setFrame:(CGRect)frame {
    %orig;
    UIView *superview = self;
    [self removeFromSuperview];
    // 父视图重新布局（可选）
    [superview setNeedsLayout];
    [superview layoutIfNeeded];
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

// 拦截网络请求
%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSString *urlString = request.URL.absoluteString;
    NSLog(@"WeiboNoAds_HOOK_NSURLSession%@", urlString);
    if ([urlString containsString:@"https://bootpreload.uve.weibo.com/v2/ad/preload"]) {
        // 构造一个空的 JSON 响应数据
        NSData *emptyJsonData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"application/json" expectedContentLength:emptyJsonData.length textEncodingName:nil];
        completionHandler(emptyJsonData, response, nil);
        return nil;
    }

    // 调用原始方法
    return %orig(request, completionHandler);
}

%end

@interface WBInternalAFURLSessionManager: NSObject
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError *error))completionHandler;
@end

%hook WBInternalAFURLSessionManager

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSString *urlString = request.URL.absoluteString;
    NSLog(@"WeiboNoAds_HOOK_WBInternalAFURLSessionManager%@", urlString);
    if ([urlString containsString:@"https://api.weibo.cn/2/remind/unread_count"]) {
        // 构造一个空的 JSON 响应数据
        NSData *emptyJsonData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"application/json" expectedContentLength:emptyJsonData.length textEncodingName:nil];
        completionHandler(emptyJsonData, response, nil);
        return nil;
    }

    // 调用原始方法
    return %orig(request, completionHandler);
}

%end