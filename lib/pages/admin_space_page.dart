import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/app_car.dart';
import '../models/app_user.dart';
import '../services/app_database.dart';
import '../widgets/hover_tap.dart';

class AdminSpacePage extends StatefulWidget {
  const AdminSpacePage({super.key});

  @override
  State<AdminSpacePage> createState() => _AdminSpacePageState();
}

class _AdminSpacePageState extends State<AdminSpacePage> {
  Future<List<AppUser>>? _usersFuture;
  Future<List<AppCar>>? _carsFuture;

  String _buildImageSource(PlatformFile file) {
    final path = file.path?.trim();
    if (path != null && path.isNotEmpty) {
      return path;
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return '';
    }

    final extension = (file.extension ?? '').toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'bmp' => 'image/bmp',
      _ => 'image/png',
    };

    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<void> _openUserDialog({required String role}) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final zipController = TextEditingController();
    final countryController = TextEditingController(text: 'Tunisia');
    final passwordController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(role == 'admin' ? 'Add Admin' : 'Add Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Phone (8 digits)'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: zipController,
                decoration: const InputDecoration(labelText: 'ZIP Code'),
              ),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password (min 6)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final fullName = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();
              final address = addressController.text.trim();
              final city = cityController.text.trim();
              final zip = zipController.text.trim();
              final country = countryController.text.trim();
              final password = passwordController.text;

