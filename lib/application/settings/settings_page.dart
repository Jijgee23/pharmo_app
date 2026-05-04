import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/printer/printer_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().scanDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, PrinterProvider>(
      builder: (context, settings, printer, _) => Scaffold(
        appBar: AppBar(title: const Text('Тохиргоо')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(icon: Icons.battery_5_bar_rounded, label: 'Төхөөрөмж'),
            _SettingsTile(
              icon: Icons.battery_charging_full_rounded,
              title: 'Батарейны түвшин',
              trailing: Text(
                '${settings.batteryLevel}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.print_rounded,
              label: 'Принтерийн тохиргоо',
              trailing: IconButton(
                onPressed: printer.loading ? null : printer.scanDevices,
                icon: printer.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Дахин хайх',
              ),
            ),
            if (printer.connectedDevice != null)
              _ConnectedPrinterCard(device: printer.connectedDevice!),
            const SizedBox(height: 8),
            if (!printer.loading && printer.devices.isEmpty)
              _EmptyDevices(onScan: printer.scanDevices)
            else
              ...printer.devices.map(
                (device) => _DeviceTile(
                  device: device,
                  connected: printer.connectedDevice?.macAdress == device.macAdress,
                  onTap: () => printer.connect(device),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _SectionHeader({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SettingsTile({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade600, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}

class _ConnectedPrinterCard extends StatelessWidget {
  final BluetoothInfo device;
  const _ConnectedPrinterCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_connected_rounded, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Холбогдсон принтер',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                ),
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade500,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothInfo device;
  final bool connected;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.device,
    required this.connected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connected ? Colors.green.shade300 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          Icons.print_outlined,
          color: connected ? Colors.green.shade600 : Colors.grey.shade500,
          size: 22,
        ),
        title: Text(device.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          device.macAdress,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        trailing: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: connected ? Colors.green.shade600 : AppColors.main,
          ),
          child: Text(
            connected ? 'Холбогдсон' : 'Холбох',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyDevices extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyDevices({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        spacing: 12,
        children: [
          Icon(Icons.bluetooth_disabled_rounded, size: 40, color: Colors.grey.shade400),
          Text(
            'Bluetooth принтер олдсонгүй',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          TextButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Дахин хайх'),
          ),
        ],
      ),
    );
  }
}
