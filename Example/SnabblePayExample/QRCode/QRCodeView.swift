//
//  QRCodeView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let code: String

    private var qrCodeImage: UIImage {
        guard let image = code.qrCodeImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        return image
    }

    var body: some View {
        Image(uiImage: qrCodeImage)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }
}

private extension String {
    var qrCodeImage: UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(self.utf8)

        if let outputImage = filter.outputImage {
            let maskFilter = CIFilter.blendWithMask()
            maskFilter.maskImage = outputImage.applyingFilter("CIColorInvert")

            // create a version of the code with black foreground...
            maskFilter.inputImage = CIImage(color: .black)
            let blackCIImage = maskFilter.outputImage!
            // ... and one with white foreground
            maskFilter.inputImage = CIImage(color: .white)
            let whiteCIImage = maskFilter.outputImage!

            // render both images
            let blackImage = context.createCGImage(blackCIImage, from: blackCIImage.extent).map(UIImage.init)!
            let whiteImage = context.createCGImage(whiteCIImage, from: whiteCIImage.extent).map(UIImage.init)!

            // use black version for light mode
            // let qrImage = UIImage(cgImage: blackImage)
            // assign the white version to be used in dark mode
            blackImage.imageAsset?.register(whiteImage, with: UITraitCollection(userInterfaceStyle: .dark))

            return blackImage
        }
        return nil
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(code: "Hallo")
    }
}
