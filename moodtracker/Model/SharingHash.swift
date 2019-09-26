//
//  SharingHash.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - SharingHash
class SharingHash: Codable {
    
    // MARK: Constants
    private enum Constants {
        
        /// https://en.wikipedia.org/wiki/Birthday_attack
        /// with alphabet of 34 symbols there are ~3*10^20 possibilities. Birthday paradoxon colission probability is approx. 10^-8 after 2.4 Mio tries
        /// for 5, 107 billion tries are needed
        static let hashlength = 10;
        static let alphabet: [Character] = [
            "a","b","c","d","e","f","g","h","i","j",
            "k","l","m","n","p","q","r","s","t","u",
            "v","w","x","y","z","0","1","2","3","4",
            "5","6","7","8","9"
        ]

    }
    
    // MARK: Stored Instance Properties
    var userHash: String?
    
    // MARK: Computed Properties
    var url: URL? {
        guard let deviceHash = self.userHash else {
            return nil
        }
        return Hosts.baseURL.appendingPathComponent(deviceHash)
    }
    
    /// TODO: Why is this a `String?`and not a `URL`
    var urlWithoutProtocol: String? {
        guard let sharingURL = self.url,
            let host = sharingURL.host else {
                return nil
        }
        return host + sharingURL.path
    }
    
    // MARK: Instance Methods
    /// if there is already a hash, it moves them
    final func generateAndRegisterHash(done: @escaping () -> Void) {

        // the hash does not have to be secure, just the seed, so use secure seed directly
        var bytes = [UInt8](repeating: 0, count: Constants.hashlength)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        if status == errSecSuccess { // always test the status
            let toURL = String(bytes.map{ byte in Constants.alphabet[Int(byte % UInt8(Constants.alphabet.count))] })
            if userHash != nil {
                moveHash(to: toURL) {
                    _ = DataHandler.saveToFiles()
                    done()
                }
            } else {
                // create by just posting
                userHash = toURL
                MoodApiJsonHttpClient.shared.postMeasurement(measurements: DataHandler.userProfile.dataset) { _ in
                    _ = DataHandler.saveToFiles()
                    done()
                }
            }
        }
    }
    
    /// I would like to return a more generic Result<>, but I was not able to do this
    func importHash(_ hash: String, done: @escaping () -> Void) {
        guard userHash != nil else {
            //this should not happen
            generateAndRegisterHash(done: done)
            return
        }
        moveHash(to: hash, done: done)
    }
    
    /// I would like to return a more generic Result<>, but I was not able to do this
    func moveHash(to: String, done: @escaping () -> Void) {
        if let old = self.userHash {
            MoodApiJsonHttpClient.shared.moveHash(old: old, new: to) { res in
                self.userHash = to //use new only after request completed
                done()
            }
        } else {
            generateAndRegisterHash(done: done)
        }
    }
    
    func disableSharing(){
        userHash = nil
        _ = DataHandler.saveToFiles()
    }
    
    func refresh(){
        if let userHash = userHash {
            MoodApiJsonHttpClient.shared.getData(hash: userHash){ _ in }
        }
    }
}
