import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _fetchArticle() async {
    try {
      // Simulate API call or use Dio, etc.
      final article = await _articleUseCase.getArticleById(widget.articleId);
      setState(() {
        _article = article.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      NotifyAnotherFlushBar.showFlushbar('fetch article failed: $e',isError: true);
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

  void _closeArticle() {
    setState(() {
      _isVisible = false;
    });
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      // offset: Offset(0, _isVisible ? 0 : constraints.maxHeight),
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
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        _loading
                            ? Center(child: CircularProgressIndicator())
                            : _article == null
                            ? Center(child: Text('Article not found'))
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Article detail',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: _closeArticle,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image.asset(
                                              'assets/images/article_cover.png',
                                              fit: BoxFit.cover,
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
                                                color: Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Hurray, we identified this article!',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      _article!.articleName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Row(
                                    //   children:
                                    //       article.tags.map((tag) {
                                    //         return Padding(
                                    //           padding: const EdgeInsets.only(
                                    //             right: 8.0,
                                    //           ),
                                    //           child: Chip(
                                    //             label: Text(tag),
                                    //             backgroundColor: Colors.grey[200],
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    // ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    // Text(
                                    //   'From ${widget.article.source}',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     color: Colors.grey[600],
                                    //     fontStyle: FontStyle.italic,
                                    //   ),
                                    // ),
                                    SizedBox(height: 10),
                                    Text(
                                      _article!.articleDescription,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'Read More',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    // Wrap(
                                    //   spacing: 12,
                                    //   runSpacing: 12,
                                    //   children:
                                    //       widget.article.actionTags.map((tag) {
                                    //         return Container(
                                    //           padding: EdgeInsets.symmetric(
                                    //             horizontal: 16,
                                    //             vertical: 12,
                                    //           ),
                                    //           decoration: BoxDecoration(
                                    //             color: tag.color.withOpacity(0.1),
                                    //             borderRadius: BorderRadius.circular(16),
                                    //           ),
                                    //           child: Row(
                                    //             mainAxisSize: MainAxisSize.min,
                                    //             children: [
                                    //               Icon(
                                    //                 tag.icon,
                                    //                 color: tag.color,
                                    //                 size: 20,
                                    //               ),
                                    //               SizedBox(width: 8),
                                    //               Text(
                                    //                 tag.label,
                                    //                 style: TextStyle(
                                    //                   color: tag.color,
                                    //                   fontWeight: FontWeight.w500,
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bookmark_border,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save this article',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
