import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/articles/article_detail.dart';

class ArticleListPage extends ConsumerStatefulWidget {
  const ArticleListPage({super.key});

  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  late final ArticleUseCase _articleUseCase;
  List<ArticleModel> _articles = [];
  List<ArticleModel> _filteredArticles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Color palette
  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);

  @override
  void initState() {
    super.initState();
    _articleUseCase = ref.read(articleUseCaseProvider);
    _loadArticles();
    _searchController.addListener(_filterArticles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await _articleUseCase.getAllArticles();
      setState(() {
        _articles = articles.data!;
        _filteredArticles = _articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles =
          query.isEmpty
              ? _articles
              : _articles.where((article) {
                return article.articleName?.toLowerCase().contains(query) ??
                    false;
              }).toList();
    });
  }

  void _navigateToDetail(String articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetail(articleId: articleId),
      ),
    );
    // Navigator.pushNamed(
    //   context,
    //   '/article-detail',
    //   arguments: {'id': articleId},
    // );
  }

  Color _getCardColor(int index) {
    const colors = [raspberry, papaya, iceCream, meadow, sunshine, springSky];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'All Articles',
            style: TextStyle(
              color: raspberry,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: raspberry),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: springSky.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search articles by name...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: springSky),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: raspberry),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: springSky.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: springSky.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: springSky, width: 2),
                  ),
                ),
              ),
            ),

            // Articles Grid
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(raspberry),
                        ),
                      )
                      : _filteredArticles.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No articles found'
                                  : 'No articles match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            final cardColor = _getCardColor(index);

                            return OpenContainer(
                              transitionDuration: Duration(milliseconds: 500),
                              closedElevation: 0,
                              closedColor: Colors.transparent,
                              openElevation: 0,
                              openColor: Colors.transparent,
                              closedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              openShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              closedBuilder: (context, openContainer) {
                                return GestureDetector(
                                  onTap:
                                      article.articleId == null
                                          ? () {
                                            Notify.showFlushbar(
                                              'Cannot view article details.',
                                            );
                                          }
                                          : openContainer,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          cardColor.withOpacity(0.8),
                                          cardColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: cardColor.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Article Icon
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.article,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Article Name
                                          Expanded(
                                            child: Text(
                                              article.articleName ??
                                                  'Untitled Article',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          // Article Description
                                          if (article.articleDescription !=
                                              null)
                                            Text(
                                              article.articleDescription!,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                          const SizedBox(height: 12),

                                          // Read More Button
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    'Read',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              openBuilder:
                                  (context, _) => ArticleDetail(
                                    articleId: article.articleId!,
                                  ),
                            );
                          },
                        ),

                        // child: GridView.builder(
                        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: 2,
                        //     crossAxisSpacing: 16,
                        //     mainAxisSpacing: 16,
                        //     childAspectRatio: 0.75,
                        //   ),
                        //   itemCount: _filteredArticles.length,
                        //   itemBuilder: (context, index) {
                        //     final article = _filteredArticles[index];
                        //     final cardColor = _getCardColor(index);
                        //
                        //     return GestureDetector(
                        //       onTap: () => _navigateToDetail(article.articleId!),
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           gradient: LinearGradient(
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //             colors: [
                        //               cardColor.withOpacity(0.8),
                        //               cardColor,
                        //             ],
                        //           ),
                        //           borderRadius: BorderRadius.circular(20),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: cardColor.withOpacity(0.3),
                        //               blurRadius: 10,
                        //               offset: const Offset(0, 4),
                        //             ),
                        //           ],
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(16),
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               // Article Icon
                        //               Container(
                        //                 padding: const EdgeInsets.all(8),
                        //                 decoration: BoxDecoration(
                        //                   color: Colors.white.withOpacity(0.3),
                        //                   borderRadius: BorderRadius.circular(12),
                        //                 ),
                        //                 child: const Icon(
                        //                   Icons.article,
                        //                   color: Colors.white,
                        //                   size: 24,
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 12),
                        //
                        //               // Article Name
                        //               Expanded(
                        //                 child: Text(
                        //                   article.articleName ?? 'Untitled Article',
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontSize: 16,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                   maxLines: 3,
                        //                   overflow: TextOverflow.ellipsis,
                        //                 ),
                        //               ),
                        //
                        //               const SizedBox(height: 8),
                        //
                        //               // Article Description
                        //               if (article.articleDescription != null)
                        //                 Text(
                        //                   article.articleDescription!,
                        //                   style: TextStyle(
                        //                     color: Colors.white.withOpacity(0.9),
                        //                     fontSize: 12,
                        //                   ),
                        //                   maxLines: 2,
                        //                   overflow: TextOverflow.ellipsis,
                        //                 ),
                        //
                        //               const SizedBox(height: 12),
                        //
                        //               // Read More Button
                        //               Align(
                        //                 alignment: Alignment.centerRight,
                        //                 child: Container(
                        //                   padding: const EdgeInsets.symmetric(
                        //                     horizontal: 12,
                        //                     vertical: 6,
                        //                   ),
                        //                   decoration: BoxDecoration(
                        //                     color: Colors.white.withOpacity(0.2),
                        //                     borderRadius: BorderRadius.circular(20),
                        //                     border: Border.all(
                        //                       color: Colors.white.withOpacity(0.3),
                        //                     ),
                        //                   ),
                        //                   child: Row(
                        //                     mainAxisSize: MainAxisSize.min,
                        //                     children: const [
                        //                       Text(
                        //                         'Read',
                        //                         style: TextStyle(
                        //                           color: Colors.white,
                        //                           fontSize: 12,
                        //                           fontWeight: FontWeight.w600,
                        //                         ),
                        //                       ),
                        //                       SizedBox(width: 4),
                        //                       Icon(
                        //                         Icons.arrow_forward_ios,
                        //                         color: Colors.white,
                        //                         size: 12,
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
