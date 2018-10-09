import Foundation

// Make an URLComponents instance
let swifty = NSURLComponents(string: "https://swift.org")!

// Print something useful about the URL
print("\(swifty.host!)")

// Output: "swift.org"
