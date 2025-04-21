import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubcriptionPageState();
}

class _SubcriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = 'VIP';
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
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/subscription_icon.png',
                height: 150,
                width: 150,
              ),
            ),
            Text(
              'Stay in control. Track your health and elevate your wellness!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SubscriptionPlanCard(
              label: 'VIP',
              price: '100.000VND',
              isSelected: selectedPlan == 'VIP',
              onTap: () {
                setState(() {
                  selectedPlan = 'VIP';
                });
              },
            ),

            const SizedBox(height: 16),

            // Premium plan card
            SubscriptionPlanCard(
              label: 'Premium',
              price: '200.000VND',
              isSelected: selectedPlan == 'Premium',
              onTap: () {
                setState(() {
                  selectedPlan = 'Premium';
                });
              },
              isRecommended: true,
            ),
            SizedBox(height: 16),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'With Premium, you can:',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 10),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500, // Maximum width on larger screens
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F3422),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64),
                    ),
                    minimumSize: const Size(0, 60), // Fixed height, flexible width
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap the text with Expanded to take up the remaining space
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Buy once, use forever 200.000VND',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
      ),
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final String label;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isRecommended;

  const SubscriptionPlanCard({
    super.key,
    required this.label,
    required this.price,
    required this.isSelected,
    required this.onTap,
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
            child: Row(
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
                        activeColor: Color(0xFF9BB168),
                      ),
                    ),

                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// Tag 'Recommended' ở sát viền container
          if (isRecommended == true)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF9BB168),
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
              color: Colors.black, // Màu của icon
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
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
