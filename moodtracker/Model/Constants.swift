//
//  Constants.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit

// MARK: - Hosts
enum Hosts {
    
    // MARK: Type Properties
    static let baseURL = NSURL(string: "https://mood.benediktsvogler.com")! as URL
}

// MARK: - LocalStorageConstants
enum LocalStorageConstants {

    // MARK: Type Properties
    static let databaseFileName = "data.json"
    static var documentDirectoryStorageURL: URL {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the document directory in the user's home directory.")
        }
        return documentsDirectory.appendingPathComponent(databaseFileName)
    }
}

// MARK: - MoodConstants
enum MoodConstants {
    
    // MARK: Stored Type Properties
    static var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
    static var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.8156862745, green: 0.368627451, blue: 0.537254902, alpha: 1), #colorLiteral(red: 0.6980392157, green: 0.6078431373, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5333333333, green: 1, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 1, green: 0.8941176471, blue: 0.1490196078, alpha: 1)]
}

// MARK: - SharingConstants
enum SharingConstants {
    
    // MARK: Stored Type Properties
    /// https://en.wikipedia.org/wiki/Birthday_attack
    /// with alphabet of 34 symbols there are ~3*10^20 possibilities. Birthday paradoxon colission probability is approx. 10^-8 after 2.4 Mio tries
    /// for 5, 107 billion tries are needed
    static let hashLength = 10;
}
