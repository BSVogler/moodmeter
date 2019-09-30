//
//  MenInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 17.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//
import WatchKit
import Foundation

class MyRowController: NSObject {
	@IBOutlet weak var itemLabel: WKInterfaceLabel!
	@IBOutlet weak var itemImage: WKInterfaceImage!
}

class MenuInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var table: WKInterfaceTable!
	
	override func willActivate() {
		
		// Configure interface objects here.
		table.setNumberOfRows(3, withRowType: "menuItem")
		
		let sharing = self.table.rowController(at: 0) as! MyRowController
		sharing.itemImage.setImage(UIImage(systemName: "cloud"))
		sharing.itemLabel.setText(NSLocalizedString("Live sharing", comment: ""))
		
		//let export = self.table.rowController(at: 1) as! MyRowController
		//export.itemImage.setImage(UIImage(systemName: "square.and.arrow.up"))
		//export.itemLabel.setText("Export File")
		
		let reminder = self.table.rowController(at: 1) as! MyRowController
		reminder.itemImage.setImage(UIImage(systemName: "clock"))
		reminder.itemLabel.setText(NSLocalizedString("Reminder", comment: ""))
		
		let item2 = self.table.rowController(at: 2) as! MyRowController
		item2.itemImage.setImage(UIImage(systemName: "delete.right"))
		item2.itemLabel.setText(NSLocalizedString("Delete data", comment: ""))
		item2.itemLabel.setTextColor(#colorLiteral(red: 1, green: 0.4156862745, blue: 0.337254902, alpha: 1))
	}
	override func table(_ table: WKInterfaceTable,
						didSelectRowAt rowIndex: Int){
		switch rowIndex {
		case 0:
			if Model.shared.sharing.userHash == nil {
				let accept = WKAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default) {
					self.pushController(withName: "Share", context: nil)
				}
				let read = WKAlertAction(title: "Read", style: .default) {
					self.presentAlert(withTitle: NSLocalizedString("Privacy agreement", comment: ""), message: """
					Privacy Policy

					We value data protection. This privacy policy clarifies the nature, scope and purpose of the processing of personal data (hereinafter referred to as "data") within our online offer. With regard to the terminology used, e.g. "Processing" or "Responsible", we refer to the definitions in Article 4 of the General Data Protection Regulation (GDPR).
					Responsible

					Benedikt S. Vogler
					Hinterbärenbadstr. 78
					81373 München Deutschland
					developer@benediktsvogler.com
					Types of processed data:

					access code
					entered mood data and its time
					application configuration
					Purpose of processing

					Provision of the online offer, its functions and contents.
					Safety measures.
					Statistical analysis for product improvement.
					Reach Measurement.
					Generating of predictions of the mood.
					Used terms

					"Personal data" means any information relating to an identified or identifiable natural person (hereinafter the "data subject"); a natural person is considered as identifiable, which can be identified directly or indirectly, in particular by means of assignment to an identifier such as a name, to an identification number, to location data, to an online identifier (eg cookie) or to one or more special features, that express the physical, physiological, genetic, mental, economic, cultural or social identity of this natural person. "Processing" means any process performed with or without the aid of automated procedures or any such process associated with personal data. The term goes far and includes virtually every handling of data. "Responsible person" means the natural or legal person, public authority, body or body that decides, alone or in concert with others, on the purposes and means of processing personal data.
					Pseudonymity

					The personal data is associated with a randomly generated code. Because they are stored in a pseudonymized form (Art. 4 para. 5 GDPR), an assignment to a person is not possible without using further data.
					Relevant legal bases

					In accordance with Art. 13 GDPR, we inform you about the legal basis of our data processing. Unless the legal basis in the data protection declaration is mentioned, the following applies: The legal basis for obtaining consent is Article 6 (1) lit. a and Art. 7 GDPR, the legal basis for the processing for the performance of our services and the execution of contractual measures as well as the response to inquiries is Art. 6 (1) lit. b GDPR, the legal basis for processing in order to fulfill our legal obligations is Art. 6 (1) lit. c GDPR, and the legal basis for processing in order to safeguard our legitimate interests is Article 6 (1) lit. f GDPR. In the event that vital interests of the data subject or another natural person require the processing of personal data, Art. 6 para. 1 lit. d GDPR as legal basis.
					Collaboration with processors and third parties

					If, in the context of our processing, we disclose data to other persons and companies (contract processors or third parties), transmit them to them or otherwise grant access to the data, this will only be done on the basis of a legal permission (eg if a transmission of the data to third parties, as required by payment service providers, pursuant to Art. 6 (1) (b) GDPR to fulfill the contract), you have consented to a legal obligation or based on our legitimate interests (eg the use of agents, web hosters, etc.). If we commission third parties to process data based on a so-called "contract processing contract", this is done based on Art. 28 GDPR.
					Transfers to third countries

					If we process data in a third country (ie outside the European Union (EU) or the European Economic Area (EEA)) or in the context of the use of third party services or disclosure or transmission of data to third parties, this will only be done if it is to fulfill our (pre) contractual obligations, on the basis of your consent, on the basis of a legal obligation or the basis of our legitimate interests. Subject to legal or contractual permissions, we process or have the data processed in a third country only in the presence of the special conditions of Art. 44 et seq. DSGVO. This means, for example, that the processing takes place based on special guarantees, such as the officially recognized level of data protection (eg for the USA through the "Privacy Shield") or compliance with officially recognized special contractual obligations (so-called "standard contractual clauses").

					Rights of data subjects

					You have the right to ask for confirmation as to whether the data in question is being processed and for information about this data as well as for further information and a copy of the data in accordance with Art. 15 GDPR. In accordance with Art. 16 GDPR you have the right to demand the completion of the data concerning you or the correction of the incorrect data concerning you In accordance with Art. 17 GDPR, you have the right to demand that the relevant data be deleted immediately or, alternatively, to require a restriction of the processing of data in accordance with Art. 18 GDPR. You have the right to demand that the data relating to you, which you have provided to us, be obtained in accordance with Art. 20 GDPR and request their transmission to other persons responsible. You have acc. Art. 77 GDPR the right to file a complaint with the competent supervisory authority.
					Withdrawal

					You have the right to grant consent in accordance with. Art. 7 para. 3 DSGVO with effect for the future

					You can object to the future processing of your data in accordance with Art. 21 GDPR at any time.

					Cookies

					"Cookies" are small files that are stored on users' computers. Different information can be stored within the cookies. A cookie is primarily used to store the information about a user (or the device on which the cookie is stored) during or after his visit to an online offer. Temporary cookies, or "session cookies" or "transient cookies", are cookies that are deleted after a user leaves an online service and closes his browser. In such a cookie, for example, the content of a shopping cart can be stored in an online shop or a login jam. The term "permanent" or "persistent" refers to cookies that remain stored even after the browser has been closed. For example, the login status can be saved if users visit it after several days. Likewise, in such a cookie the interests of the users can be stored, which are used for range measurement or marketing purposes. A "third-party cookie" refers to cookies that are offered by providers other than the person who manages the online offer (otherwise, if it is only their cookies, this is called "first-party cookies"). We can use temporary and permanent cookies and clarify this in the context of our privacy policy. If users do not want cookies stored on their computer, they will be asked to disable the option in their browser's system settings. Saved cookies can be deleted in the system settings of the browser. The exclusion of cookies can lead to functional restrictions of this online offer.

					Hosting

					The hosting services we use are for the purpose of providing the following services: infrastructure and platform services, computing capacity, storage and database services, security and technical maintenance services we use to operate this online service. Here we, or our hosting provider, process inventory data, contact data, content data, contract data, usage data, meta and communication data of customers, interested parties and visitors to this online offer on the basis of our legitimate interests in an efficient and secure provision of this online offer acc. Art. 6 para. 1 lit. f DSGVO in conjunction with Art. 28 DSGVO (conclusion of contract processing contract).

					Collection of access data and log files

					We, or our hosting provider, collects on the basis of our legitimate interests within the meaning of Art. 6 para. 1 lit. f. GDPR Data on every access to the server on which this service is located (so-called server log files). The access data includes name of the retrieved web page, file, date and time of retrieval, amount of data transferred and message about successful retrieval. Logfile information is stored for security reasons (eg to investigate abusive or fraudulent activities) for a maximum of 7 days and then deleted. Data whose further retention is required for evidential purposes shall be exempted from the cancellation until final clarification of the incident.

					Contact

					When contacting us (eg via contact form, e-mail, telephone or via social media), the information provided by the user to process the contact request and its processing acc. Art. 6 para. 1 lit. b) GDPR processed. We delete the requests if they are no longer required. We check the necessity every two years; Furthermore, the legal archiving obligations apply.
					""", preferredStyle: .actionSheet, actions: [accept])
				}
				
				presentAlert(withTitle: NSLocalizedString("Privacy", comment: ""), message: NSLocalizedString("By using the share feature you agree to the privacy agreement.", comment: ""), preferredStyle: .actionSheet, actions: [read, accept])
			} else {
				pushController(withName: "Share", context: nil)
			}
		case 1:
			self.pushController(withName: "Reminder", context: nil)
		case 2:
			let accept = WKAlertAction(title: NSLocalizedString("Yes, delete", comment: ""), style: .destructive) {
				_ = Model.shared.eraseData()
			}
			presentAlert(withTitle: NSLocalizedString("Delete data?", comment: ""), message: NSLocalizedString("This will permanently delete your local data on your watch and phone.", comment: ""), preferredStyle: .actionSheet, actions: [ accept])
			
		default: print(NSLocalizedString("export not supported", comment: ""))
		}
		
	}
}

