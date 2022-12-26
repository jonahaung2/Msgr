//
//  ConInfoViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 26/12/22.
//

import Foundation

class ConInfoViewModel: ObservableObject {

    @Published var con: Con
    
    init(_ conID: String) {
        con = Con.object(for: conID, Persistance.shared.viewContext) ?? Con.fetchOrCreate(conId: conID, context: Persistance.shared.viewContext)
    }
}
