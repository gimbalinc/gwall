//
//  FirstViewController.swift
//  GWall
//
//  Created by Gary Damm on 8/3/16.
//  Copyright © 2016 Gimbal. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    let youTubeVideoHTML = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%@', height:'%@', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>"
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.gwallManager.delegate = self
    }
    
    func playYoutubeWithID(_ videoID: String) {
        let html = String(format: youTubeVideoHTML, "1024", "768", videoID)
        self.webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }
    
}

extension FirstViewController : GWallManagerDelegate {
    
    func receivedURL(manager: GWallManager, urlString: String) {
        DispatchQueue.main.async(execute: {
            NSLog("receivedURL %@", urlString)
            
            if (urlString.contains("//")) {
                let url = URL(string: urlString)
                let request = URLRequest(url: url!)
                self.webView.loadRequest(request)
            }
            else {
                self.playYoutubeWithID(urlString)
            }
            
        })
    }
    
    func connectedToDisplay(displayName: String){}

}

