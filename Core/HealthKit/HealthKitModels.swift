import Foundation

// MARK: - HealthKit Permission Status

enum HealthKitPermissionStatus: Equatable {
    case notDetermined
    case denied
    case authorized
}

// MARK: - HealthKit Errors

enum HealthDataError: Error, LocalizedError {
    case notAvailable
    case permissionDenied
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "此设备不支持 HealthKit"
        case .permissionDenied:
            return "未获得健康数据访问权限"
        case .queryFailed(let reason):
            return "查询健康数据失败: \(reason)"
        }
    }
}
