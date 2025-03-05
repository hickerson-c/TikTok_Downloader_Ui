import UIKit
import Flutter
import QuickLook

@main
@objc class AppDelegate: FlutterAppDelegate, QLPreviewControllerDataSource {
    
    var previewItem: URL?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Function to present Quick Look Preview
    func presentQuickLook(for filePath: String) {
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: filePath)
        
        // ✅ Ensure the file has read permissions
        do {
            try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: filePath)
        } catch {
            print("❌ Failed to set file permissions: \(error)")
        }

        guard let window = UIApplication.shared.windows.first else { return }

        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewItem = fileURL

        // ✅ Reload Quick Look to ensure the new file is loaded
        previewController.reloadData()

        window.rootViewController?.present(previewController, animated: true, completion: nil)
    }

    // QLPreviewControllerDataSource methods
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItem != nil ? 1 : 0
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItem! as QLPreviewItem
    }
}