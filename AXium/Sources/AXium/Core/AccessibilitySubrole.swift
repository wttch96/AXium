//
//  AccessibilitySubrole.swift
//  AXium
//
//  Created by Wttch on 2024/11/12.
//

/// 描述辅助功能元素所代表的专用对象子类型的值.
/// - seeAlso: [SubRoles](https://developer.apple.com/documentation/appkit/nsaccessibility/subrole)
public enum AccessibilitySubrole: String {
    /// 窗口的关闭按钮
    case closeButton = "AXCloseButton"

    case collectionListSubrole = "AXCollectionList"

    /// 表示按列表组织的内容, 但该内容不在列表控件或表格视图中.
    case contentList = "AXContentList"

    /// 递减箭头(滚动条中的向下箭头).
    case decrementArrow = "AXDecrementArrow"

    /// 递减页面(滚动条滚动轨道中的递减区域).
    case decrementPage = "AXDecrementPage"

    /// 网页中内容列表
    case definitionList = "AXDefinitionList"

    /// 描述的列表
    case descriptionList = "AXDescriptionList"

    /// 对话框
    case dialog = "AXDialog"

    /// 浮动窗口
    case floatingWindow = "AXFloatingWindow"

    /// 窗口全屏按钮
    case fullScreenButton = "AXFullScreenButton"

    /// 递增箭头(滚动条中的向上箭头).
    case incrementArrow = "AXIncrementArrow"

    /// 递增页面(滚动条滚动轨道中的递增区域).
    case incrementPage = "AXIncrementPage"

    /// 窗口的最小化按钮
    case minimizeButton = "AXMinimizeButton"

    /// outline row
    case outlineRow = "AXOutlineRow"

    /// 评级指示器
    case ratingIndicator = "AXRatingIndicator"

    /// 搜索框
    case searchField = "AXSearchField"

    case sectionListSubrole = "AXSectionList"

    /// 安全文本字段
    case secureTextField = "AXSecureTextField"

    /// table 或者 outline row 的排序按钮
    case sortButton = "AXSortButton"

    /// 标准窗口
    case standardWindow = "AXStandardWindow"

    /// 开关
    case `switch` = "AXSwitch"

    /// 系统对话框(一个系统生成的对话框, 浮动在最上层, 无论哪个应用程序处于前端)
    case systemDialog = "AXSystemDialog"

    /// 系统浮动窗口(一个系统生成的面板)
    case systemFloatingWindow = "AXSystemFloatingWindow"

    case tabButtonSubrole = "AXTabButton"

    /// 表格行
    case tableRow

    /// 文本附件
    case textAttachment = "AXTextAttachment"

    /// 文本链接
    case textLink = "AXTextLink"

    /// 时间线
    case timeline = "AXTimeline"

    /// 切换按钮
    case toggle = "AXToggle"

    /// 窗体工具栏按钮
    case toolbarButton = "AXToolbarButton"

    /// 窗体缩放按钮
    case zoomButton = "AXZoomButton"

    case unknown = "AXUnknown"
    
    // MARK: 未知但存在
    case segment = "AXSegment"
    case landmarkNavigation = "AXLandmarkNavigation"
    case landmarkMain = "AXLandmarkMain"
    case emptyGroup = "AXEmptyGroup"
}
