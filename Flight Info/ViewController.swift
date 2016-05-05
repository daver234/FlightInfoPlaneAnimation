/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
 *
 * Modified by Dave Rothschild May 4, 2016
*/

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!
  
  //MARK: view controller methods
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    //set the initial flight data
    self.changeFlightDataTo(londonToParis)
  }
  
  func changeFlightDataTo(data: FlightData) {
    
    //populate the UI with the next flight's data
    // summary.text = data.summary
    flightNr.text = data.flightNr
    gateNr.text = data.gateNr
    departingFrom.text = data.departingFrom
    arrivingTo.text = data.arrivingTo
    flightStatus.text = data.flightStatus

    UIView.transitionWithView(snowView, duration: 1.5, options: [.TransitionCrossDissolve], animations: {
      self.snowView.hidden = !data.showWeatherEffects
      }, completion: nil)

    //duplicate background image
    let overlay = duplicateImageViewFrom(bgImageView, newImageName: data.weatherImageName)
    
    overlay.alpha = 0.0
    overlay.transform = CGAffineTransformMakeScale(1.33, 1.0)
    
    bgImageView.superview!.insertSubview(overlay, aboveSubview: bgImageView)
    
    //duplicate departing airpot
    let helperLabel = duplicateLabelFrom(departingFrom)
    departingFrom.superview!.addSubview(helperLabel)
    
    let departingOffset = CGFloat(-80)
    
    departingFrom.center.x += departingOffset
    departingFrom.alpha = 0
    departingFrom.text = data.departingFrom
    
    //duplicate arriving airport
    let helperLabelArriving = duplicateLabelFrom(arrivingTo)
    arrivingTo.superview!.addSubview(helperLabelArriving)
    
    let arrivingOffset = CGFloat(-50)
    arrivingTo.center.y += arrivingOffset
    arrivingTo.alpha = 0
    arrivingTo.text = data.arrivingTo
    
    //kick off animations
    UIView.animateWithDuration(0.5, animations: {
      overlay.alpha = 1.0
      overlay.transform = CGAffineTransformIdentity
      
      self.departingFrom.center.x -= departingOffset
      self.departingFrom.alpha = 1.0
      
      helperLabel.alpha = 0.0
      helperLabel.center.x += departingOffset
      
      self.arrivingTo.center.y -= arrivingOffset
      self.arrivingTo.alpha = 1

      helperLabelArriving.alpha = 0.0
      helperLabelArriving.center.y += arrivingOffset
      
    }, completion: {_ in
      self.bgImageView.image = overlay.image
      overlay.removeFromSuperview()
      
      helperLabel.removeFromSuperview()
      helperLabelArriving.removeFromSuperview()
    })
    
    planeDepart()
    
    UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: [], animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
            self.summary.center.y -= 50 })
        
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
            self.summary.center.y += 50
        })
        
        }, completion: nil)
    
    delay(seconds: 0.25, completion: {
        self.summary.text = data.summary
    })
    // schedule next flight
    delay(seconds: 3.0) {
      self.changeFlightDataTo(data.isTakingOff ? parisToRome : londonToParis)
    }
    
  }
  
  func planeDepart() {
    
    let originalCenter = planeImage.center
    
    UIView.animateKeyframesWithDuration(1.5, delay: 0.0,
      options: [], animations: {
      
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.25, animations: {
          self.planeImage.center.x += 80.0
          self.planeImage.center.y -= 10.0
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.4, animations: {
          self.planeImage.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4/2))
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.25, animations: {
          self.planeImage.center.x += 100.0
          self.planeImage.center.y -= 50.0
          self.planeImage.alpha = 0
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.51, relativeDuration: 0.01, animations: {
          self.planeImage.transform = CGAffineTransformIdentity
          self.planeImage.center = CGPoint(x: 0, y: originalCenter.y)
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.55, relativeDuration: 0.45, animations: {
          self.planeImage.alpha = 1.0
          self.planeImage.center = originalCenter
        })
        
      }, completion: nil)
  }
}

////////////////////////////////////////
//
//    Starter project code
//
////////////////////////////////////////
extension ViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: CGRectOffset(view.frame, 0, 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
  }
  
  func duplicateImageViewFrom(originalView: UIImageView, newImageName: String) -> UIImageView {
    let duplicate = UIImageView(image: UIImage(named: newImageName)!)
    duplicate.frame = bgImageView.frame
    duplicate.contentMode = bgImageView.contentMode
    duplicate.center = bgImageView.center
    return duplicate
  }
  
  func duplicateLabelFrom(originalLabel: UILabel, newText: String? = nil) -> UILabel {
    let duplicate = UILabel(frame: originalLabel.frame)
    duplicate.text = newText ?? originalLabel.text
    duplicate.font = originalLabel.font
    duplicate.textAlignment = originalLabel.textAlignment
    duplicate.textColor = originalLabel.textColor
    duplicate.backgroundColor = UIColor.clearColor()
    return duplicate
  }
  
}