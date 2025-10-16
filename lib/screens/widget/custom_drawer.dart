import 'package:emi_calculator/screens/emi/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:  Color(0xFF1E1E1E),
      // Use a Column so we can pin the footer at the bottom.
      child: SafeArea(
        child: Column(
          children: [
            // Expanded ListView for scrollable menu content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                   SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          "EMI Calculator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "CALCULATOR",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ListTile(
                    leading:  Icon(Icons.history, color: Colors.white),
                    title:  Text("History", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Get.back();
                      Get.to(() => HistoryScreen());
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "SYSTEM",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ListTile(
                    leading:  Icon(Icons.share, color: Colors.white),
                    title:  Text("Tell a Friend", style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading:  Icon(Icons.star_rate, color: Colors.white),
                    title:  Text("Rate This App", style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),

                  // Add any other list tiles here...
                   SizedBox(height: 24), // spacing before footer
                ],
              ),
            ),

            // Footer area: version + optional small text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: FutureBuilder<PackageInfo>(
                future: _getPackageInfo(),
                builder: (context, snapshot) {
                  String versionText = "Version unknown";
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final info = snapshot.data!;
                    versionText = "v${info.version} (${info.buildNumber})";
                  }
                  print('snapshot: ${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}');
                  // Optionally show company/app copyright on a second line:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Divider(color: Colors.grey),
                       SizedBox(height: 8),
                      Text(
                        versionText,
                        style:  TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                       SizedBox(height: 4),
                      // const Text(
                      //   "© 2025 YourCompany",
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
