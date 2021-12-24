//
//  Protocols.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/11/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation


protocol PresentationDelegate {
    func dismissParent(dismiss: Bool)
    func presentationDismissed(action: String)
}
