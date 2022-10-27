//
//  GoogleSearchView.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 3/9/22.
//

import SwiftUI
import WebKit

struct GoogleSearchView: UIViewRepresentable {
    var searchString: String
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView : WKWebView , context : Context) {
        if let url = URL(string: "https://www.google.com/search?q=\(searchString.urlEncoded)") {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
