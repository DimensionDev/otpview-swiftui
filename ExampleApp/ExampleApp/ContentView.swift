//
//  ContentView.swift
//  ExampleApp
//
//  Created by MainasuK on 2024-11-24.
//

import SwiftUI
import OTPView

struct ContentView: View {
    @State var anotherText = ""

    var body: some View {
        VStack {
            OTPView(
                configuration: .init(length: 6),
                box: { context in
                    let strokeColor = context.isActive ? Color.primary : Color.secondary.opacity(0.5)
                    Rectangle()
                        .strokeBorder(strokeColor, lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text(context.character.uppercased())
                        }
                        .drawingGroup()
                },
                onChange: { code in
                    print(code)
                }
            )
            TextField("Other", text: $anotherText)
                .padding()
                .textFieldStyle(.roundedBorder)
        }
    }

}

#Preview {
    ContentView()
}
