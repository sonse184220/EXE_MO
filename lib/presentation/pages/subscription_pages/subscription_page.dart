import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/subscription/subscription_model.dart';
import 'package:inner_child_app/domain/usecases/payment_usecase.dart';
import 'package:inner_child_app/domain/usecases/subscription_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  late final SubscriptionUsecase _subscriptionUsecase;
  late final PaymentUsecase _paymentUsecase; // Add payment usecase

  List<SubscriptionModel> subscriptions = [];
  SubscriptionModel? selectedSubscription;
  bool isLoading = true;
  String? errorMessage;
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _subscriptionUsecase = ref.read(subscriptionUseCaseProvider);
    _paymentUsecase = ref.read(paymentUseCaseProvider); // Initialize payment usecase
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _subscriptionUsecase.getAllSubscriptions();
// final result = Result.success('');
      if (result.isSuccess && result.data != null) {
        setState(() {
          subscriptions = result.data!;
          // Set first subscription as default selected if available
          if (subscriptions.isNotEmpty) {
            selectedSubscription = subscriptions.first;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result.error ?? 'Failed to load subscriptions';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _handleSubscriptionPurchase() async {
    if (selectedSubscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subscription plan')),
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    try {
      final result = await _paymentUsecase.createPayment(selectedSubscription!.subscriptionId!);

      if (result.isSuccess && result.data != null) {
        // Assuming the result.data contains the payment URL
        final paymentUrl = result.data.toString();

        if (paymentUrl.isNotEmpty) {
          // Launch the QR payment URL
          await _launchPaymentUrl(paymentUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment QR opened. Complete payment to activate subscription.'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment initiated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final Uri paymentUri = Uri.parse(url);

      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(
          paymentUri,
          mode: LaunchMode.externalApplication, // Opens in external browser/app
        );
      } else {
        // Fallback: try to launch in web view
        await launchUrl(
          paymentUri,
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open payment page: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

//   Future<void> _handleSubscriptionPurchase() async {
//     if (selectedSubscription == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a subscription plan')),
//       );
//       return;
//     }
//
//     setState(() {
//       isProcessingPayment = true;
//     });
//
//     try {
//       // final result = await _paymentUsecase.processPayment(selectedSubscription!.subscriptionId);
// final result = Result.success('data');
//       if (result.isSuccess) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Payment successful! Subscription activated.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Navigate back or to success page
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result.error ?? 'Payment failed. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An error occurred: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isProcessingPayment = false;
//       });
//     }
//   }

  void _showSubscriptionDetails(SubscriptionModel subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                subscription.subscriptionType ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${subscription.subscriptionPrice.toString()}.000VND',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9BB168),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subscription.subscriptionDescription ?? 'N/A',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (subscription.purchases!.isNotEmpty) ...[
                Text(
                  'Features Included',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...?subscription.purchases?.map((purchase) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF9BB168),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          purchase.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      selectedSubscription = subscription;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F3422),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Select This Plan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Subscription',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubscriptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/subscription_icon.png',
                      height: 150,
                      width: 150,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stay in control. Track your health and elevate your wellness!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 300, // Set height as per your layout needs
                    child: ListView.separated(
                      itemCount: subscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final subscription = subscriptions[index];
                        return SubscriptionPlanCard(
                          subscription: subscription,
                          isSelected: selectedSubscription?.subscriptionId == subscription.subscriptionId,
                          onTap: () {
                            setState(() {
                              selectedSubscription = subscription;
                            });
                          },
                          onDetailsPressed: () => _showSubscriptionDetails(subscription),
                          isRecommended: subscription.subscriptionType?.toLowerCase() == 'premium',
                        );
                      },
                    ),
                  ),

                  /// Subscription Cards (Scrollable middle section)
                  // ...subscriptions.map((subscription) => Padding(
                  //   padding: const EdgeInsets.only(bottom: 16),
                  //   child: SubscriptionPlanCard(
                  //     subscription: subscription,
                  //     isSelected: selectedSubscription?.subscriptionId ==
                  //         subscription.subscriptionId,
                  //     onTap: () {
                  //       setState(() {
                  //         selectedSubscription = subscription;
                  //       });
                  //     },
                  //     onDetailsPressed: () =>
                  //         _showSubscriptionDetails(subscription),
                  //     isRecommended: subscription.subscriptionType?.toLowerCase() ==
                  //         'premium',
                  //   ),
                  // )),

                  /// Benefits Section (scrollable with rest)
                  if (selectedSubscription != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'With ${selectedSubscription!.subscriptionType}, you can:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBenefitItem(
                      icon: Icons.track_changes_outlined,
                      text: 'Unlimited mood tracking',
                    ),
                    _buildBenefitItem(
                      icon: Icons.bookmark_add_outlined,
                      text: 'Exclusive meditation guides',
                    ),
                    _buildBenefitItem(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      text: 'Smart health monitoring',
                    ),
                    _buildBenefitItem(
                      icon: Icons.headphones_outlined,
                      text: 'Brainwave sound therapy',
                    ),
                  ],
                ],
              ),
            ),
          ),

          /// Sticky Buy Button (Always visible)
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ElevatedButton(
                onPressed: selectedSubscription == null || isProcessingPayment
                    ? null
                    : _handleSubscriptionPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F3422),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  minimumSize: const Size(0, 60),
                ),
                child: isProcessingPayment
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          selectedSubscription != null
                              ? 'Buy ${selectedSubscription!.subscriptionType} - ${selectedSubscription!.subscriptionPrice}.000VND'
                              : 'Select a subscription plan',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       title: const Text(
  //         'Subscription',
  //         style: TextStyle(fontWeight: FontWeight.w500),
  //       ),
  //       centerTitle: true,
  //       leading: IconButton(
  //         onPressed: () => Navigator.pop(context),
  //         icon: const Icon(Icons.arrow_back),
  //       ),
  //     ),
  //     body: isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : errorMessage != null
  //         ? Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             errorMessage!,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(color: Colors.red),
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: _loadSubscriptions,
  //             child: const Text('Retry'),
  //           ),
  //         ],
  //       ),
  //     )
  //         : SingleChildScrollView(
  //       padding: const EdgeInsets.only(bottom: 16),
  //       child: Column(
  //         children: [
  //           Center(
  //             child: Image.asset(
  //               'assets/images/subscription_icon.png',
  //               height: 150,
  //               width: 150,
  //             ),
  //           ),
  //           const Text(
  //             'Stay in control. Track your health and elevate your wellness!',
  //             style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 16),
  //
  //           // Dynamic subscription cards
  //           ...subscriptions.map((subscription) => Padding(
  //             padding: const EdgeInsets.only(bottom: 16),
  //             child: SubscriptionPlanCard(
  //               subscription: subscription,
  //               isSelected: selectedSubscription?.subscriptionId == subscription.subscriptionId,
  //               onTap: () {
  //                 setState(() {
  //                   selectedSubscription = subscription;
  //                 });
  //               },
  //               onDetailsPressed: () => _showSubscriptionDetails(subscription),
  //               isRecommended: subscription.subscriptionType?.toLowerCase() == 'premium',
  //             ),
  //           )),
  //
  //           const SizedBox(height: 16),
  //
  //           // Benefits section (you can customize this based on selected subscription)
  //           if (selectedSubscription != null) ...[
  //             Container(
  //               alignment: Alignment.topLeft,
  //               padding: const EdgeInsets.only(left: 30),
  //               child: Text(
  //                 'With ${selectedSubscription!.subscriptionType}, you can:',
  //                 textAlign: TextAlign.left,
  //                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             _buildBenefitItem(
  //               icon: Icons.track_changes_outlined,
  //               text: 'Unlimited mood tracking',
  //             ),
  //             _buildBenefitItem(
  //               icon: Icons.bookmark_add_outlined,
  //               text: 'Exclusive meditation guides',
  //             ),
  //             _buildBenefitItem(
  //               icon: FontAwesomeIcons.magnifyingGlass,
  //               text: 'Smart health monitoring',
  //             ),
  //             _buildBenefitItem(
  //               icon: Icons.headphones_outlined,
  //               text: 'Brainwave sound therapy',
  //             ),
  //           ],
  //
  //           // Purchase button
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             width: double.infinity,
  //             child: ConstrainedBox(
  //               constraints: const BoxConstraints(
  //                 maxWidth: 500,
  //               ),
  //               child: ElevatedButton(
  //                 onPressed: selectedSubscription == null || isProcessingPayment
  //                     ? null
  //                     : _handleSubscriptionPurchase,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF4F3422),
  //                   padding: const EdgeInsets.symmetric(vertical: 16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(64),
  //                   ),
  //                   minimumSize: const Size(0, 60),
  //                 ),
  //                 child: isProcessingPayment
  //                     ? const Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     SizedBox(
  //                       width: 20,
  //                       height: 20,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                       ),
  //                     ),
  //                     SizedBox(width: 12),
  //                     Text(
  //                       'Processing...',
  //                       style: TextStyle(color: Colors.white, fontSize: 16),
  //                     ),
  //                   ],
  //                 )
  //                     : Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(left: 16),
  //                         child: Text(
  //                           selectedSubscription != null
  //                               ? 'Buy ${selectedSubscription!.subscriptionType} - ${selectedSubscription!.subscriptionPrice}.000VND'
  //                               : 'Select a subscription plan',
  //                           style: const TextStyle(color: Colors.white, fontSize: 16),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                       ),
  //                     ),
  //                     const Padding(
  //                       padding: EdgeInsets.only(right: 16),
  //                       child: Icon(
  //                         Icons.arrow_forward_ios,
  //                         color: Colors.white,
  //                         size: 18,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDetailsPressed;
  final bool? isRecommended;

  const SubscriptionPlanCard({
    super.key,
    required this.subscription,
    required this.isSelected,
    required this.onTap,
    required this.onDetailsPressed,
    this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: screenWidth * 0.9,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF9BB168) : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(64),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Radio<bool>(
                            value: true,
                            groupValue: isSelected ? true : null,
                            onChanged: (_) => onTap(),
                            activeColor: const Color(0xFF9BB168),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subscription.subscriptionType ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${subscription.subscriptionPrice}.000VND',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // View details button
                GestureDetector(
                  onTap: onDetailsPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFF9BB168)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View subscription details',
                      style: TextStyle(
                        color: Color(0xFF9BB168),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended == true)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF9BB168),
                  borderRadius: BorderRadius.circular(128),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildBenefitItem({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(
          color: Colors.grey,
          height: 0,
          indent: 8,
          endIndent: 8,
          thickness: 1.4,
        ),
      ],
    ),
  );
}