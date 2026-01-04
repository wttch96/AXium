//
//  AccessibilityRole.swift
//  AXium
//
//  Created by Wttch on 2024/11/12.
//

/// 描述辅助功能元素所代表的对象类型的值, 例如按钮、文本字段或滚动条
/// - seeAlso: [Roles](https://developer.apple.com/documentation/appkit/nsaccessibility/role)
public enum AccessibilityRole: String, CaseIterable {
    /// 应用程序
    case application = "AXApplication"
    case browser = "AXBrowser"
    case busyIndicator = "AXBusyIndicator"
    case button = "AXButton"
    case cell = "AXCell"
    case checkBox = "AXCheckBox"
    case colorWell = "AXColorWell"
    case column = "AXColumn"
    case comboBox = "AXComboBox"
    case disclosureTriangle = "AXDisclosureTriangle"
    case drawer = "AXDrawer"
    case grid = "AXGrid"
    case group = "AXGroup"
    case growArea = "AXGrowArea"
    case handle = "AXHandle"
    case helpTag = "AXHelpTag"
    case image = "AXImage"
    case incrementor = "AXIncrementor"
    case layoutArea = "AXLayoutArea"
    case layoutItem = "AXLayoutItem"
    case levelIndicator = "AXLevelIndicator"
    case link = "AXLink"
    case list = "AXList"
    case matte = "AXMatte"
    case menu = "AXMenu"
    case menuBar = "AXMenuBar"
    case menuBarItem = "AXMenuBarItem"
    case menuButton = "AXMenuButton"
    case menuItem = "AXMenuItem"
    case outline = "AXOutline"
    case pageRole = "AXPageRole"
    case popUpButton = "AXPopUpButton"
    case progressIndicator = "AXProgressIndicator"
    case radioButton = "AXRadioButton"
    case radioGroup = "AXRadioGroup"
    case relevanceIndicator = "AXRelevanceIndicator"
    case row = "AXRow"
    case ruler = "AXRuler"
    case rulerMarker = "AXRulerMarker"
    case scrollArea = "AXScrollArea"
    case scrollBar = "AXScrollBar"
    case sheet = "AXSheet"
    case slider = "AXSlider"
    case splitGroup = "AXSplitGroup"
    case splitter = "AXSplitter"
    case staticText = "AXStaticText"
    case systemWide = "AXSystemWide"
    case tabGroup = "AXTabGroup"
    case table = "AXTable"
    case textArea = "AXTextArea"
    case textField = "AXTextField"
    case toolbar = "AXToolbar"
    case valueIndicator = "AXValueIndicator"
    case window = "AXWindow"

    case unknown = "AXUnknown"

    // 附加
    case functionRowTopLevelElement = "AXFunctionRowTopLevelElement"

    // MARK: 未定义但是存在的

    case heading = "AXHeading"
    case webArea = "AXWebArea"
    case listMarker = "AXListMarker"
}
