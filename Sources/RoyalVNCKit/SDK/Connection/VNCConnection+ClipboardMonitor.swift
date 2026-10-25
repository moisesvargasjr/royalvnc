#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension VNCConnection {
	func startMonitoringClipboard() {
		guard settings.isClipboardRedirectionEnabled else { return }

		clipboardMonitor.startMonitoring()
	}

	func stopMonitoringClipboard() {
		guard settings.isClipboardRedirectionEnabled else { return }

		clipboardMonitor.stopMonitoring()
	}
}

public extension VNCConnection {
	/// Sends `text` to the server's clipboard (RFB ClientCutText, Latin-1),
	/// regardless of `isClipboardRedirectionEnabled`.
	func sendClipboardText(_ text: String) {
		enqueueClientCutTextMessage(text)
	}
}

// MARK: - VNCClipboardMonitorDelegate
extension VNCConnection: VNCClipboardMonitorDelegate {
	func clipboardMonitorShouldMonitor(_ clipboardMonitor: VNCClipboardMonitor) -> Bool {
#if os(iOS)
		// Reading UIPasteboard content copied in another app shows the system
		// "Allow Paste" prompt on every read, so iOS clients send local text
		// explicitly with `sendClipboardText(_:)` (e.g. from a PasteButton).
		// Server-to-client text is still written to the pasteboard.
		return false
#else
		let isConnected = connectionState.status == .connected

		return isConnected
#endif
	}

	func clipboardMonitor(_ clipboardMonitor: VNCClipboardMonitor,
						  didChangeText text: String) {
		logger.logDebug("Clipboard Monitor did change text")

		guard settings.isClipboardRedirectionEnabled else { return }

		enqueueClientCutTextMessage(text)
	}
}
