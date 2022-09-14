import SwiftUI
import SwiftUIBackports

/// Various styles for representing unordered list item bullet elements
///
///     ● Element one
///     ● Element two
///       ○ Element one
///       ○ Element two
///         ◼︎ Element one
///         ◼︎ Element two
public struct UnorderedListBulletStyle: RawRepresentable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension UnorderedListBulletStyle {
    /// Represents a filled circle bullet. By default this is used for all level-0 elements
    ///
    ///     ● Element one
    ///     ● Element two
    static var filledCircle: Self { Self(rawValue: "•") }
    
    /// Represents an outlined circle bullet. By default this is used for all level-1 elements
    ///
    ///     ● Element one
    ///     ● Element two
    static var outlineCircle: Self { Self(rawValue: "•") }
    
    /// Represents a filled square bullet. By default this is used for all elements greater than level 1
    ///
    ///     ◼︎ Element one
    ///     ◼︎ Element two
    static var square: Self { Self(rawValue: "◼︎") }
}

/// A type that applies a custom appearance to unordered bullet markdown elements
public protocol UnorderedListBulletMarkdownStyle {
    associatedtype Body: View
    /// The properties of a unordered bullet markdown element
    typealias Configuration = UnorderedListBulletMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListBulletMarkdownStyle: UnorderedListBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedListBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a unordered bullet markdown element
public struct UnorderedListBulletMarkdownConfiguration {
    struct Label: View {
        @ScaledMetric private var reservedWidth: CGFloat = 25
        let bulletStyle: UnorderedListBulletStyle
        var body: some View {
            Text("\(bulletStyle.rawValue)")
                .frame(minWidth: reservedWidth)
        }
    }

    /// An integer value representing this element's indentation level
    public let level: Int
    /// The preferred bullet style, based on the current indentation level
    ///
    ///     ● Element one
    ///     ● Element two
    ///       ○ Element one
    ///       ○ Element two
    ///         ◼︎ Element one
    ///         ◼︎ Element two
    public var preferredBulletStyle: UnorderedListBulletStyle {
        switch level {
        case 0: return .filledCircle
        case 1: return .outlineCircle
        default: return .square
        }
    }

    /// Returns a default unordered bullet markdown representation
    public var label: some View {
        Label(bulletStyle: preferredBulletStyle)
    }
}

/// An unordered bullet style that presents its bullets as `UnorderedListBulletStyle` elements, based on the elements indendation level
public struct DefaultUnorderedListBulletMarkdownStyle: UnorderedListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListBulletMarkdownStyle where Self == DefaultUnorderedListBulletMarkdownStyle {
    /// An unordered bullet style that presents its bullets as `UnorderedListBulletStyle` elements, based on the elements indendation level
    static var automatic: Self { .init() }
}

private struct UnorderedListBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyUnorderedListBulletMarkdownStyle = .init(.automatic)
}

public extension EnvironmentValues {
    /// The current unordered bullet markdown style
    var markdownUnorderedListBulletStyle: AnyUnorderedListBulletMarkdownStyle {
        get { self[UnorderedListBulletMarkdownEnvironmentKey.self] }
        set { self[UnorderedListBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for unordered bullet markdown elements
    func markdownUnorderedListBulletStyle<S>(_ style: S) -> some View where S: UnorderedListBulletMarkdownStyle {
        environment(\.markdownUnorderedListBulletStyle, .init(style))
    }
}
