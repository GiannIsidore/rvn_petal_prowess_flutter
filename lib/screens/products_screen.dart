import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import 'order_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🌸 Our Products')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            children: [
              Text(
                'Choose Your Flowers',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              SizedBox(height: 50),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 0.8,
                children: [
                  ProductCard(
                    name: 'Assorted Flowers',
                    description: 'A mix of fresh seasonal flowers.',
                    imagePath:
                        'assets/images/3.jpg/ea84b9ab-446b-4b1e-abe3-27e4186a3e2d.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderScreen(productName: 'Assorted Flowers'),
                        ),
                      );
                    },
                  ),
                  ProductCard(
                    name: 'Custom Bouquet',
                    description: 'Create your own bouquet design.',
                    imagePath:
                        'assets/images/product1/bg.jpg/0cc187c2-6772-4547-91b1-aa609094f5d3.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderScreen(productName: 'Custom Bouquet'),
                        ),
                      );
                    },
                  ),
                  ProductCard(
                    name: 'Custom Pot',
                    description: 'Personalized potted plants.',
                    imagePath:
                        'assets/images/2.jpg/3aace3da-ad32-4722-b170-79fdcac9ac75.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderScreen(productName: 'Custom Pot'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text('Back to Home'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
