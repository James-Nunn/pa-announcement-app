//
//  Colour.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import Foundation
import SwiftUI

extension Color {
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

extension Color{
    public static var messageImportantBackgroundColor:Color {
        return Color(0xFDC300)
    }
    public static var messageBackgroundColor:Color {
        return Color(0xD9D9D9)
    }
    public static var schoolRedColor:Color {
        return Color(0xAA214C)
    }
}
