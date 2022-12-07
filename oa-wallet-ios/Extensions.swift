//
//  Extensions.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 7/12/22.
//

import UniformTypeIdentifiers

extension UTType {
    static var oa: UTType {
        UTType(exportedAs: "com.openattestation.document")
    }
}
