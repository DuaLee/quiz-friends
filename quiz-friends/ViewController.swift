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
    @IBOutlet weak var visibilityButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var gameMode: Int = 0
    var isHost: Bool = false
    
    var myPeerID: MCPeerID!
    var session: MCSession!
    var assistant: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        assistant = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "game")
        assistant.delegate = self
        
        session.delegate = self
        
        visibilityButton.setTitle(" Disable Device Visibility", for: .selected)
        visibilityButton.setTitle(" Enable Device Visibility", for: .normal)
        visibilityButton.titleLabel?.font = .systemFont(ofSize: 24)
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            singleButton.isSelected = true
            visibilityButton.isSelected = false
            playButton.isEnabled = true
            
            stopClient()
            session.disconnect()
            
            gameMode = 1
            
        case 2:
            singleButton.isSelected = false
            
            if visibilityButton.isSelected {
                visibilityButton.isSelected = false
                
                stopClient()
            } else {
                visibilityButton.isSelected = true
                
                startClient()
            }
            
            gameMode = 2
            
        default:
            gameMode = 0
        }
    }
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        singleButton.isSelected = false
        visibilityButton.isSelected = false
        
        stopClient()
        startServer()
    }
    
    func startClient() {
        assistant.startAdvertisingPeer()
    }
    
    func stopClient() {
        assistant.stopAdvertisingPeer()
    }
    
    func startServer() {
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
        isHost = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        isHost = false
        
        session.disconnect()
        
        dismiss(animated: true, completion: nil)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let acceptAction = UIAlertAction(title: "Accept",
                                         style: .default) { [self] action in
            invitationHandler(true, session)
            stopClient()
        }
        let declineAction = UIAlertAction(title: "Decline",
                                         style: .cancel) { action in
            invitationHandler(false, self.session)
        }
             
        let alertController = UIAlertController(title: "🎮 Game Invite", message: "\(peerID.displayName) wants to play!", preferredStyle: .alert)
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
             
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        singleButton.isSelected = false
        visibilityButton.isSelected = false
        
        if isHost {
            playButton.isEnabled = true
        } else {
            playButton.isEnabled = false
        }
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
