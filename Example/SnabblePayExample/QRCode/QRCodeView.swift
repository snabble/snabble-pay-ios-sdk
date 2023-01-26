//
//  QRCodeView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    @State var code: String
    @State var size: CGSize = .init(width: 200, height: 200)

    init(code: String) {
        self.code = code
    }

    var body: some View {
        Image(uiImage: generateQRCode(from: code))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
    }

    private func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCodeImage = filter.outputImage {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(code: "Hallo")
    }
}
