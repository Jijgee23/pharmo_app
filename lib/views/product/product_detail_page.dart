import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/application.dart';

class ProductDetail extends StatefulWidget {
  final Product prod;
  const ProductDetail({super.key, required this.prod});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic> det = {};
  List<File> images = [];
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await _getProductDetail(),
    );
  }

  Future<void> _getProductDetail() async {
    try {
      LoadingService.show();
      final r = await api(Api.get, 'products/${widget.prod.id}/');

      if (r == null) {
        messageError('Сертертэй холбоглож чадсангүй, түр хүлээнэ үү!');
        return;
      }

      if (r.statusCode == 200) {
        final data = convertData(r);
        setState(() => det = data);
      }
    } catch (e) {
      messageError('Алдаа гарлаа: $e');
    } finally {
      LoadingService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BasketProvider, HomeProvider>(
      builder: (context, basket, home, child) {
        final isNotPharma = !Authenticator.security!.isPharmacist;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar with Image
                _buildSliverAppBar(isNotPharma, home),

                // Content
                SliverToBoxAdapter(
                  child: det.isEmpty
                      ? _buildLoadingState()
                      : Column(
                          children: [
                            // Product Info Card
                            _buildProductInfoCard(),

                            const SizedBox(height: 12),

                            // Details Card
                            _buildDetailsCard(),

                            const SizedBox(height: 12),

                            // Price Card
                            _buildPriceCard(),

                            const SizedBox(height: 12),

                            // Image Management (for non-pharma)
                            if (isNotPharma) ...[
                              if (isNotPharma) _buildImageManagementCard(home),
                              const SizedBox(height: 80),
                            ] else
                              const SizedBox(height: 80),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Bottom Add to Cart Button
          bottomNavigationBar: _buildBottomBar(basket),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isNotPharma, HomeProvider home) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width * 0.7,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: grey300),
        icon: Icon(
          Icons.chevron_left_rounded,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: CartIcon.forAppBar(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: det.isEmpty
            ? Container(color: Colors.grey.shade200)
            : _buildImageCarousel(home, isNotPharma),
      ),
    );
  }

  Widget _buildImageCarousel(HomeProvider home, bool isNotPharma) {
    if (det.containsKey('images') && det['images'] is List) {
      final pictures = det['images'] as List;

      if (pictures.isEmpty) {
        return _buildPlaceholderImage();
      }

      return Stack(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            items: pictures.map((p) {
              return Stack(
                children: [
                  _buildNetworkImage('${dotenv.env['IMAGE_URL']}$p'),

                  // // Delete button for non-pharma users
                  // if (isNotPharma)
                  //   Positioned(
                  //     bottom: 16,
                  //     right: 16,
                  //     child: Material(
                  //       color: Colors.red,
                  //       borderRadius: BorderRadius.circular(20),
                  //       child: InkWell(
                  //         onTap: () => _deleteImage(home, p['id']),
                  //         borderRadius: BorderRadius.circular(20),
                  //         child: Container(
                  //           padding: const EdgeInsets.all(8),
                  //           child: const Icon(
                  //             Icons.delete_outline,
                  //             color: Colors.white,
                  //             size: 20,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              );
            }).toList(),
            options: CarouselOptions(
              viewportFraction: 1.0,
              autoPlay: pictures.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) {
                setState(() => _currentImageIndex = index);
              },
            ),
          ),

          // Image indicators
          if (pictures.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pictures.asMap().entries.map((entry) {
                  return Container(
                    width: _currentImageIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    return _buildPlaceholderImage();
  }

  Widget _buildNetworkImage(String url) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Зураг байхгүй',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            widget.prod.name ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xff3F414E),
              height: 1.3,
            ),
          ),

          // Barcode
          if (widget.prod.barcode != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  SelectableText(
                    widget.prod.barcode.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final details = {
      'Барааны дуусах хугацаа': det['expDate']?.toString(),
      'Ерөнхий нэршил': det['intName']?.toString(),
      'Мастер савалгааны тоо': det['master_box_qty']?.toString(),
      'Үйлдвэрлэгч': det['vndr'] != null ? det['vndr']['name'] : null,
      'Бөөний үнэ': det['sale_price'] != null
          ? toPrice(det['sale_price'].toString())
          : null,
      'Бөөний тоо': det['sale_qty']?.toString(),
      'Хямдрал дуусах хугацаа': det['discount_expiredate']?.toString(),
    };

    // Filter out null/empty values
    final filteredDetails = details.entries
        .where((e) => e.value != null && e.value != '' && e.value != 'null')
        .toList();

    if (filteredDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Дэлгэрэнгүй мэдээлэл',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...filteredDetails.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceItem(
              label: 'Үндсэн үнэ',
              price: toPrice(widget.prod.price.toString()),
              color: Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildPriceItem(
              label: 'Бөөний үнэ',
              price: toPrice(widget.prod.salePrice.toString()),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem({
    required String label,
    required String price,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildImageManagementCard(HomeProvider home) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Зураг удирдах',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chooseImageSource,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Зураг нэмэх'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (images.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendImages(home),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Хадгалах'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Selected images preview
          if (images.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _removeImage(images[index]),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBottomBar(BasketProvider basket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _showAddToCartSheet(basket),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 22,
                color: white,
              ),
              const SizedBox(width: 12),
              const Text(
                'Сагслах',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  void _chooseImageSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Камераар авах'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Зургийн санаас сонгох'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (await Permission.camera.isDenied ||
          await Permission.storage.isDenied) {
        await Permission.camera.request();
        await Permission.storage.request();
      }

      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        if (images.length >= 5) {
          messageWarning('5 хүртэлт зураг оруулах боломжтой');
          return;
        }

        File imageFile = File(pickedFile.path);
        File compressedImage = await compressImage(imageFile);

        setState(() {
          images.add(compressedImage);
        });
      } else {
        messageWarning("Зураг сонгоно уу!");
      }
    } catch (e) {
      messageWarning("Зураг сонгох үед алдаа гарлаа!");
    }
  }

  void _removeImage(File image) {
    setState(() {
      images.remove(image);
    });
  }

  Future<void> _sendImages(HomeProvider home) async {
    try {
      LoadingService.show();
      dynamic res = await home.uploadImage(
        id: widget.prod.id,
        images: images,
      );

      message(res['message']);

      if (res['errorType'] == 0) {
        await _getProductDetail();
        home.refresh(context);
        setState(() => images.clear());
      }
    } catch (e) {
      messageError('Алдаа гарлаа');
    } finally {
      LoadingService.hide();
    }
  }

  // Future<void> _deleteImage(HomeProvider home, int id) async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Зураг устгах'),
  //       content: const Text('Энэ зургийг устгахдаа итгэлтэй байна уу?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Үгүй'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('Устгах'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm != true) return;
  //   LoadingService.run(() async {
  //     bool deleted = await home.deleteImages(
  //       id: widget.prod.id,
  //       imageID: id,
  //     );

  //     if (deleted) {
  //       await _getProductDetail();
  //       home.refresh(context);
  //     }
  //   });
  // }

  void _showAddToCartSheet(BasketProvider basket) {
    Get.bottomSheet(
      ChangeQtyPad(
        onSubmit: (v) async {
          await _addToCart(v, basket);
        },
        initValue: '',
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _addToCart(String qty, BasketProvider basket) async {
    if (qty.isEmpty || qty == 'Тоо ширхэг') {
      message('Тоон утга оруулна уу!');
      return;
    }

    final quantity = parseDouble(qty);
    if (quantity <= 0) {
      message('0 ба түүгээс бага байж болохгүй!');
      return;
    }

    try {
      Navigator.pop(context);
      LoadingService.show();

      await basket.addProduct(
        widget.prod.id,
        widget.prod.name!,
        quantity,
      );

      Navigator.pop(context);
    } catch (e) {
      message('Алдаа гарлаа');
    } finally {
      LoadingService.hide();
    }
  }
}
