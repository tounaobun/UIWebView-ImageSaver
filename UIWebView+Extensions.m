//
//  UIWebView+Extensions.m
//  WeiXinMovie
//
//  Created by Benson on 2/24/16.
//  Copyright © 2016 Benson. All rights reserved.
//

#import "UIWebView+Extensions.h"

@interface UIWebView ()<UIActionSheetDelegate>
@end

@implementation UIWebView (Extensions)

- (void)enableLongPressingToSaveImage {
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:gesture];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchPoint = [sender locationInView:self];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y - 64];   // 要考虑导航栏高度对touchPoint的影响
        NSString *urlToSave = [self stringByEvaluatingJavaScriptFromString:imgURL];
        if (urlToSave.length) {
            // 识别到图片
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
            sheet.accessibilityValue = urlToSave;   // 传值
            [sheet showInView:self];
        }
    }
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {

        NSString *urlToSave = actionSheet.accessibilityValue;
        NSURL * imageURL = [NSURL URLWithString:urlToSave];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        // 保存到系统相册
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (!error) {
        [WPAppManager showGlobalCompleteHUDWithTitle:@"已保存到系统相册"];
    } else {
        [WPAppManager showTextHudWithTitle:@"保存失败"];
    }
}

@end
