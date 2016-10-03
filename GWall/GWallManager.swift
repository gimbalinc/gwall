//
//  GWallManager.swift
//  GWall
//
//  Created by Gary Damm on 8/3/16.
//  Copyright © 2016 Gimbal. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol GWallManagerDelegate {
    func receivedURL(manager: GWallManager, urlString: String)
    func connectedToDisplay(displayName: String)
}

class GWallManager : NSObject {
    
    static let GIMBAL_API_KEY = "YOUR_GIMBAL_API_KEY_HERE"
    
    static let NO_DISPLAY = "None"
    static let SERVICE_TYPE = "gwall-service"
    
    fileprivate let peerID = MCPeerID(displayName:UIDevice.current.name)
    fileprivate let serviceAdvertiser : MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : GWallManagerDelegate?
    var connectedDisplay = NO_DISPLAY
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: GWallManager.SERVICE_TYPE)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: GWallManager.SERVICE_TYPE)
        super.init();
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        Gimbal.setAPIKey(GWallManager.GIMBAL_API_KEY, options: nil)
        GMBLPlaceManager.startMonitoring()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func sendURL(_ url : String) {
        NSLog("%@", "sendURL: \(url)")
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.send(url.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
        
    }
    
}

extension GWallManager : MCNearbyServiceAdvertiserDelegate {
    
    @available(iOS 7.0, *)
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }

    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
}

extension GWallManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
    
}

extension GWallManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        switch(state) {
        case .connected:
            self.delegate?.connectedToDisplay(displayName: peerID.displayName)
            self.connectedDisplay = peerID.displayName
        case .notConnected:
            self.delegate?.connectedToDisplay(displayName: GWallManager.NO_DISPLAY)
            self.connectedDisplay = GWallManager.NO_DISPLAY
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.count) bytes")
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.receivedURL(manager: self, urlString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
}
