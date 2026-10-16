import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech Store',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Set<int> _favoriteIds = {};

  final List<Product> products = const [
    Product(
      id: 1,
      title: 'iPhone 16',
      description: 'The latest Apple smartphone with a powerful processor, improved camera and modern design.',
      image: 'https://picsum.photos/seed/iphone/600/400',
      price: 799,
      category: 'Smartphone',
    ),
    Product(
      id: 2,
      title: 'MacBook Air',
      description: 'Lightweight and powerful laptop suitable for study, work and creative projects.',
      image: 'https://picsum.photos/seed/macbook/600/400',
      price: 1099,
      category: 'Laptop',
    ),
    Product(
      id: 3,
      title: 'AirPods Pro',
      description: 'Wireless headphones with active noise cancellation and high quality sound.',
      image: 'https://picsum.photos/seed/airpods/600/400',
      price: 249,
      category: 'Headphones',
    ),
    Product(
      id: 4,
      title: 'Apple Watch',
      description: 'Smart watch for fitness tracking, notifications and everyday activities.',
      image: 'https://picsum.photos/seed/watch/600/400',
      price: 399,
      category: 'Smart Watch',
    ),
  ];

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteIds.contains(product.id)) {
        _favoriteIds.remove(product.id);
      } else {
        _favoriteIds.add(product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = products
        .where((p) => _favoriteIds.contains(p.id))
        .toList();

    final List<Widget> screens = [
      FeedScreen(
        products: products,
        favoriteIds: _favoriteIds,
        onFavoriteChanged: _toggleFavorite,
      ),

      FavoritesScreen(
        products: favoriteProducts,
        favoriteIds: _favoriteIds,
        onFavoriteChanged: _toggleFavorite,
      ),

      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Tech Feed'
              : _selectedIndex == 1
              ? 'Favorites'
              : 'Profile',
        ),
      ),

      body: IndexedStack(index: _selectedIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  final List<Product> products;
  final Set<int> favoriteIds;
  final Function(Product) onFavoriteChanged;

  const FeedScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        final isFavorite = favoriteIds.contains(product.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    product: product,
                    isFavorite: isFavorite,
                    onFavoriteChanged: onFavoriteChanged,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          product.category,
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      onFavoriteChanged(product);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Product> products;
  final Set<int> favoriteIds;
  final Function(Product) onFavoriteChanged;

  const FavoritesScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 70, color: Colors.grey),
            SizedBox(height: 15),
            Text('No favorite products yet', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),

            title: Text(product.title),

            subtitle: Text('\$${product.price.toStringAsFixed(0)}'),

            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                onFavoriteChanged(product);
              },
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    product: product,
                    isFavorite: favoriteIds.contains(product.id),
                    onFavoriteChanged: onFavoriteChanged,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final Function(Product) onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();

    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Chip(label: Text(product.category)),

                  const SizedBox(height: 15),

                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onFavoriteChanged(product);

                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(
                        isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 55)),

        const SizedBox(height: 16),

        const Center(
          child: Text(
            'Adlan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        const Center(
          child: Text('Flutter Student', style: TextStyle(color: Colors.grey)),
        ),

        const SizedBox(height: 30),

        const Divider(),

        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Receive app notifications'),
          value: notifications,
          onChanged: (value) {
            setState(() {
              notifications = value;
            });
          },
        ),

        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Enable dark appearance'),
          value: darkMode,
          onChanged: (value) {
            setState(() {
              darkMode = value;
            });
          },
        ),

        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About'),
          subtitle: Text('Homework Assignment #7'),
        ),
      ],
    );
  }
}
