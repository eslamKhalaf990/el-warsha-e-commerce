import 'package:flutter/material.dart';

class DefaultFooter extends StatelessWidget {
  const DefaultFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('سياسة الخصوصية', () {}),
              _buildDot(),
              _buildFooterLink('شروط الاستخدام', () {}),
              _buildDot(),
              _buildFooterLink('تواصل معنا', () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} الورشة. جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'تسوق آمن 100%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        '•',
        style: TextStyle(color: Colors.grey[300]),
      ),
    );
  }
}
