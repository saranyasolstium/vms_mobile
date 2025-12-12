import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParkingSlipPreviewPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ParkingSlipPreviewPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dfIn = DateFormat('yyyy-MM-dd HH:mm:ss'); // API format
    final dfOut = DateFormat('dd MMM yyyy hh:mm a'); // display

    String vehicleNo = data['vehicle_no'] ?? '-';

    String purpose = data['visit_reason']?['purpose'] ?? '-';
    final other = (data['other'] ?? '').toString();
    if (other.isNotEmpty) {
      purpose = purpose.isNotEmpty ? '$purpose - $other' : other;
    }

    String entryDisplay = '-';
    final inStr = (data['in_time'] ?? '').toString().trim();
    if (inStr.isNotEmpty) {
      try {
        final inDt = dfIn.parseStrict(inStr);
        entryDisplay = dfOut.format(inDt);
      } catch (_) {
        // ignore parse error, keep '-'
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Slip Preview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFEEEEEE),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              Image.asset(
                'assets/images/skywood_logo.png',
                width: 140,
                height: 0,
                fit: BoxFit.cover,
              ),

              // TITLE
              const Text(
                "Visitor's Parking Slip",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // BODY (same info as ESC/POS)
              _ticketRow('Vehicle No', vehicleNo),
              const SizedBox(height: 4),
              _ticketRow('Purpose', purpose),
              const SizedBox(height: 4),
              _ticketRow('Entry', entryDisplay),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Please display this slip on the Dashboard.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
