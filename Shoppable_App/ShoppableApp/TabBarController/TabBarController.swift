/*
    TabBarController.swift
    ShoppableApp

    Created on 1/19/23.
 
    A TabBarController with 2 child Navigation Controllers
*/

import UIKit


// Describes a product object's type
typealias ProductDictionary = [String:AnyObject]


class TabBarController: UITabBarController {

  // MARK: - Properties ******
  
  // UserDefaults
  let itemsInShoppingCartArrayKey = "itemsInShoppingCartArray"
  
  // Tab Bar
  var currentTabIndex = 0
  
  // Image Loader
  var imageLoader: ImageDownloader?
  
  // Products
  var productCollections: [ProductCollection] = []
  
  // ShoppingCart
  var itemsInShoppingCartIDs: [ProductDictionary] = []
  var itemsInShoppingCartCount = 0
  
  
  // MARK: - View Controller's Life Cycle ******
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TabBar's Delegate
    delegate = self
    
    // Image Loader
    imageLoader = ImageDownloader()
    
    // Load JSON Data
    loadJsonData()
    
    // Get the items in the Shopping Cart from UserDefaults
    getItemsInShoppingCart()
    
    // Become the Children's delegate
    setupChildrenDelegates()
    
    // Setup the TabBar items title and style
    customizeTabBarItems()
    
    // Set up the Cart TabBar item badge
    setupInitialCartTabBarItemBadge()
    
  }

}


// MARK: - Setup UI ******

extension TabBarController {
  
  // Setup the TabBar items title and style
  func customizeTabBarItems() {
    
    let tabBarItems = tabBar.items
    tabBarItems?[0].title = NSLocalizedString("Collections",
                                              comment: "Collections TabBar item title")
    tabBarItems?[1].title = NSLocalizedString("Cart",
                                              comment: "Cart TabBar item title")
    tabBar.tintColor = .label
    tabBar.unselectedItemTintColor = .systemGray3
  }
  
  /*
   Set the Shopping Cart's tabBar item badge if the customer
   has products on their Shopping Cart.
   
   The color of the badge will remain its default RED color
   to give the customer a sense of urgency to go to the
   Shopping Cart and buy.
   */
  func setupCartTabBarItemBadge(with count: Int) {
    let cartTabItem = tabBar.items?.last
    cartTabItem?.badgeValue = count > 0 ? "\(count)" : nil
  }
  
  // Cart's TabBarItem badge on app launch
  func setupInitialCartTabBarItemBadge() {
    let itemsInCartCount = getItemCountInShoppingCart(from: itemsInShoppingCartIDs)
    itemsInShoppingCartCount = itemsInCartCount
    setupCartTabBarItemBadge(with: itemsInCartCount)
  }
  
}


// MARK: - Setup Children Delegates ******

/*
 Become the delegate of children's top controllers
 */
extension TabBarController {
  
  func setupChildrenDelegates() {
    setupProductOverviewVcDelegate()
    setupCartVcDelegate()
  }
  
  // Child 1
  func setupProductOverviewVcDelegate() {
    
    if
      let navController = getChildNavigationController(with: 0),
      let rootController = navController.topViewController as? ProductOverviewViewController
    {
      navController.navigationBar.prefersLargeTitles = true
      rootController.productOverviewViewControllerDelegate = self
      rootController.productCollections = productCollections
      rootController.imageLoader = imageLoader
    }
  }
  
  // Child 2
  func setupCartVcDelegate() {
    
    if
      let navController = getChildNavigationController(with: 1),
      let rootController = navController.topViewController as? CartViewController
    {
      rootController.cartViewControllerDelegate = self
      rootController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
      rootController.productCollections = productCollections
      rootController.imageLoader = imageLoader
    }
  }
  
  // Get a child NavigationController
  func getChildNavigationController(with index: Int) -> UINavigationController? {
    
    if let navController = children[index] as? UINavigationController {
      return navController
    }
    return nil
  }
  
}


// MARK: - Load the Products data

extension TabBarController {
  
  // Load the data from the products.json file
  func loadJsonData() {
    let products = JsonLoader.returnProductCollectionTypeArray(from: "products")
    productCollections = products
  }
  
  // Get itemsInShoppingCart array from UserDefaults if it exists
  func getItemsInShoppingCart() {
    if let itemsInShoppingCartArray = UserDefaults.standard.array(forKey: itemsInShoppingCartArrayKey) as? [ProductDictionary] {
      itemsInShoppingCartIDs = itemsInShoppingCartArray
    }
  }
  
}
