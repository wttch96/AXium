//
//  AccessibilityElementAttribute.swift
//  AXium
//
//  Created by Wttch on 2024/11/10.
//
import ApplicationServices

/// 辅助功能属性键, 对原始键进行了包装, 使其可以指定键对应值的类型.
/// 不使用 enum 是因为 enum 无法指定关联值的类型(如果使用 `Any`则和手动转换无异).
public struct AccessibilityAttributeKey<O, T> {
    /// 属性键名称
    let key: String
    /// 原始类型, 未转换前类型
    let originalType: O.Type
    /// 转换后类型
    let convertedType: T.Type
    /// 转换函数
    let convertFunc: (O) -> T?
    /// 默认值
    let defaultValue: T?
    
    init(key: String, convertFunc: @escaping (O) -> T?, defaultValue: T? = nil) {
        self.key = key
        self.originalType = O.self
        self.convertedType = T.self
        self.convertFunc = convertFunc
        self.defaultValue = defaultValue
    }

    init(key: String) where O == T {
        self.init(key: key) { $0 }
    }
}

// MARK: 原始属性

private typealias OriginalAttribute<O> = AccessibilityAttributeKey<O, O>



extension OriginalAttribute<[Any]> {
    static var allowedValues: Self {
        .init(key: kAXAllowedValuesAttribute)
    }
}

/// 原始数据是 `NSNumber` 类型但表征 `Bool` 的属性.
/// 数据可能保存的是 `NSNumber` 类型或者 `Bool` 都可以获取到值, 文档中说这些属性是 `NSNubmer` 类型的, 暂且这么处理.
extension AccessibilityAttributeKey<NSNumber, Bool> {
    init(key: String) {
        self.init(key: key) { $0.boolValue }
    }

    static var enabled: Self {
        .init(key: kAXEnabledAttribute)
    }

    static var hidden: Self {
        .init(key: kAXHiddenAttribute)
    }

    static var focused: Self {
        .init(key: kAXFocusedAttribute)
    }
}

// MARK: UIElement 属性

extension AccessibilityAttributeKey<[AXUIElement], [AccessibilityElement]> {
    static var windows: Self {
        .init(key: kAXWindowsAttribute) {
            $0.map(AccessibilityElement.init)
        }
    }

    /// 一个包含辅助功能对象的数组, 表示此辅助功能对象的子对象.
    /// - seeAlso: [kaxchildrenattribute](https://developer.apple.com/documentation/applicationservices/kaxchildrenattribute)
    static var children: Self {
        .init(key: kAXChildrenAttribute) {
            $0.map(AccessibilityElement.init)
        }
    }
}

public extension AccessibilityAttributeKey<AXUIElement, AccessibilityElement> {
    private init(key: String) {
        self.init(key: key, convertFunc: AccessibilityElement.init)
    }

    static var parent: Self {
        .init(key: kAXParentAttribute)
    }

    static var focusedUIElement: Self {
        .init(key: kAXFocusedUIElementAttribute)
    }

    static var topLevelUIElement: Self {
        .init(key: kAXTopLevelUIElementAttribute)
    }
}

// MARK: 原始字符串属性

typealias StringAttribute = AccessibilityAttributeKey<NSString, String>

extension StringAttribute {
    init(key: String) {
        self.init(key: key) { $0 as String }
    }

    static var description: Self {
        .init(key: kAXDescriptionAttribute)
    }

    static var title: Self {
        .init(key: kAXTitleAttribute)
    }
    
    static var label: Self {
        .init(key: kAXLabelValueAttribute)
    }

    static var help: Self {
        .init(key: kAXHelpAttribute)
    }

    static var roleDescription: Self {
        .init(key: kAXRoleDescriptionAttribute)
    }

    static var valueDescription: Self {
        .init(key: kAXValueDescriptionAttribute)
    }

    static var identifier: Self {
        .init(key: kAXIdentifierAttribute)
    }
}

// MARK: 可转换字符串属性

fileprivate typealias NSStringAttribute<T> = AccessibilityAttributeKey<NSString, T>

fileprivate typealias ConvertibleStringAttribute<T> = AccessibilityAttributeKey<String, T>

fileprivate typealias ConvertibleStringAttributeWithRawValue<T: RawRepresentable> = AccessibilityAttributeKey<String, T>

extension ConvertibleStringAttributeWithRawValue<AccessibilityRole> {
    static var role: Self {
        .init(key: kAXRoleAttribute, convertFunc: {
            if let role: T = .init(rawValue: $0) {
                return role
            }
            AXium.logger.warning("Unknown AXUIElement role: \($0)")
            return .unknown
        }, defaultValue: .unknown)
    }
}

extension ConvertibleStringAttributeWithRawValue<AccessibilitySubrole> {
    static var subrole: Self {
        .init(key: kAXSubroleAttribute, convertFunc: {
            if let subrole: T = .init(rawValue: $0) {
                return subrole
            }

            AXium.logger.warning("Unknown AXUIElement subrole: \($0)")
            return .unknown
        })
    }
}

// MARK: 基于 `NSValue` 的属性

typealias ValueAttribute<T> = AccessibilityAttributeKey<AXValue, T>

extension ValueAttribute where O: AXValue {
    init(key: String) {
        self.init(key: key) { value in
            var result: AnyObject?
            let type: AXValueType = AXValueGetType(value)
            // 使用 UnsafeMutablePointer 临时存储结果
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value, type, pointer)
                assert(success, "Failed to get \(T.self) from AXValue")
            }
            return result as? T
        }
    }

    /// TODO: 根据类型来获取值
    ///
    static var value: Self {
        .init(key: kAXValueAttribute, convertFunc: { value in
            var result: AnyObject?
            let type: AXValueType = AXValueGetType(value)
            // 使用 UnsafeMutablePointer 临时存储结果
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value, type, pointer)
                guard success else {
                    print("Failed to get \(T.self) from AXValue")
                    return
                }
            }
            return result as? T
        })
    }
}

public extension ValueAttribute<CGPoint> {
    static var position: Self {
        .init(key: kAXPositionAttribute) { value in
            var result: CGPoint = .zero
            let type: AXValueType = AXValueGetType(value)
            // 使用 UnsafeMutablePointer 临时存储结果
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value, type, pointer)
                assert(success, "Failed to get \(T.self) from AXValue")
            }
            return result
        }
    }
}

extension ValueAttribute<CGSize> {
    static var size: Self {
        .init(key: kAXSizeAttribute) { value in
            var result: CGSize = .zero
            let type: AXValueType = AXValueGetType(value)
            // 使用 UnsafeMutablePointer 临时存储结果
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value, type, pointer)
                assert(success, "Failed to get \(T.self) from AXValue")
            }
            return result
        }
    }
}

extension ValueAttribute<CGRect> {
    static var frame: Self {
        .init(key: "AXFrame") { value in
            var result: CGRect = .zero
            let type: AXValueType = AXValueGetType(value)
            // 使用 UnsafeMutablePointer 临时存储结果
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value, type, pointer)
                assert(success, "Failed to get \(T.self) from AXValue")
            }
            return result
        }
    }
}
