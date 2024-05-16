import UIKit
import GoogleSignIn
import FirebaseAuth
import Network

@objcMembers
@objc class LoginViewModel: NSObject {
    @objc func signOut() {
            UserDefaults.standard.removeObject(forKey: "userToken")
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
    
    @objc func isNetworkAvailable(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Network")
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
            monitor.cancel()
        }
        monitor.start(queue: queue)
    }
}

enum LoginError: Error {
    case missingIDToken
}
