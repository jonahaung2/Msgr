//
//  ContactInfoViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 26/12/22.
//

import Foundation

class ContactInfoViewModel: ObservableObject {

    let contact: Contact

    init(_ contactID: String) {
        contact = Contact.object(for: contactID, Persistance.shared.viewContext) ?? Contact.save(.init(id: contactID), context: Persistance.shared.viewContext)
    }
}
