//
//  SharingHash.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import Alamofire

// MARK: - SharingHash
class SharingHash: Codable {
    
    // MARK: Constants
    private enum Constants {
        
        static let alphabet: [Character] = [
            "a","b","c","d","e","f","g","h","i","j",
            "k","l","m","n","p","q","r","s","t","u",
            "v","w","x","y","z","0","1","2","3","4",
            "5","6","7","8","9"
        ]
    }
    
    // MARK: Stored Instance Properties
    var userHash: String?
    var password: String?
    
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
    private func resultRegister(done: @escaping (Bool, Error?) -> Void, res: Result<RegisterResponse>) -> Void {
        if res.isSuccess {
            if let userHash =  res.value?.hash {
                self.userHash = userHash
                _ = DataHandler.saveToFiles()
            } else {
                done(false, NSError(domain: "got no hash", code: 1, userInfo: nil))
            }
        }
        done(res.isSuccess, res.error)
    }
    
    /// if there is already a hash, it moves them
    final func registerHash(done: @escaping (Bool, Error?) -> Void){
        if let old = self.userHash {
            MoodApiJsonHttpClient.shared.moveHash(old: old) { res in
                self.resultRegister(done: done, res: res)
            }
        } else {
            MoodApiJsonHttpClient.shared.register(measurements: DataHandler.userProfile.dataset) { res in
                self.resultRegister(done: done, res: res)
            }
        }
    }
    
    func importHash(_ hash: String, done: @escaping (Bool, Error?) -> Void) {
        guard userHash != nil else {
            //this should not happen
            return
        }
        if hash.count > 1 {
            if let old = self.userHash {
                MoodApiJsonHttpClient.shared.importHash(old: old, new: hash) { res in
                    if res.isSuccess {
                        self.userHash = hash //use new only after request completed
                        _ = DataHandler.saveToFiles()
                    }
                    done(res.isSuccess, res.error)
                }
            }
        } else {
            done(false, NSError(domain: "Invalid import call. no hash found", code: 13, userInfo: nil))
        }
    }
    
    func disableSharing(){
        userHash = nil
        _ = DataHandler.saveToFiles()
    }
    
    func refresh(done: @escaping ()-> Void ){
        if let userHash = userHash {
            MoodApiJsonHttpClient.shared.getData(hash: userHash){ res in
                done()
            }
        }
    }
}
