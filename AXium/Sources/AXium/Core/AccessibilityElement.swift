//
//  AccessibilityElement.swift
//  AXium
//
//  本文件主要是对 AXUIElement 对象的封装
//
//  Created by Wttch on 2024/11/10.
//

import ApplicationServices
import OSLog

fileprivate let logger = Logger(subsystem: "com.wttch.AXium", category: "AccessibilityElement")

/// 对 `AXUIElement` 进行封装
public struct AccessibilityElement: Identifiable, Hashable, @unchecked Sendable {
    public let id: String = UUID().uuidString

    public let original: AXUIElement

    public var children: [AccessibilityElement] {
        get throws {
            try original.attribute(.children) ?? []
        }
    }

    public init(_ element: AXUIElement) {
        self.original = element
    }
}

// MARK: - 原类型扩展

fileprivate extension AXUIElement {
    func attributesAsStrings() throws -> [String] {
        var names: CFArray?
        let error = AXUIElementCopyAttributeNames(self, &names)

        if error == .noValue || error == .attributeUnsupported {
            return []
        }

        guard error == .success else {
            throw AccessibilityError.error(error)
        }

        return names! as! [String]
    }

    /// 获取当前辅助功能对象的属性值
    /// - Parameter attribute: 属性键
    /// - Throws: 如果无法检索属性值, 或者类型不匹配, 则抛出错误
    /// - Returns: 属性值
    func attribute<O, T>(_ attribute: AccessibilityAttributeKey<O, T>) -> T? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(self, attribute.key as CFString, &value)

        if error == .noValue || error == .attributeUnsupported {
            return nil
        }

        guard error == .success else {
            logger.error("获取属性 \(attribute.key) 失败: \(error.rawValue)")
            return nil
        }
        guard let value = value as? O
        else {
            logger.error("属性 \(attribute.key) 类型不匹配: 期望类型 \(O.self), 实际类型 \(type(of: value))")
            return nil
        }

        return attribute.convertFunc(value)
    }

    func requiredAttribute<O, T>(_ attribute: AccessibilityAttributeKey<O, T>) throws -> T {
        guard let value = self.attribute(attribute) else {
            throw AccessibilityError.logicError("属性值不存在")
        }
        return value
    }

    func requiredAttribute<O, T>(_ attribute: AccessibilityAttributeKey<O, [T]>) throws -> [T] {
        guard let value = self.attribute(attribute) else {
            // TODO: 区分属性不存在和属性值为空的情况
            return []
        }
        return value
    }
}

// MARK: - 计算属性的获取

extension AccessibilityElement {
    /// 创建一个辅助功能对象，以提供对系统属性的访问
    init() {
        self.init(AXUIElementCreateSystemWide())
    }
}

public extension AccessibilityElement {
    func attributeValueType<O, T>(_ attribute: AccessibilityAttributeKey<O, T>) throws -> AXValueType? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(original, attribute.key as CFString, &value)
        if error != .success {
            return nil
        }
        let axValue = value as! AXValue

        let type: AXValueType = AXValueGetType(axValue)

