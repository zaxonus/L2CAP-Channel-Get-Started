//
//  Utils.swift
//  BlueTooth
//
//  Created by Michel Bouchet on 2019/01/20.
//  Copyright © 2019 Michel Bouchet. All rights reserved.
//

import Foundation
import UIKit


func randomMessage() -> String {
    // This function returns a random string. It could be modified in any way and of course simplified.
    var randomString = randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 10)
    randomString += randomSequenceFrom("#$%&-!=", length: 1)
    randomString += randomSequenceFrom("0123456789", length: 6)
    randomString += randomSequenceFrom("#$%&-!=", length: 1)
    randomString += randomSequenceFrom("abcdefghijklmnopqrstuvwxyz", length: 7)
    randomString += "\n" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 6)
    randomString += randomSequenceFrom("+-*/=", length: 1)
    randomString += randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 6)
    randomString += randomSequenceFrom("+-*/=", length: 1)
    randomString += randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 6)
    randomString += randomSequenceFrom("0123456789", length: 5)
    randomString += "\n{\(randomSequenceFrom("0123456789", length: 6))}"
    randomString += ":=:[\(randomSequenceFrom("0123456789", length: 5))]"
    randomString += "(\(randomSequenceFrom("0123456789", length: 5)))"
    randomString += "\n" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 4)
    randomString += ":" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 4)
    randomString += "+" + randomSequenceFrom("abcdefghijklmnopqrstuvwxyz", length: 5)
    randomString += "+" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 4)
    randomString += ":" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 4)
    randomString += "\n" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 3)
    randomString += "*" + randomSequenceFrom("0123456789", length: 2)
    randomString += "+" + randomSequenceFrom("abcdefghijklmnopqrstuvwxyz", length: 4)
    randomString += randomSequenceFrom("#$%&-!:=", length: 3)
    randomString += randomSequenceFrom("abcdefghijklmnopqrstuvwxyz", length: 4)
    randomString += "+" + randomSequenceFrom("0123456789", length: 2)
    randomString += "*" + randomSequenceFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ", length: 3)
    
    return randomString
}


func randomSequenceFrom(_ string:String, length:Int) -> String {
    var charSequence = "", randomVal:Int
    for _ in 0..<length {
        randomVal = Int(arc4random_uniform(UInt32(string.utf8.count)))
        charSequence = charSequence + String(string[string.index(string.startIndex,
                                                                 offsetBy: randomVal)])
    }
    return charSequence
}


func sendL2CAPInfo(_ outStream: OutputStream,
                   reportPanel: UILabel) -> Bool {
    let msgValue = randomMessage(),
    data = Data(msgValue.utf8)
    let bytesWritten = data.withUnsafeBytes {outStream.write($0, maxLength: data.count)}
    
    if bytesWritten > 0 {
        reportPanel.text = "\(bytesWritten) bytes sent:\n\(msgValue)"
        return true
    }
    
    return false
}


func receiveL2CAPInfo(_ inStream: InputStream,
                      reportPanel: UILabel) {
    let bufLength = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufLength)
    let bytesRead = inStream.read(buffer, maxLength: bufLength)
    
    if let string = String(bytesNoCopy: buffer,
                           length: bytesRead,
                           encoding: .utf8,
                           freeWhenDone: false) {
        reportPanel.text = "\(bytesRead) bytes received:\n\(string)"
    }
}
