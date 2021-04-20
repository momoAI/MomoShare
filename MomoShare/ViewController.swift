//
//  ViewController.swift
//  MomoShare
//
//  Created by momo on 2021/4/17.
//

import UIKit

class ViewController: UIViewController {
    var shareImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        shareImageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        shareImageView.backgroundColor = .blue
        view.addSubview(shareImageView)
        
        let ud = UserDefaults.init(suiteName: SUITNAME)
        if let imageData = ud?.object(forKey: SHARE_IMAGE_KEY) as? Data {
            let image = UIImage(data: imageData)
            shareImageView.image = image
        }
    }


}

