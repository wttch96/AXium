// The Swift Programming Language
// https://docs.swift.org/swift-book

// @preconcurrency属性是帮助您逐步迁移到严格并发检查的工具的一部分.
// 当苹果引入异步/等待时, 我们正在编写非结构化异步代码, 主要使用闭包.
// 在我们通往 Swift 6 的道路上, 我们必须为编译器进行严格的并发检查准备我们的项目.
//
// 为了压制 kAXTrustedCheckOptionPrompt 不安全的警告
@preconcurrency import ApplicationServices
import OSLog

public class AXium {
    private init() {}
    /// 当前进程是否为受信任的辅助功能客户端
    /// - Parameter promt: 是否显示提示, 如果 true 则会系统弹窗询问是否给权限
    /// - Returns: 是否受信任
    /// - alsoSee: [AXIsProcessTrusted](https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted)
    /// - alsoSee: [AXIsProcessTrustedWithOptions](https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions)
    public static func isProcessTrusted(promt: Bool = false) -> Bool {
        if !promt {
            return AXIsProcessTrusted()
        } else {
            let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
            let options = [key: true] as CFDictionary
            return AXIsProcessTrustedWithOptions(options)
        }
    }

    static let logger = Logger(subsystem: "com.wttch.AXium", category: "AXium")
}
