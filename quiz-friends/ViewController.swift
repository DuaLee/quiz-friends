//
//  ViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {

    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var gameMode: Int = 0
    
    var peerID: MCPeerID!
    var session: MCSession!
    var assistant: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        session.delegate = self
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            singleButton.isSelected = true
            multiButton.isSelected = false
            
            gameMode = 1
            
        case 2:
            singleButton.isSelected = false
            multiButton.isSelected = true
            
            gameMode = 2
            
        default:
            gameMode = 0
        }
        
        if gameMode > 0 {
            playButton.isEnabled = true
        }
    }
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        startHosting()
        joinSession()
    }
    
    func startHosting() {
        assistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "game")
        assistant.delegate = self
        assistant.startAdvertisingPeer()
    }
    
    func joinSession() {
        let browser = MCBrowserViewController(serviceType: "game", session: session)
        browser.delegate = self
        present(browser, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async(execute: {
            switch state {
            case MCSessionState.connected:
                print("Connected: \(peerID.displayName)")
                
            case MCSessionState.connecting:
                print("Connecting: \(peerID.displayName)")
                
            case MCSessionState.notConnected:
                print("Not Connected: \(peerID.displayName)")
                
            default:
                print("Error")
            }
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is dismissed
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        dismiss(animated: true, completion: nil)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        singleButton.isSelected = false
        multiButton.isSelected = false
        playButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "quizSegue":
                let controller = segue.destination as! QuizViewController
                
                controller.gameMode = self.gameMode
            default:
                break
            }
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        print("unwind")
    }
}
