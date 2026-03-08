import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final String productName;

  const OrderScreen({super.key, required this.productName});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _selectedSize = 'Small';
  String _deliveryMethod = 'Pickup';
  int _quantity = 1;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _selectedFlowers = [];
  LatLng? _selectedLocation;
  MapController? _mapController;
  double _deliveryDistance = 0;
  double _deliveryCharge = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (_deliveryMethod == 'Pickup') {
      _addressController.text =
          '${AppConstants.shopAddress}\nStore Hours: ${AppConstants.shopHours}';
    }
  }

  double get _unitPrice {
    return AppConstants.productPrices[widget.productName]?[_selectedSize] ?? 0;
  }

  double get _totalPrice {
    return (_unitPrice * _quantity) + _deliveryCharge;
  }

  void _updatePrice() {
    setState(() {
      if (_selectedLocation != null && _deliveryMethod == 'Delivery') {
        _deliveryDistance = _calculateDistance(
          AppConstants.shopLatitude,
          AppConstants.shopLongitude,
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
        _deliveryCharge = (_deliveryDistance * AppConstants.deliveryRatePerKm)
            .roundToDouble();
      } else {
        _deliveryDistance = 0;
        _deliveryCharge = 0;
      }
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        (0.5 - 0.5 * cos(dLat)) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * (0.5 - 0.5 * cos(dLon));
    return R * 2 * asin(sqrt(a));
  }

  double _toRad(double deg) => deg * 3.14159265359 / 180;

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (!mounted) return;
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _mapController?.move(_selectedLocation!, 15);
    });
    _updatePrice();
  }

  void _clearMapSelection() {
    setState(() {
      _selectedLocation = null;
      _addressController.clear();
    });
    _updatePrice();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select date and time')));
      return;
    }

    if (_deliveryMethod == 'Delivery' && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select delivery location on map')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final order = Order(
      product: widget.productName,
      size: _selectedSize,
      quantity: _quantity,
      customerName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      deliveryMethod: _deliveryMethod,
      address: _addressController.text.trim(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
      deliveryDistanceKm: _deliveryDistance,
      deliveryCharge: _deliveryCharge,
      unitPrice: _unitPrice,
      totalPrice: _totalPrice,
      dateNeeded: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      timeNeeded:
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      flowerPreferences: _selectedFlowers.isEmpty
          ? '-'
          : _selectedFlowers.join(', '),
      notes: _notesController.text.trim().isEmpty
          ? '-'
          : _notesController.text.trim(),
    );

    final result = await _apiService.createOrder(order);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (result['status'] == 1) {
      _showThankYouDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: ${result['message']}')),
      );
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌸', style: TextStyle(fontSize: 50)),
            SizedBox(height: 16),
            Text(
              'Thank you for your order!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Your order has been successfully submitted. We will notify you via email or phone once your order has been approved or rejected.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place Your Order')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '🌼 ${widget.productName}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  _buildReadOnlyField('Product', widget.productName),

                  _buildDropdown('Size', _selectedSize, AppConstants.sizes, (
                    val,
                  ) {
                    setState(() => _selectedSize = val!);
                    _updatePrice();
                  }),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Price: ₱${_unitPrice.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildDropdown(
                    'Delivery Method',
                    _deliveryMethod,
                    ['Pickup', 'Delivery'],
                    (val) {
                      setState(() {
                        _deliveryMethod = val!;
                        if (_deliveryMethod == 'Pickup') {
                          _addressController.text =
                              '${AppConstants.shopAddress}\nStore Hours: ${AppConstants.shopHours}';
                          _selectedLocation = null;
                        } else {
                          _addressController.clear();
                        }
                      });
                      _updatePrice();
                    },
                  ),

                  if (_deliveryMethod == 'Delivery') ...[
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 2,
                      validator: (val) =>
                          val!.isEmpty ? 'Address is required' : null,
                    ),
                    SizedBox(height: 12),

                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              AppConstants.shopLatitude,
                              AppConstants.shopLongitude,
                            ),
                            initialZoom: 13,
                            onTap: (tapPosition, point) {
                              setState(() => _selectedLocation = point);
                              _updatePrice();
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            if (_selectedLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedLocation!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '📍 Tap on the map to pin your delivery location',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: Icon(Icons.my_location),
                            label: Text('Use My Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearMapSelection,
                            icon: Icon(Icons.clear),
                            label: Text('Clear Pin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_deliveryDistance > 0)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.lightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Distance: ${_deliveryDistance.toStringAsFixed(2)} km | Delivery Charge: ₱${_deliveryCharge.toStringAsFixed(0)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                  ] else
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Pickup Address',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      readOnly: true,
                    ),
                  SizedBox(height: 16),

                  _buildTextField('Full Name', _nameController, Icons.person),
                  _buildTextField(
                    'Email',
                    _emailController,
                    Icons.email,
                    isEmail: true,
                  ),
                  _buildTextField(
                    'Phone',
                    _phoneController,
                    Icons.phone,
                    isPhone: true,
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date of ${_deliveryMethod == 'Delivery' ? 'Delivery' : 'Pickup'}',
                    ),
                    subtitle: Text(
                      _selectedDate != null
                          ? DateFormat('MMMM dd, yyyy').format(_selectedDate!)
                          : 'Select date',
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppConstants.primaryColor,
                    ),
                    onTap: _selectDate,
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Time of ${_deliveryMethod == 'Delivery' ? 'Delivery' : 'Pickup'}',
                    ),
                    subtitle: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select time',
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: AppConstants.primaryColor,
                    ),
                    onTap: _selectTime,
                  ),

                  if (widget.productName != 'Assorted Flowers') ...[
                    SizedBox(height: 8),
                    Text(
                      'Flower Preferences',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.flowerPreferences.map((flower) {
                        return FilterChip(
                          label: Text(flower),
                          selected: _selectedFlowers.contains(flower),
                          selectedColor: AppConstants.lightGreen,
                          checkmarkColor: AppConstants.primaryColor,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFlowers.add(flower);
                              } else {
                                _selectedFlowers.remove(flower);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 8),

                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        color: AppConstants.primaryColor,
                      ),
                      Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () => setState(() => _quantity++),
                        color: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Total: ₱${_totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Submit Order'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
            ? TextInputType.phone
            : TextInputType.text,
        validator: (val) {
          if (val == null || val.isEmpty) return '$label is required';
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
