import Sparkle

@MainActor
public enum PoppyUpdater {
    private static let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    public static func start() {
        _ = updaterController
    }

    public static func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
