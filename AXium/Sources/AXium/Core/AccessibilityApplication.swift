//
//  AccessibilityApplication.swift
//  AXium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 具有指定运行应用程序的辅助功能对象
public struct AccessibilityApplication {
    /// 元素根节点
    public let root: AccessibilityElement

    /// 使用具有指定进程 ID 的应用程序创建顶级辅助功能对象
    /// - Parameter
    ///    - pid: 应用程序的进程 ID
    public init(pid: pid_t) {
        let element = AXUIElementCreateApplication(pid)
        self.root = AccessibilityElement(element)
    }
}

extension AccessibilityApplication {
    /// 检查具有指定 bundle identifier 的应用程序是否正在运行
    /// - Parameter bundleId: 应用程序的 bundle identifier
    public static func isRunning(bundleId: String) -> Bool {
        return NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
            .isEmpty == false
    }
}

extension AccessibilityApplication {
    /// 使用具有指定运行应用程序的辅助功能对象创建顶级辅助功能对象
    init(application: NSRunningApplication) {
        self.init(pid: application.processIdentifier)
    }

    /// 使用具有指定 bundle identifier 的应用程序创建顶级辅助功能对象, 只返回第一个
    public init?(withBundleIdentifier: String) {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: withBundleIdentifier).first else {
            return nil
        }

        self.init(pid: app.processIdentifier)
    }

    init?(name: String) {
        let pid = NSWorkspace.shared.runningApplications.filter { !$0.isTerminated }
            .first { $0.localizedName?.contains(name) ?? false }?.processIdentifier
        guard let pid = pid else { return nil }
        self.init(pid: pid)
    }
}

extension AccessibilityApplication {
    /// 获取所有运行的应用程序的辅助功能对象
    /// - Returns: 辅助功能对象数组
    static func all() -> [AccessibilityApplication] {
        NSWorkspace.shared.runningApplications
            .filter { !$0.isTerminated }
            .compactMap { AccessibilityApplication(pid: $0.processIdentifier) }
    }

    /// 使用具有指定 bundle identifier 的应用程序创建顶级辅助功能对象
    /// - Parameter withBundleIdentifier: bundle identifier
    /// - Returns: 辅助功能对象数组
    static func allForBundle(withBundleIdentifier: String) -> [AccessibilityApplication] {
        NSRunningApplication
            .runningApplications(withBundleIdentifier: withBundleIdentifier)
            .compactMap { AccessibilityApplication(pid: $0.processIdentifier) }
    }
}

extension AccessibilityApplication {
    public func findElement(matching predicate: (AccessibilityElement) -> Bool) -> AccessibilityElement? {
        return root.find { predicate($0) }
    }

    func visit(_ element: AccessibilityElement, _ deep: Int, _ block: (AccessibilityElement, Int) throws -> Void) {
        do {
            try block(element, deep)
        } catch {
            print(error)
        }
        for element in (try? element.children) ?? [] {
            visit(element, deep + 1, block)
        }
    }
}
