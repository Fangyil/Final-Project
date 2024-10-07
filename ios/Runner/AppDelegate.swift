import Flutter
import UIKit
import GoogleMaps // 在此導入 Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 在此處提供您的 Google Maps API 金鑰
    GMSServices.provideAPIKey("AIzaSyBC5BnBviIJBBg-cFdK4M0F5UO_nD85m-I") // 替換為您的 API 金鑰

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
