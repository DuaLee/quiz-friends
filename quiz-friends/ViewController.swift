//
//  ViewController.swift
//  quiz-friends
//
//  Created by Cony Lee on 4/24/22.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {

    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var clientList: UILabel!
    
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
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        if hapticSetting {
            AudioServicesPlaySystemSound(1519)
        }
        
        switch sender.tag {
        case 1:
            visibilityButton.isEnabled = true
            
            statusLabel.text = "Single player selected."
            
            singleButton.isSelected = true
            visibilityButton.isSelected = false
            playButton.isEnabled = true
            
            session.disconnect()
            stopClient()
            
            gameMode = 1
            
        case 2:
            singleButton.isSelected = false
            playButton.isEnabled = false
            
            if visibilityButton.isSelected {
                statusLabel.text = "Device invisible to nearby."
                visibilityButton.isSelected = false
                
                stopClient()
            } else {
                statusLabel.text = "Device visible to nearby."
                visibilityButton.isSelected = true
                
                startClient()
            }
            
            gameMode = 2
            
        default:
            gameMode = 0
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        if hapticSetting {
            AudioServicesPlaySystemSound(1519)
        }
        
        singleButton.isSelected = false
        visibilityButton.isSelected = false
        
        session.disconnect()
        stopClient()
        startServer()
        
        gameMode = 2
    }
    
    func startClient() {
        assistant.startAdvertisingPeer()
    }
    
    func stopClient() {
        assistant.stopAdvertisingPeer()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if hapticSetting {
            AudioServicesPlaySystemSound(1520)
        }
    }
    
    func startServer() {
        let browser = MCBrowserViewController(serviceType: "game", session: session)
        browser.maximumNumberOfPeers = 4
        browser.delegate = self
        present(browser, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async(execute: { [self] in
            switch state {
            case MCSessionState.connected:
                //print("Connected: \(peerID.displayName)")
                
                if !isHost {
                    statusLabel.text = "Connected to host: \(peerID.displayName)."
                }
                
            case MCSessionState.connecting:
                //print("Connecting: \(peerID.displayName)")
                
                if !isHost {
                    statusLabel.text = "Connecting to host: \(peerID.displayName)"
                }
                
            case MCSessionState.notConnected:
                //print("Not Connected: \(peerID.displayName)")
                
                if !isHost {
                    statusLabel.text = "Disconnected from host: \(peerID.displayName)"
                }
                
            default:
                print("Error")
            }
            
            if isHost {
                if session.connectedPeers.count > 0 {
                    playButton.isEnabled = true
                } else {
                    playButton.isEnabled = false
                }
                
                clientList.text = "Client List:"
                
                for peer in session.connectedPeers {
                    //print(peer.displayName)
                    clientList.text?.append("\n\(peer.displayName)")
                }
            }
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "quizSegue", sender: self)
        }
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
        statusLabel.text = "You are the host."
        visibilityButton.isEnabled = false
        playButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        isHost = false
        statusLabel.text = "You are no longer the host."
        visibilityButton.isEnabled = true
        playButton.isEnabled = false
        
        session.disconnect()
        
        dismiss(animated: true, completion: nil)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if hapticSetting {
            AudioServicesPlaySystemSound(4095)
            print("vibrate")
        }
        
        let acceptAction = UIAlertAction(title: "Accept",
                                         style: .default) { [self] action in
            invitationHandler(true, session)
            visibilityButton.isSelected = false
            playButton.isEnabled = false
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
        playButton.isEnabled = false
        
        if isHost {
            if session.connectedPeers.count > 0 {
                playButton.isEnabled = true
            }
            
            clientList.text = "Client List:"
            
            for peer in session.connectedPeers {
                //print(peer.displayName)
                clientList.text?.append("\n\(peer.displayName)")
            }
        } else {
            clientList.text = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopClient()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(session.connectedPeers)
        
        if let identifier = segue.identifier {
            switch identifier {
            case "quizSegue":
                let controller = segue.destination as! QuizViewController
                
                if isHost {
                    let trigger: Data? = "segue".data(using: .utf8)
                    
                    do {
                        try session.send(trigger!, toPeers: session.connectedPeers, with: .reliable)
                    } catch {
                        print(error)
                    }
                }
                
                controller.gameMode = self.gameMode
                controller.session = self.session
            default:
                break
            }
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        print("unwind")
    }
}
