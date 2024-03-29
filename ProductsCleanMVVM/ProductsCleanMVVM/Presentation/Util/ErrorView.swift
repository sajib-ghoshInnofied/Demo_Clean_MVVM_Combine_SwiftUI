//
//  ErrorView.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 14/02/24.
//

import SwiftUI

struct ErrorView: View {
    
    let errorTitle: String
    let errorDescription: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack{
            ContentUnavailableView(errorTitle, systemImage: "exclamationmark.triangle.fill", description: Text(errorDescription))
                .frame(height:200)
            Button("Retry"){
                retryAction()
            }
        }
        .animation(.easeInOut, value: 0.5)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ErrorView(errorTitle: "", errorDescription: "", retryAction: {})
}
