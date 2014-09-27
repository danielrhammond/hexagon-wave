//
//  ViewController.swift
//  HexagonWave
//
//  Created by Daniel Hammond on 9/26/14.
//

import UIKit

class ViewController: UIViewController {
    // setup
    var displayLink:CADisplayLink?;
    var initialT:CFTimeInterval = 0
    var xRotation:CGFloat = 0.676;
    var nodes: [[[CALayer]]] = []
    // colors
    let c1 = UIColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0)
    let c2 = UIColor(red: 40/255.0, green: 120/255.0, blue: 180/255.0, alpha: 1.0)
    let c3 = UIColor(red: 150/255.0, green: 50/255.0, blue: 60/255.0, alpha: 1.0)
    // constants
    let sp:Float = 24
    let d:Float = 4
    let N = 12
    let df:Float = 0.045
    let ll:Float = 0.2
    let mh:Float = 100
    let mdi:Float = 121
    let mn:Float = 0.5 * sqrt(3.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        for var i = -N; i <= N; ++i {
            var layers:[[CALayer]] = []
            for var j = -N; j <= N; ++j {
                let layerOne = createLayer(c1)
                let layerTwo = createLayer(c2)
                let layerThree = createLayer(c3)
                layers.append([ layerOne, layerTwo, layerThree ])
            }
            nodes.append(layers)
        }
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureAction:"))
    }
    
    func createLayer(color:UIColor) -> CALayer {
        let layer = CALayer()
        layer.bounds = CGRect(x: 0.0,y: 0.0,width: 8.0,height: 8.0)
        layer.cornerRadius = 4.0
        layer.backgroundColor = color.CGColor
        layer.actions = ["position": NSNull(), "transform": NSNull(), "bounds": NSNull()]
        view.layer.addSublayer(layer)
        layer.position = view.layer.position
        return layer
    }
    
    override func viewDidAppear(animated: Bool) {
        displayLink = CADisplayLink(target: self, selector: "displayLinkAction:")
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func displayLinkAction(displayLink:CADisplayLink) {
        if (initialT == 0) {
            initialT = displayLink.timestamp
        }
        let t = fmod(displayLink.timestamp - initialT, 3.0) / 3.0;
        var sublayerTransform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        sublayerTransform.m34 = -1.0/500.0;
        sublayerTransform = CATransform3DRotate(sublayerTransform, CGFloat(xRotation), 1.0, 0.0, 0.0)
        let rotation = (2.0 * Float(M_PI) * Float(t)) / 3.0
        sublayerTransform = CATransform3DRotate(sublayerTransform, CGFloat(rotation), 0.0, 0.0, 1.0)
        view.layer.sublayerTransform = sublayerTransform
        
        for var i = -N; i <= N; ++i {
            for var j = -N; j <= N; ++j {
                let layerSet = nodes[i+N][j+N]
                for (index, layer) in enumerate(layerSet) {
                    var x:Float = 0, y:Float = 0, z:Float = 0, tt:Float = 0, di:Float = 0
                    y = Float(i) * sp
                    switch index {
                    case 0:
                        x = Float(j) * Float(mn) * sp
                    case 1:
                        x = (Float(j) - 2/3.0) * Float(mn) * sp
                    case 2:
                        x = (Float(j) + 2/3.0) * Float(mn) * sp
                    default:
                        break
                    }
                    if j % 2 != 0 {
                        y += 0.5 * sp
                    }
                    di = fmaxf(fabsf(y), fmaxf(fabsf(0.5 * y + mn * x), fabsf(0.5 * y - mn * x)))
                    z = map(sinf(2.0 * Float(M_PI) * Float(t) - Float(df) * di), low: -1, high: 1, newLow: -mh/2.0, newHigh: mh/2.0)
                    layer.transform = CATransform3DMakeTranslation(CGFloat(x), CGFloat(y), CGFloat(z))
                    layer.hidden = di >= mdi
                }
            }
        }
    }
    
    func map(value:Float, low:Float, high:Float, newLow:Float, newHigh:Float) -> Float {
        let x = (value - low) / (high - low)
        return newLow + x * (newHigh - newLow)
    }

    func panGestureAction(pan:UIPanGestureRecognizer) {
        let translationY = Float(pan.locationInView(view).y) / Float(CGRectGetHeight(view.bounds))
        xRotation = CGFloat(map(translationY, low: 0, high: 1, newLow: 0, newHigh: Float(M_PI_2)))
    }
}

