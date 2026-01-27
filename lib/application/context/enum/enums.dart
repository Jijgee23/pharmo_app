enum LoadState { loading, loaded, error }

enum Api { get, post, patch, delete }

enum AuthState {
  unknown,
  loggedIn,
  notLoggedIn,
  expired,
  notSplashed,
  noConnection
}

enum Role { noUser, seller, driver, orderer, admin, repman }

enum OrderStatus { newOrder, ready, packing, payed, unpayed }

enum NetworkStatus { online, offline, hasConnectionButNotInternet }

enum Tracker { sellerTrack, driverTrack }
