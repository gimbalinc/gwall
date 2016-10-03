//
//  SecondViewController.swift
//  GWall
//
//  Created by Gary Damm on 8/3/16.
//  Copyright © 2016 Gimbal. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    let DEFAULT_URL = "https://www.gimbal.com"
    let DEFAULT_URL_KEY = "gwall.default"
    let ATTRIBUTE_KEY = "gwall.url"
    
    var placeManager: GMBLPlaceManager!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeManager = GMBLPlaceManager()
        self.placeManager.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.gwallManager.delegate = self
        self.displayLabel.text = appDelegate.gwallManager.connectedDisplay
    }
  
}

extension SecondViewController : GWallManagerDelegate {
    
    func receivedURL(manager: GWallManager, urlString: String){}
    
    func connectedToDisplay(displayName: String){
        DispatchQueue.main.async(execute: {
            self.displayLabel.text = displayName
        })
    }
    
}

extension SecondViewController : GMBLPlaceManagerDelegate {
    
    func placeManager(_ manager: GMBLPlaceManager!, didBegin visit: GMBLVisit!) -> Void {
        NSLog("didBegin %@", visit.description)
        NSLog("Looking for attribute: %@", ATTRIBUTE_KEY)
        
        for key in visit.place.attributes.allKeys() {
            if ((key as AnyObject).isEqual(ATTRIBUTE_KEY)) {
                let url = visit.place.attributes.string(forKey: key as! String)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                self.beaconLabel.text = String(format: "Beacon:%@ URL:%@", visit.place.name, url!)
                appDelegate.gwallManager.sendURL(url!)
            }
        }
        
    }
    
    func placeManager(_ manager: GMBLPlaceManager!, didEnd visit: GMBLVisit!) -> Void {
        NSLog("didEnd %@", visit.place.description)
        
        var url = DEFAULT_URL
        
        for key in visit.place.attributes.allKeys() {
            if ((key as AnyObject).isEqual(DEFAULT_URL_KEY)) {
                url = visit.place.attributes.string(forKey: key as! String)
                break
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.gwallManager.sendURL(url)
        self.beaconLabel.text = "None"
    }
    
}