        return type
    }

    internal var pid: pid_t? {
        var pid: pid_t = 0
        let result = AXUIElementGetPid(original, &pid)
        guard result == .success else { return nil }
        return pid
    }

    internal var allowedValues: [Any] {
        get throws {
            try original.requiredAttribute(.allowedValues)
        }
    }

    var attributes: [String] {
        get throws {
            try original.attributesAsStrings()
        }
    }

    func getAttribute<O, T>(_ attribute: AccessibilityAttributeKey<O, T>) -> T? {
        do {
            return try original.attribute(attribute)
        } catch {
            logger.error("获取属性 \(attribute.key) 失败: \(error.localizedDescription)")
            return attribute.defaultValue
        }
    }

    var description: String? {
        getAttribute(.description)
    }

    /// 指示元素启用状态的标志(原始数据为 `NSNumber`, 已经转换为 `Bool`).
    ///
    /// - seeAlse: [Enabled](https://developer.apple.com/documentation/appkit/nsaccessibility/attribute/1530006-enabled)
    /// - seeAlso: [kaxenabledattribute](https://developer.apple.com/documentation/applicationservices/kaxenabledattribute)
    var enabled: Bool {
        get throws {
            try original.requiredAttribute(.enabled)
        }
    }

    var focused: Bool {
        get throws {
            try original.requiredAttribute(.focused)
        }
    }

    var focusedElement: AccessibilityElement? {
        get throws {
            try original.attribute(.focusedUIElement)
        }
    }

    var hidden: Bool {
        get throws {
            try original.requiredAttribute(.hidden)
        }
    }

    var help: String? {
        get throws {
            try original.attribute(.help)
        }
    }

    var value: Any? {
        get throws {
            try original.attribute(.value)
        }
    }

    /// 元素的标识（`NSString`）。
    ///
    ///
    /// -- seeAlso: [identifier](https://developer.apple.com/documentation/appkit/nsaccessibility/attribute/1528737-identifier)
    /// -- seeAlso: [kaxidentifierattribute](https://developer.apple.com/documentation/applicationservices/kaxidentifierattribute)
    var identifier: String? {
        get throws {
            try original.attribute(.identifier)
        }
    }

    /// 元素值的描述（`NSString`）。
    ///
    /// 用于补充 `value` 的属性。该属性返回一个字符串描述，用于最佳描述当前存储在 `value` 中的值。
    /// 这在滑块等控件中非常有用，因为 `value` 中的数值并不总能充分表达滑块调整后的具体信息。
    /// 例如，一个通过滑块调整不同颜色的颜色滑块，其数值并不能很好地描述滑块当前所代表的颜色。
    /// 在这种情况下，`valueDescription` 就能派上用场。开发者可以使用此属性提供颜色相关的信息。
    /// - seeAlso:[valueDescription](https://developer.apple.com/documentation/appkit/nsaccessibility/attribute/1529313-valuedescription)
    /// - seeAlso: [kaxvaluedescriptionattribute](https://developer.apple.com/documentation/applicationservices/kaxvaluedescriptionattribute)
    var valueDescription: String? {
        get throws {
            try original.attribute(.valueDescription)
        }
    }

    /// 角色或类型, 表示此辅助功能对象的类型(例如，AXButton).
    /// 该字符串仅用于识别目的, 无需本地化. 所有辅助功能对象必须包含此属性.
    /// - seeAlso: [Roles](https://developer.apple.com/documentation/appkit/nsaccessibility/role)
    /// - seeAlso: [kaxroleattribute](https://developer.apple.com/documentation/applicationservices/kaxroleattribute)
    var role: AccessibilityRole {
        do {
            return try original.requiredAttribute(.role)
        } catch {
            logger.error("获取角色失败: \(error.localizedDescription)")
            return .unknown
        }
    }

    /// 对元素角色的本地化、易于人类理解的描述，例如"单选按钮"。
    /// 原始属性值为 `NSString` 类型。
    /// - seeAlso: [roleDescription](https://developer.apple.com/documentation/appkit/nsaccessibility/attribute/1530857-roledescription)
    /// - seeAlso: [kaxroledescriptionattribute](https://developer.apple.com/documentation/applicationservices/kaxroledescriptionattribute)
    var roleDescription: String? {
        get throws {
            try original.attribute(.roleDescription)
        }
    }

    var subrole: AccessibilitySubrole {
        get throws {
            try original.requiredAttribute(.subrole)
        }
    }

    var title: String? {
        get throws {
            try original.attribute(.title)
        }
    }

    var label: String? {
        get throws {
            try original.attribute(.label)
        }
    }

    var position: CGPoint? {
        get throws {
            try original.attribute(.position)
        }
    }

    /// 一个包含辅助功能对象的数组, 表示此应用程序的窗口.
    /// 建议所有应用程序级别的辅助功能对象使用此属性.
    internal var windows: [Self] {
        get throws {
            try original.requiredAttribute(.windows)
        }
    }

    var size: CGSize? {
        original.attribute(.size)
    }

    var topLevelElement: Self? {
        original.attribute(.topLevelUIElement)
    }

    var parent: Self {
        get throws {
            try original.requiredAttribute(.parent)
        }
    }

    // MARK: 没有文档的属性

    var frame: CGRect? {
        get throws {
            try original.attribute(.frame)
        }
    }
}

// MARK: - 元素定位

public extension AccessibilityElement {
    func find(_ condition: (AccessibilityElement) -> Bool) -> AccessibilityElement? {
        if condition(self) {
            return self
        }
        guard let children = try? children else {
            return nil
        }
        for child in children {
            if let element = child.find(condition) {
                return element
            }
        }
        return nil
    }
}

// MARK: - 动作

extension AccessibilityElement {
    /// 模拟单击操作, 例如点击按钮.
    public func perform(_ action: AccessibilityAction) -> Bool {
        let result = AXUIElementPerformAction(original, action.rawValue as CFString)
        return result == .success
    }

    /// 获取当前元素某个操作的描述
    /// - Parameter action: 操作
    /// - Returns: 操作描述
    /// - seeAlso: [AXUIElementCopyActionDescription](https://developer.apple.com/documentation/applicationservices/1462075-axuielementcopyactiondescription)
    func actionDescription(_ action: AccessibilityAction) throws -> String? {
        var description: CFString?
        let error = AXUIElementCopyActionDescription(original, action.rawValue as CFString, &description)

        if error == .actionUnsupported || error == .noValue { return nil }
        guard error == .success else { throw AccessibilityError.error(error) }

        return description as String?
    }

    /// 获取当前元素支持的所有操作
    /// - Returns: 操作数组
    /// - seeAlso: [AXUIElementCopyActionNames](https://developer.apple.com/documentation/applicationservices/1459475-axuielementcopyattributenames)
    func actions() throws -> [AccessibilityAction] {
        var actions: CFArray?
        let error = AXUIElementCopyActionNames(original, &actions)

        if error == .attributeUnsupported || error == .noValue { return [] }
        guard error == .success else { throw AccessibilityError.error(error) }
        guard let actions = actions as? [String] else { return [] }

        return actions.map {
            if let action = AccessibilityAction(rawValue: $0) {
                return action
            }

            logger.error("未知操作: \($0)")
            return .unknown
        }
    }

    public func setValue(value: String) -> Bool {
        let result = AXUIElementSetAttributeValue(
            original,
            kAXValueAttribute as CFString,
            value as CFTypeRef
        )

        return result == .success
    }
}
