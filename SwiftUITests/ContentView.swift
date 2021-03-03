//
//  ContentView.swift
//  SwiftUITests
//
//  Created by Alexander Golikov on 1/9/21.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var items = ["", "", ""]

    var body: some View {
        Form {
            ForEach(0..<items.count + 1, id: \.self) { index in
                WCTextEditor(text: $items[index, default: ""])

            }
            .onDelete(perform: self.delete)
        }
    }

    func delete(_ indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
}

extension Binding where
    Value: MutableCollection,
    Value: RangeReplaceableCollection
{
    subscript(
        _ index: Value.Index,
        default defaultValue: Value.Element
    ) -> Binding<Value.Element> {
        Binding<Value.Element> {
            guard index < self.wrappedValue.endIndex else {
                return defaultValue
            }
            return self.wrappedValue[index]
        } set: { newValue in

            // It is possible that the index we are updating
            // is beyond the end of our array so we first
            // need to append items to the array to ensure
            // we are within range.
            while index >= self.wrappedValue.endIndex {
                self.wrappedValue.append(defaultValue)
            }

            self.wrappedValue[index] = newValue
        }
    }
}

extension String : Identifiable {

    public var id: String {
        UUID().uuidString
    }
}

struct WCTextEditor: View {

    @Binding var text: String

    @State private var calculatedHeight = WCTextView.minHeight

    @State var id = UUID().uuidString

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WCTextView(text: $text, calculatedHeight: $calculatedHeight)
                .frame(
                    minHeight: calculatedHeight,
                    maxHeight: calculatedHeight
                )
            border
            Text("Placeholder")
                .foregroundColor(.gray)
                .padding(.leading, 5)
        }
    }

    var border: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 10)
            Rectangle()
                .foregroundColor(.gray)
                .frame(height: 8)
                .animation(.linear(duration: 0.1))
        }
    }
}

struct WCTextView : UIViewRepresentable {

    static let minHeight: CGFloat = 44

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        WCTextView.recalculateHeight(view: textView, result: $calculatedHeight)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text

        WCTextView.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    func makeCoordinator() -> WCTextView.Coordinator {
        return Coordinator(text: $text, calculatedHeight: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))
        guard result.wrappedValue != newSize.height else { return }
        DispatchQueue.main.async { // call in next render cycle.
            result.wrappedValue = max(newSize.height, minHeight)
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {

        private var text: Binding<String>
        private var calculatedHeight: Binding<CGFloat>

        init(text: Binding<String>, calculatedHeight: Binding<CGFloat>) {
            self.text = text
            self.calculatedHeight = calculatedHeight
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            WCTextView.recalculateHeight(view: textView, result: calculatedHeight)
        }
    }
}
