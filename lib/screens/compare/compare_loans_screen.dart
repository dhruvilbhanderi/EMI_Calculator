import 'package:flutter/material.dart';

class CompareLoansScreen extends StatelessWidget {

  const CompareLoansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Compare Loans',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon:  Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('LOAN 1', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInputField('Loan 1 amount'),
                      const SizedBox(height: 16),
                      _buildInputField('Interest %'),
                      const SizedBox(height: 16),
                      _buildInputField('Ex: 1  Years | Months'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: List.generate(3, (index) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 74),
                          child: Icon(Icons.arrow_forward, color: Colors.blue),
                        ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('LOAN 2', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInputField('Loan 2 amount'),
                      const SizedBox(height: 16),
                      _buildInputField('Interest %'),
                      const SizedBox(height: 16),
                      _buildInputField('Ex: 1  Years | Months'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Calculate', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}