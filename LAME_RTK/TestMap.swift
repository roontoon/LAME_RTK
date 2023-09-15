//
//  testmap.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//\

import SwiftUI
import UIKit

struct TestUILabel: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Hello, UIKit!"
        label.textColor = .black
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        // Update the UILabel
    }
}

struct TestUILabel_Previews: PreviewProvider {
    static var previews: some View {
        TestUILabel()
    }
}