              if (fullName.isEmpty ||
                  email.isEmpty ||
                  !email.contains('@') ||
                  !RegExp(r'^\d{8}$').hasMatch(phone) ||
                  address.isEmpty ||
                  city.isEmpty ||
                  zip.isEmpty ||
                  country.isEmpty ||
                  password.length < 6) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all user fields correctly.')),
                );
                return;
              }

              final exists = await AppDatabase.instance.emailExists(email);
              if (exists) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A user with this email already exists.')),
                );
                return;
              }

              final user = AppUser(
                fullName: fullName,
                email: email,
                phone: phone,
                address: address,
                city: city,
                zipCode: zip,
                country: country,
                role: role,
                joinedAt: DateTime.now(),
              );

              await AppDatabase.instance.createUser(user, password);

              if (!mounted) return;
              Navigator.pop(context);
              _reload();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    countryController.dispose();
    passwordController.dispose();
  }

  Future<void> _setUserRole(AppUser user, String role) async {
    if (user.id == null) return;
    if (user.role.toLowerCase() == role.toLowerCase()) return;

    if (user.role.toLowerCase() == 'admin' && role.toLowerCase() != 'admin') {
      final adminCount = await AppDatabase.instance.getAdminCount();
      if (adminCount <= 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least one admin must remain.')),
        );
        return;
      }
    }

    await AppDatabase.instance.updateUserRole(userId: user.id!, role: role);
    _reload();
  }

  Future<void> _removeUser(AppUser user) async {
    if (user.id == null) return;

    if (user.role.toLowerCase() == 'admin') {
      final adminCount = await AppDatabase.instance.getAdminCount();
      if (adminCount <= 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot remove the last admin.')),
        );
        return;
      }
    }

    await AppDatabase.instance.deleteUser(user.id!);
    _reload();
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _usersFuture = AppDatabase.instance.getAllUsers();
      _carsFuture = AppDatabase.instance.getCars();
    });
  }

  Future<void> _openCarDialog({AppCar? car}) async {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearModelController = TextEditingController(text: car?.yearModel ?? '');
    final kilometrageController = TextEditingController(
      text: car?.kilometrage?.toString() ?? '',
    );
    final motorisationController = TextEditingController(text: car?.motorisation ?? '');
    final colorController = TextEditingController(text: car?.color ?? '');
    final consumptionController = TextEditingController(
      text: car?.consumptionPer100km?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: car != null ? car.price.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: car != null ? car.stock.toString() : '',
    );
    final descController = TextEditingController(text: car?.description ?? '');
    String? selectedImagePath = car?.imageUrl;
    bool featured = car?.isFeatured ?? false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(car == null ? 'Add Car' : 'Edit Car'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    TextField(
                      controller: yearModelController,
                      decoration: const InputDecoration(labelText: 'Year Model'),
                    ),
                    TextField(
                      controller: kilometrageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kilometrage (km)'),
                    ),
                    TextField(
                      controller: motorisationController,
                      decoration: const InputDecoration(labelText: 'Motorisation'),
                    ),
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    TextField(
                      controller: consumptionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Consumption / 100km'),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedImagePath == null || selectedImagePath!.trim().isEmpty
                            ? 'No photo selected'
                            : 'Photo selected',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                          );
                          if (result != null) {
                            final imageSource = _buildImageSource(result.files.single);
                            if (imageSource.isEmpty) return;
                            setLocalState(() {
                              selectedImagePath = imageSource;
                            });
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach Car Photo (from PC)'),
                      ),
                    ),
                    if (selectedImagePath != null && selectedImagePath!.trim().isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setLocalState(() => selectedImagePath = null),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove Photo'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured'),
                      value: featured,
                      onChanged: (value) => setLocalState(() => featured = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text.trim());
                    final stock = int.tryParse(stockController.text.trim());
                    final kilometrageText = kilometrageController.text.trim();
                    final kilometrage = kilometrageText.isEmpty
                        ? null
                        : int.tryParse(kilometrageText);
                    final consumptionText = consumptionController.text.trim();
                    final consumption = consumptionText.isEmpty
                        ? null
                        : double.tryParse(consumptionText);

                    if (brandController.text.trim().isEmpty ||
                        modelController.text.trim().isEmpty ||
                        price == null ||
                        stock == null ||
                        (kilometrageText.isNotEmpty && kilometrage == null) ||
                        (consumptionText.isNotEmpty && consumption == null) ||
                        descController.text.trim().isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all car fields correctly.')),
                      );
                      return;
                    }

                    final input = AppCar(
                      id: car?.id,
                      brand: brandController.text.trim(),
                      model: modelController.text.trim(),
                        yearModel: yearModelController.text.trim().isEmpty
                          ? null
                          : yearModelController.text.trim(),
                        kilometrage: kilometrage,
                        motorisation: motorisationController.text.trim().isEmpty
                          ? null
                          : motorisationController.text.trim(),
                        color: colorController.text.trim().isEmpty
                          ? null
                          : colorController.text.trim(),
                        consumptionPer100km: consumption,
                      price: price,
                      stock: stock,
                      description: descController.text.trim(),
                      isFeatured: featured,
                        imageUrl: selectedImagePath,
                    );

                    if (car == null) {
                      await AppDatabase.instance.addCar(input);
                    } else {
                      await AppDatabase.instance.updateCar(input);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    _reload();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    brandController.dispose();
    modelController.dispose();
    yearModelController.dispose();
    kilometrageController.dispose();
    motorisationController.dispose();
    colorController.dispose();
    consumptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text('Admin Space'),
          backgroundColor: const Color(0xFF020617),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Clients', icon: Icon(Icons.people_outline)),
              Tab(text: 'Cars', icon: Icon(Icons.directions_car_outlined)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openCarDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Car'),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<AppUser>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                final adminCount =
                    users.where((u) => u.role.toLowerCase() == 'admin').length;
                final clientCount = users.length - adminCount;
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              title: 'Total Users',
                              value: '${users.length}',
                              icon: Icons.group_outlined,
                              color: const Color(0xFF113B7A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _metricCard(
                              title: 'Admins',
                              value: '$adminCount',
                              icon: Icons.admin_panel_settings_outlined,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _metricCard(
                              title: 'Clients',
                              value: '$clientCount',
                              icon: Icons.person_outline,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: HoverTap(
                              onTap: () => _openUserDialog(role: 'client'),
                              borderRadius: BorderRadius.circular(12),
                              hoverColor: Colors.white.withOpacity(0.06),
                              child: OutlinedButton.icon(
                                onPressed: () => _openUserDialog(role: 'client'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF020617),
                                  side: BorderSide.none,
                                ),
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('Add Client'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: HoverTap(
                              onTap: () => _openUserDialog(role: 'admin'),
                              borderRadius: BorderRadius.circular(12),
                              hoverColor: Colors.white.withOpacity(0.06),
                              child: ElevatedButton.icon(
                                onPressed: () => _openUserDialog(role: 'admin'),
                                icon: const Icon(Icons.admin_panel_settings),
                                label: const Text('Add Admin'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isAdmin = user.role.toLowerCase() == 'admin';
                          return HoverTap(
                            borderRadius: BorderRadius.circular(14),
                            hoverColor: Colors.white.withOpacity(0.06),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(child: Text(user.initials)),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(user.fullName)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAdmin
                                            ? Colors.deepPurple.withOpacity(0.12)
                                            : Colors.teal.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        isAdmin ? 'Admin' : 'Client',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isAdmin ? Colors.deepPurple : Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text('${user.email}\n${user.city}, ${user.country}'),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'make_admin') {
                                      await _setUserRole(user, 'admin');
                                    } else if (value == 'make_client') {
                                      await _setUserRole(user, 'client');
                                    } else if (value == 'remove') {
                                      await _removeUser(user);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!isAdmin)
                                      const PopupMenuItem(
                                        value: 'make_admin',
                                        child: Text('Make Admin'),
                                      ),
                                    if (isAdmin)
                                      const PopupMenuItem(
                                        value: 'make_client',
                                        child: Text('Make Client'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove User'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            FutureBuilder<List<AppCar>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cars = snapshot.data!;
                if (cars.isEmpty) {
                  return const Center(child: Text('No cars in database.'));
                }
                final featuredCount = cars.where((c) => c.isFeatured).length;
                final inStockCount = cars.where((c) => c.stock > 0).length;
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            title: 'Total Cars',
                            value: '${cars.length}',
                            icon: Icons.directions_car_outlined,
                            color: const Color(0xFF113B7A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            title: 'In Stock',
                            value: '$inStockCount',
                            icon: Icons.inventory_2_outlined,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            title: 'Featured',
                            value: '$featuredCount',
                            icon: Icons.workspace_premium_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...cars.map((car) {
                      return HoverTap(
                        borderRadius: BorderRadius.circular(14),
                        hoverColor: Colors.white.withOpacity(0.06),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text('${car.brand} ${car.model}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('\$${car.price.toStringAsFixed(0)} • Stock: ${car.stock}'),
                                    if (car.isFeatured)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Featured',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if ((car.yearModel ?? '').trim().isNotEmpty)
                                      'Year: ${car.yearModel}',
                                    if (car.kilometrage != null)
                                      'Km: ${car.kilometrage}',
                                    if ((car.motorisation ?? '').trim().isNotEmpty)
                                      'Motor: ${car.motorisation}',
                                    if ((car.color ?? '').trim().isNotEmpty)
                                      'Color: ${car.color}',
                                    if (car.consumptionPer100km != null)
                                      'Cons: ${car.consumptionPer100km!.toStringAsFixed(1)}L/100',
                                  ].join(' • '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openCarDialog(car: car),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    if (car.id == null) return;
                                    await AppDatabase.instance.deleteCar(car.id!);
                                    _reload();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
