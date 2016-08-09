#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Brick
import Sugar

/// A class protocol that is used for all components inside of SpotsController
public protocol Spotable: class {
  
  /// The default kind to fall back to if the view model kind does not exist when trying to display the spotable item
  static var defaultKind: StringConvertible { get }

  /// A SpotsDelegate object
  weak var spotsDelegate: SpotsDelegate? { get set }

  /// The index of a Spotable object
  var index: Int { get set }
  /// The component of a Spotable object
  var component: Component { get set }
  /// A configuration closure for a SpotConfigurable object
  var configure: (SpotConfigurable -> Void)? { get set }
  /// A cache for a Spotable object
  var stateCache: SpotCache? { get }
  /// A SpotAdapter
  var adapter: SpotAdapter? { get }

  #if os(OSX)
    var responder: NSResponder { get }
    var nextResponder: NSResponder? { get set }
  #endif

  /**
   Initialize a Spotable object with a Component

   - Parameter component: The component that the Spotable object should be initialized with
   - Returns: A Spotable object
   */
  init(component: Component)

  /// Setup Spotable object with size
  func setup(size: CGSize)
  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete a collection of view models from a Spotable object
  func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Return a Spotable object as a UIScrollView
  func render() -> ScrollView
  /// Layout Spotable object using size
  func layout(size: CGSize)
  /// Perform internal preperations for a Spotable object
  func register()
  /// Scroll to view model using predicate
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat

  func spotHeight() -> CGFloat
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize

  func dequeueView(identifier: String, indexPath: NSIndexPath) -> View?
  func identifier(index: Int) -> String?

  #if os(OSX)
  func deselect()
  #endif
}

public extension Spotable {

  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }
  /// Delete a collection of view models from a Spotable object
  func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }
}

public extension Spotable {

  /// A collection of view models
  var items: [ViewModel] {
    set(items) { component.items = items }
    get { return component.items }
  }

  /// Return a dictionary representation of Spotable object
  public var dictionary: JSONDictionary {
    get {
      return component.dictionary
    }
  }

  /**
   Prepare items in component
  */
  func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
    }
  }

  /**
   - Parameter index: The index of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(index: Int) -> ViewModel? {
    guard index < component.items.count else { return nil }
    return component.items[index]
  }

  /**
   - Parameter indexPath: The indexPath of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(indexPath: NSIndexPath) -> ViewModel? {
    #if os(OSX)
      return item(indexPath.item)
    #else
      return item(indexPath.row)
    #endif
  }

  /**
   - Returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    return component.items.reduce(0, combine: { $0 + $1.size.height })
  }

  /**
   Refreshes the indexes of all items within the component
   */
  public func refreshIndexes() {
    items.enumerate().forEach {
      items[$0.index].index = $0.index
    }
  }

  /**
   Reloads spot only if it has changes
   - Parameter items: An array of view models
   - Parameter animated: Perform reload animation
   */

  /**
   Reloads a spot only if it changes

   - Parameter items:     A collection of ViewModels
   - Parameter animation: The animation that should be used (only works for Listable objects)
   */
  public func reloadIfNeeded(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic) {
    guard !(self.items == items) else {
      cache()
      return
    }

    self.items = items
    reload(nil, withAnimation: animation) {
      self.cache()
    }
  }

  /**
   Reload Spotable object with JSON if contents changed

   - Parameter json:      A JSON dictionary
   - Parameter animation: The animation that should be used (only works for Listable objects)
   */
  public func reloadIfNeeded(json: JSONDictionary, withAnimation animation: SpotsAnimation = .Automatic) {
    let newComponent = Component(json)

    guard component != newComponent else { cache(); return }

    component = newComponent
    reload(nil, withAnimation: animation) { [weak self] in
      self?.cache()
    }
  }

  /**
   Caches the current state of the spot
   */
  public func cache() {
    stateCache?.save(dictionary)
  }

  /**
   TODO: We should probably have a look at this method? Seems silly to always return 0.0 😁

   - Parameter includeElement: A filter predicate to find a view model
   - Returns: Always returns 0.0
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    return 0.0
  }

  /**
   Prepares a view model item before being used by the UI component

   - Parameter index: The index of the view model
   */
  public func configureItem(index: Int, usesViewSize: Bool = false) {
    guard let item = item(index) else { return }

    var viewModel = item
    viewModel.index = index

    guard let view = dequeueView(viewModel) as? SpotConfigurable else { return }

    view.configure(&viewModel)

    if usesViewSize {
      if viewModel.size.height == 0 {
        viewModel.size.height = view.size.height
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = view.size.width
      }
    }

    if index < component.items.count {
      component.items[index] = viewModel
    }
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return render().frame.size
  }

  func dequeueView(item: ViewModel) -> View? {
    let indexPath: NSIndexPath

    #if os(OSX)
      indexPath = NSIndexPath(forItem: item.index, inSection: 0)
    #else
      indexPath = NSIndexPath(forRow: item.index, inSection: 0)
    #endif

    return dequeueView(item.kind, indexPath: indexPath)
  }

  func identifier(indexPath: NSIndexPath) -> String? {
    #if os(OSX)
      return identifier(index: indexPath.item)
    #else
      return identifier(indexPath.row)
    #endif
  }

  func registerAndPrepare() {
    register()
    prepareItems()
  }
}
