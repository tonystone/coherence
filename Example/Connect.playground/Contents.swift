//: Playground - noun: a place where people can play

import UIKit
@testable import Connect

let url = URLComponents(string: "http://example.com/widgets/reports/stock;instockonly;accountID=12323?id=1234")

url?.string

url?.queryItems
url?.path
url?.fragment
url?.query
url?.host

URL(string: "/temp")?.absoluteString


WADLMediaType(rawValue: "test")



