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

