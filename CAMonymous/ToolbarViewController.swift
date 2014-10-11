//
//  ToolbarViewController.swift
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

import UIKit

class ToolbarViewController: UIViewController {
  
  let colorUsual = UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0.12)
  let colorHighlighted = UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0.5)

  @IBOutlet weak var toolbar: UIView!
  @IBAction func cameraButtonPressed(sender: AnyObject) {
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.toolbar.backgroundColor = self.colorHighlighted
    }) { (success) -> Void in
      CaptureManager.sharedManager().savePicture()
      UIView.animateWithDuration(0.1, animations: { () -> Void in
        self.toolbar.backgroundColor = self.colorUsual
        }) { (success) -> Void in
          //
      }
    }
  }
  
}
