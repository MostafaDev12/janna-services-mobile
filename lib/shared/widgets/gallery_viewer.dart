import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Full-screen, zoomable, swipeable image gallery.
class GalleryViewer extends StatefulWidget {
  const GalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title,
  });

  final List<String> images;
  final int initialIndex;
  final String? title;

  static Future<void> open(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GalleryViewer(
          images: images,
          initialIndex: initialIndex,
          title: title,
        ),
      ),
    );
  }

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late int _index = widget.initialIndex;
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title != null
              ? '${widget.title} (${_index + 1}/${widget.images.length})'
              : '${_index + 1} / ${widget.images.length}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      body: PhotoViewGallery.builder(
        pageController: _controller,
        itemCount: widget.images.length,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        onPageChanged: (i) => setState(() => _index = i),
        builder: (_, i) => PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(widget.images[i]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.images[i]),
        ),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
