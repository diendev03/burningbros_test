abstract class ProductListEvent {}

class GetProductList extends ProductListEvent {
  final bool? isRefresh;
  final String searchText;
  GetProductList({this.isRefresh, this.searchText = ""});
}

class ToggleFavorite extends ProductListEvent {
  final int productId;

  ToggleFavorite({required this.productId});
}
