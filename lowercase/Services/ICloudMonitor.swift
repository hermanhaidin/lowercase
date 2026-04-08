import Foundation

@Observable
final class ICloudMonitor {

    private(set) var isGathered = false

    var onUpdate: (() async -> Void)?

    private var query: NSMetadataQuery?
    private var gatherTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?

    // MARK: - Lifecycle

    func startMonitoring() {
        guard query == nil else { return }

        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(value: true)
        query.notificationBatchingInterval = 0.5

        self.query = query

        gatherTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: .NSMetadataQueryDidFinishGathering
            ) {
                guard let self else { return }
                self.isGathered = true
                await self.handleQueryUpdate()
            }
        }

        updateTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: .NSMetadataQueryDidUpdate
            ) {
                guard let self else { return }
                await self.handleQueryUpdate()
            }
        }

        query.start()
    }

    func stopMonitoring() {
        query?.stop()
        query = nil
        gatherTask?.cancel()
        gatherTask = nil
        updateTask?.cancel()
        updateTask = nil
        isGathered = false
    }

    // MARK: - Private

    private func handleQueryUpdate() async {
        query?.disableUpdates()
        defer { query?.enableUpdates() }

        triggerDownloads()
        await onUpdate?()
    }

    /// Eagerly downloads any iCloud files that aren't local yet.
    /// .md files are tiny so downloading all of them avoids latency when opening.
    private func triggerDownloads() {
        guard let query else { return }

        for i in 0..<query.resultCount {
            guard let item = query.result(at: i) as? NSMetadataItem else { continue }

            let status = item.value(
                forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey
            ) as? String

            guard status != NSMetadataUbiquitousItemDownloadingStatusCurrent,
                  let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL
            else { continue }

            try? FileManager.default.startDownloadingUbiquitousItem(at: url)
        }
    }
}
