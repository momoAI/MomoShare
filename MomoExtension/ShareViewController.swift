//
//  ShareViewController.swift
//  MomoExtension
//
//  Created by momo on 2021/4/17.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        // 验证分享的内容 返回值true则发布按钮会禁用
        return true
    }

    override func didSelectPost() {
        guard let inputItems = self.extensionContext?.inputItems.map({ $0 as? NSExtensionItem }) else {
            self.extensionContext?.cancelRequest(withError: ShareError(message: "extensionItem error"))
            return
        }
        for inputItem in inputItems {
            guard let providers = inputItem?.attachments else { return }
            for itemProvider in providers {
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (data, error) in
                        if error != nil {
                            self.extensionContext?.cancelRequest(withError: error!)
                            return
                        }
                            
                        guard let url = data as? URL else {
                            self.extensionContext?.cancelRequest(withError: ShareError(message: "data error"))
                            return
                        }
                            
                        // 分享的url
                        let ud = UserDefaults.init(suiteName: SUITNAME)
                        ud?.setValue(url, forKey: SHARE_URL_KEY)
                    }
                    return
                } else if (itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String)) {
                    itemProvider.loadDataRepresentation(forTypeIdentifier: kUTTypeImage as String) { (data, error) in
                        if error != nil {
                            self.extensionContext?.cancelRequest(withError: error!)
                            return
                        }
                        
                        guard let imgData = data else {
                            self.extensionContext?.cancelRequest(withError: ShareError(message: "data error"))
                            return
                        }
                        
                        // 分享的图片
                        let ud = UserDefaults.init(suiteName: SUITNAME)
                        ud?.setValue(imgData, forKey: SHARE_IMAGE_KEY)
                        self.openContainerApp()
                    }
                }
            }
        }
        
        
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        // 通知host app任务完成，并且extension界面自动dismiss
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        let s1 = SLComposeSheetConfigurationItem()
        s1?.title = "发送给朋友"  // 左侧标题
        s1?.value = "请选择"         // 右侧文字
        s1?.valuePending = true // 是否显示菊花
        s1?.tapHandler = {      // 点击事件
            self.showAlert(message: "跳转到好友列表")
        }
        
        let s2 = SLComposeSheetConfigurationItem()
        s2?.title = "分享到朋友圈"
        s2?.tapHandler = {
            self.showAlert(message: "跳转到朋友圈")
        }
        return [s1!, s2!]
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 打开ContainerAPP
    private func openContainerApp() {
        let scheme = "momoshare://"
        let url: URL = URL(string: scheme)!
        let context = NSExtensionContext()
        context.open(url, completionHandler: nil)
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        while (responder != nil) {
            if responder!.responds(to: selectorOpenURL) {
                responder!.perform(selectorOpenURL, with: url)
                break
            }
            responder = responder?.next
        }
    }
}
