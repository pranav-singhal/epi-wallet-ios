//
//  helpers.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 14/01/23.
//

import Foundation
let USERNAME_MESSAGE_IDENTIFIER = "username:"
let WALLET_ADDRESS_MESSAGE_IDENTIFIER = "ethereum:"

func isEthereumAddressString (qrString: String ) -> Bool {
    return qrString.contains("ethereum:0x");
}


func getUsernameFromUsernameMessage (usernameMessage: String) -> String {
    let str = usernameMessage
    let start = str.index(str.startIndex, offsetBy: USERNAME_MESSAGE_IDENTIFIER.count)
    let username = String(str[start...])
    return username.lowercased()
}

func getWalletAddressFromMessage (walletAddressMessage: String) -> String {
    let str = walletAddressMessage
    let start = str.index(str.startIndex, offsetBy: WALLET_ADDRESS_MESSAGE_IDENTIFIER.count)
    let walletAddress = String(str[start...])
    return walletAddress
}
