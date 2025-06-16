import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';

class ArticleDetail extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetail({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends ConsumerState<ArticleDetail>
    with SingleTickerProviderStateMixin {
  late final ArticleUseCase _articleUseCase;

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  ArticleModel? _article;
  bool _loading = true;
  bool _hasError = false;

  // Theme colors
  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);

  Future<void> _fetchArticle() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final article = await _articleUseCase.getArticleById(widget.articleId);
      setState(() {
        _article = article.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      Notify.showFlushbar('fetch article failed: $e', isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Start with a flow-up animation
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();
    });

    _articleUseCase = ref.read(articleUseCaseProvider);
    _fetchArticle();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openArticleUrl() async {
    if (_article?.articleUrl != null && _article!.articleUrl!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(_article!.articleUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          Notify.showFlushbar('Cannot open article link', isError: true);
        }
      } catch (e) {
        Notify.showFlushbar('Invalid article link: $e', isError: true);
      }
    } else {
      Notify.showFlushbar('No article link available', isError: true);
    }
  }

  void _closeArticle() {
    setState(() {
      _isVisible = false;
    });
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Widget _buildImageContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: sunshine.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/article_cover.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageErrorWidget();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: meadow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: meadow,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Hurray, we identified this article!',
                    style: TextStyle(
                      fontSize: 12,
                      color: meadow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: iceCream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: raspberry.withOpacity(0.7),
          ),
          SizedBox(height: 8),
          Text(
            'Image failed to load',
            style: TextStyle(
              color: raspberry.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap to retry',
            style: TextStyle(
              color: raspberry.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: raspberry,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load article',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: raspberry,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchArticle,
            style: ElevatedButton.styleFrom(
              backgroundColor: springSky,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text('Retry'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sunshine.withOpacity(0.05),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        constraints.maxHeight * (1 - _animation.value),
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: springSky.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _loading
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(springSky),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading article...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                        : _hasError
                        ? _buildErrorState()
                        : _article == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: raspberry.withOpacity(0.7),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Article not found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: raspberry,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Article detail',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: springSky,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  color: raspberry,
                                  onPressed: _closeArticle,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                // Tap to retry if image fails to load
                                setState(() {});
                              },
                              child: _buildImageContainer(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              _article?.articleName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: raspberry,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: springSky,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _article?.articleDescription ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _openArticleUrl,
                                  child: Text(
                                    'Read More',
                                    style: TextStyle(
                                      color: springSky,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _openArticleUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: meadow,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: meadow.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_browser_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Read on browser',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ArticleObject {
  final String title;
  final String source;
  final String description;
  final List<String> tags;
  final String category;
  final List<TagItem> actionTags;
  final String readMoreText;

  ArticleObject({
    required this.title,
    required this.source,
    required this.description,
    required this.tags,
    required this.category,
    required this.actionTags,
    this.readMoreText = "Read more",
  });
}

class TagItem {
  final String label;
  final IconData icon;
  final Color color;

  TagItem({required this.label, required this.icon, required this.color});
}