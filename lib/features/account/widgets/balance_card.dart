import 'package:flutter/material.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/skeleton.dart';

/// Primary Account Balance Card with masked balance by default and eye toggle (Feature F2)
class BalanceCard extends StatefulWidget {
  final int? balancePaise;
  final String? primaryVpa;
  final String? maskedNumber;
  final bool isLoading;

  const BalanceCard({
    super.key,
    this.balancePaise,
    this.primaryVpa,
    this.maskedNumber,
    this.isLoading = false,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.maskedNumber ?? 'Primary Account',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.primaryVpa ?? 'paylite',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (widget.isLoading)
                const Skeleton(height: 32, width: 140)
              else
                Expanded(
                  child: Text(
                    _isBalanceVisible
                        ? Money(widget.balancePaise ?? 0).format()
                        : '••••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              IconButton(
                tooltip: _isBalanceVisible ? 'Hide Balance' : 'Show Balance',
                icon: Icon(
                  _isBalanceVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
