//
//  ImagineIAApp.swift
//  ImagineIA
//
//  Created by Anthony José on 29/03/23.
//

import SwiftUI
import Firebase
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    FirebaseApp.configure()
    return true
  }
}


@main
struct ImagineIAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class Interstitial: NSObject, GADFullScreenContentDelegate {
    private var interstitial: GADInterstitialAd?
    static var shared: Interstitial = Interstitial()
    
    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }
    
    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-8762893864776699/2747873953", request: request, completionHandler: { [self] ad, error in
            if ad != nil { interstitial = ad }
            interstitial?.fullScreenContentDelegate = self
        })
    }
    
    func showInterstitialAds() {
        if interstitial != nil, let root = rootController {
            interstitial?.present(fromRootViewController: root)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}

/// Root controller for the app
var rootController: UIViewController? {
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController { root = presenter }
    return root
}
