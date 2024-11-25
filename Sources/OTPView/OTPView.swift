import SwiftUI

public struct OTPView<Box>: View where Box: View {

    let configuration: OTPViewConfiguration
    let box: (OTPViewBoxContext) -> Box
    let onChange: (String) -> Void

    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool

    public init(
        configuration: OTPViewConfiguration = .init(),
        @ViewBuilder box: @escaping (OTPViewBoxContext) -> Box,
        onChange: @escaping (String) -> Void
    ) {
        self.configuration = configuration
        self.box = box
        self.onChange = onChange
    }

    public var body: some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0...configuration.length-1, id: \.self) { index in
                let boxContext = boxContext(on: index)
                box(boxContext)
            }
        }.background {
            TextField("", text: $otpText.limit(configuration.length))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { newValue in
                    onChange(newValue)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
        .overlay {
            Menu {
                Button {
                    if let string = UIPasteboard.general.string {
                        otpText = string
                    }
                } label: {
                    Label("Paste", systemImage: "document.on.clipboard")
                }
            } label: {
                Color.clear
            } primaryAction: {
                isKeyboardShowing = true
            }
        }
    }
}

extension OTPView {
    private func boxContext(on index: Int) -> OTPViewBoxContext {
        return OTPViewBoxContext(
            index: index,
            character: {
                let characters = Array(otpText)
                return index < characters.count ? String(characters[index]) : " "
            }(),
            isActive: {
                let isActive = (isKeyboardShowing && otpText.count == index)
                return isActive
            }()
        )
    }

    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack{
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let isActive = (isKeyboardShowing && otpText.count == index)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isActive ? Color(uiColor: configuration.activeIndicatorColor) : Color(uiColor: configuration.inactiveIndicatorColor))
                .animation(.easeInOut(duration: 0.2), value: isActive)

        }
        .padding()
        .drawingGroup()
    }
}

public struct OTPViewConfiguration {
    public let length: Int
    public let spacing: CGFloat
    public let activeIndicatorColor: UIColor
    public let inactiveIndicatorColor: UIColor

    public init(
        length: Int = 6,
        spacing: CGFloat = 8,
        activeIndicatorColor: UIColor = .tintColor,
        inactiveIndicatorColor: UIColor = .secondaryLabel
    ) {
        self.length = length
        self.spacing = spacing
        self.activeIndicatorColor = activeIndicatorColor
        self.inactiveIndicatorColor = inactiveIndicatorColor
    }
}

public struct OTPViewBoxContext {
    public let index: Int
    public let character: String
    public let isActive: Bool

    public init(
        index: Int,
        character: String,
        isActive: Bool
    ) {
        self.index = index
        self.character = character
        self.isActive = isActive
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
