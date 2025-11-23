import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class UserTokenPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserTokenPage({super.key, this.user});

  @override
  State<UserTokenPage> createState() => _UserTokenPageState();
}

class _UserTokenPageState extends State<UserTokenPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String formatRupiah(String value) {
    if (value.isEmpty) return "";
    final number = int.parse(value.replaceAll(".", ""));
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => "${m[1]}.",
    );
  }

  Future<void> buyToken() async {
    if (_amountController.text.isEmpty) {
      showSnack("Masukkan jumlah token!");
      return;
    }

    final rawAmount = _amountController.text.replaceAll(".", "");
    final amount = int.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      showSnack("Jumlah token tidak valid!");
      return;
    }

    if (widget.user?["id"] == null) {
      showSnack("User tidak valid, silakan login ulang.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(ApiConfig.buyTokenUrl());

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.user!["id"],
          "amount": amount,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        showSnack("🔥 Token berhasil dibeli!", success: true);
        _amountController.clear();
      } else {
        showSnack("Gagal membeli token (${response.statusCode})");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnack("Error: $e");
    }
  }

  void showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.electric_bolt, color: Colors.blue, size: 80),
              const SizedBox(height: 15),

              const Text(
                "Pembelian Token",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Isi jumlah token dalam rupiah.\nTransaksi langsung tercatat otomatis.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newValue = formatRupiah(
                          value.replaceAll(".", ""),
                        );
                        _amountController.value = TextEditingValue(
                          text: newValue,
                          selection: TextSelection.collapsed(
                            offset: newValue.length,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Jumlah Token (Rp)",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.payments),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : buyToken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Beli Token",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}