//
//  VendorQrModel.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 04/01/23.
//

import Foundation

struct VendorQrModel: Codable {
    var QRId: Int32
    var vendorName: String
    var amount: Float
}
