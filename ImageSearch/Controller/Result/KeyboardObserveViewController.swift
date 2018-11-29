//
//  KeyboardObserveViewController.swift
//  ImageSearch
//
//  Created by ChAe on 13/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

// 키보드 Show/Hide 감지 ViewController
class KeyboardObserveViewController: UIViewController {
    struct KeyboardAttributes {
        let duration: TimeInterval
        let curve: UIView.AnimationOptions
        let begin: CGRect
        let end: CGRect
        
        init?(withRawValue rawValue: [AnyHashable: Any]?) {
            guard let rawValue = rawValue else {
                return nil
            }
            
            duration = rawValue[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            curve = .init(rawValue: rawValue[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            begin = (rawValue[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            end = (rawValue[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        }
        
        var height: CGFloat {
            return end.maxY - end.minY
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForKeyboardNotifications()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Kyeboard hide/show methods
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardAtts = KeyboardAttributes(withRawValue: notification.userInfo) else {
            return
        }
        
        keyboardWillShow(keyboardAtts: keyboardAtts)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardAtts = KeyboardAttributes(withRawValue: notification.userInfo) else {
            return
        }
        
        keyboardWillHide(keyboardAtts: keyboardAtts)
    }
    
    func keyboardWillShow(keyboardAtts: KeyboardAttributes) {
        // 상속 구조시 해당 function override해서 처리
    }
    
    func keyboardWillHide(keyboardAtts: KeyboardAttributes) {
        // 상속 구조시 해당 function override해서 처리
    }
    
    private func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
