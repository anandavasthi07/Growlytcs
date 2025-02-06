//
//  AuthenticationViewModel.swift
//  Ellifit
//
//  Created by Rudrank Riyam on 05/05/21.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import Growlytics

class AuthenticationViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    init() {
        self.state = UserDefaultsManager.shared.get(forKey: UserDefaultsManager.Keys.signedIn) == true ? .signedIn : .signedOut
    }
    
    func signInWithgoogle() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
                authenticateUser(for: user?.user, with: error)
            }
            
        }
    }
    
    func signIn(userName: String) {
        UserDefaultsManager.shared.setString(userName, forKey: UserDefaultsManager.Keys.userName)
        UserDefaultsManager.shared.set(true, forKey: UserDefaultsManager.Keys.signedIn)
        state = .signedIn
        Analytics.getInstance().loginUser("ManualLogin", ["Email": userName])
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // 2
        guard let authentication = user, let idToken = authentication.idToken?.tokenString else { return }
        
        Analytics.getInstance().loginUser(authentication.userID, ["Email": authentication.profile?.email ?? "example@gmail.com"])
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)
        
        // 3
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            state = .signedIn
            UserDefaultsManager.shared.set(true, forKey: UserDefaultsManager.Keys.signedIn)
        }
    }
    
    func signOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
        
        do {
            // 2
            try Auth.auth().signOut()
            UserDefaultsManager.shared.clearAll()
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
}
