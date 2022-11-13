//
//  AuthenticationChecker.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI

private struct AuthenticationCheckerModifier: ViewModifier {

   @EnvironmentObject private var authenticator: Authenticator
   @AppStorage(UserDefaultManager.shared.UseFaceID) private var useFaceID = false
   
   func body(content: Content) -> some View {
      Group {
          if authenticator.isLoggedIn {
            content
                 .redacted(reason: authenticator.isUnlocked ? [] : .placeholder)
                 .task {
                     if useFaceID {
                         authenticator.authenticate()
                     } else {
                         authenticator.isUnlocked = true
                     }
                     CurrentUser.update()
                 }
         }else {
            SignInView()
         }
      }
   }
}

extension View {
   func authenticatable() -> some View {
      ModifiedContent(content: self, modifier: AuthenticationCheckerModifier())
   }
}
