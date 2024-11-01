#import <UIKit/UIKit.h>

%hook WBAdSdkFlashAdView
- (id)initWithWindow:(id)arg1 {
    return 0;
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

