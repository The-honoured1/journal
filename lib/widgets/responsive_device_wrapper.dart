import 'package:flutter/material.dart';

class ResponsiveDeviceWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveDeviceWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 500;

    if (!isDesktop) {
      return child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2DDD5),
      body: Center(
        child: Container(
          width: 395,
          height: 835,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(52),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(52),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2C2A29), width: 10),
                borderRadius: BorderRadius.circular(52),
              ),
              child: Stack(
                children: [
                  child,
                  // Dynamic island/top notch bezel simulator
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        width: 110,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  // Bottom home indicator bar simulator
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        width: 130,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2A29).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
