// ignore_for_file: deprecated_member_use, unused_import

import 'dart:async';

import 'package:burningbros_test/blocs/product/product_list_bloc.dart';
import 'package:burningbros_test/blocs/product/product_list_event.dart';
import 'package:burningbros_test/blocs/product/product_list_state.dart';
import 'package:burningbros_test/data/hive_config.dart';
import 'package:burningbros_test/models/product_response.dart';
import 'package:burningbros_test/utils/app_res.dart';
import 'package:burningbros_test/utils/custom_widget.dart';
import 'package:burningbros_test/utils/enum.dart';
import 'package:burningbros_test/utils/style_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with AutomaticKeepAliveClientMixin {
  late final ProductListBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _bloc = ProductListBloc()..add(GetProductList());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _bloc.add(GetProductList());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 45,
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _bloc.add(
                        GetProductList(searchText: value, isRefresh: true),
                      );
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Search...",
                    labelStyle:
                        _searchController.text.isNotEmpty
                            ? const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            )
                            : const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 5,
                    ),
                    suffixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey,
                    ),
                    focusedBorder: inputBorder(Colors.teal),
                    enabledBorder: inputBorder(Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();
                _bloc.add(GetProductList(isRefresh: true));
              },
              child: Builder(
                builder: (context) {
                  if (state.loadStatus == LoadStatus.loading && !state.isLoadingMore) {
                    return const Center(
                      child: SpinKitCircle(color: Colors.indigoAccent),
                    );
                  }

                  if (state.loadStatus == LoadStatus.failure) {
                    // Hiển thị lỗi, có nút retry
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.errorMessage?.toString() ?? "Unknown error"),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 30,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                _bloc.add(GetProductList(isRefresh: true));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.loadStatus == LoadStatus.noData) {
                    return const Center(
                      child: Text("No products available"),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 5 / 7,
                          ),
                          cacheExtent: 1000, // cache vừa phải tránh tốn bộ nhớ
                          itemCount: state.productList.length,
                          itemBuilder: (context, index) {
                            final product = state.productList[index];
                            return productItem(
                              key: ValueKey(product.id),
                              product: product,
                              isFavorite: state.favoriteIds.contains(product.id),
                              toggleFavorite: () => _bloc.add(ToggleFavorite(productId: product.id)),
                            );
                          },
                        ),
                      ),

                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: SpinKitCircle(color: Colors.indigoAccent),
                        ),

                      if (state.loadStatus == LoadStatus.endReached)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("You have reached the end of the products"),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget productItem({
    Key? key,
    required Product product,
    required bool isFavorite,
    required VoidCallback toggleFavorite,
  }) {
    final hasDiscount = product.discountPercentage > 0;
    final salePrice = product.price * (1 - product.discountPercentage / 100);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: CustomImageNetwork(url: product.images.first)),
          const SizedBox(height: 10),
          Text(
            product.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              if (hasDiscount)
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 14,
                  ),
                ),
              if (hasDiscount) const Spacer(),
              Text(
                "\$${hasDiscount ? salePrice.toStringAsFixed(2) : product.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating,
                itemBuilder:
                    (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16.0,
                direction: Axis.horizontal,
              ),
              const Spacer(),
              GestureDetector(
                onTap: toggleFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
