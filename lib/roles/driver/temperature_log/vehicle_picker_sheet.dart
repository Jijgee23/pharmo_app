import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

/// Picks or changes today's vehicle.
Future<void> showVehiclePickerSheet() =>
    Get.bottomSheet(const VehiclePickerSheet(), isScrollControlled: true);

class VehiclePickerSheet extends StatefulWidget {
  const VehiclePickerSheet({super.key});

  @override
  State<VehiclePickerSheet> createState() => _VehiclePickerSheetState();
}

class _VehiclePickerSheetState extends State<VehiclePickerSheet> {
  int? _vehicleId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _vehicleId = context.read<TemperatureLogProvider>().today?.log?.vehicleId;
  }

  Future<void> _save() async {
    final logs = context.read<TemperatureLogProvider>();
    final id = _vehicleId;
    if (id == null) {
      messageWarning('Машинаа сонгоно уу!');
      return;
    }
    if (id == logs.today?.log?.vehicleId) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    final picked = await logs.pickVehicle(id);
    if (!mounted) return;
    if (picked) {
      messageComplete('Машин сонгогдлоо');
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TemperatureLogProvider>().today;
    final log = today?.log;
    final hasReadings = log?.start != null || log?.end != null;
    return AppSheet(
      title: 'Өнөөдрийн машин',
      subtitle: 'Түгээлтэд явах машинаа сонгоно уу',
      closable: !_saving,
      footer: SheetButton(
        label: 'Сонгох',
        icon: Icons.check_rounded,
        busy: _saving,
        onPressed: today == null || today.vehicles.isEmpty ? null : _save,
      ),
      children: [
        if (hasReadings) ...[
          const SheetNote(
            Icons.info_outline_rounded,
            'Машин солиход өнөөдрийн хэмжилтүүдийг шинэ машины хязгаараар дахин шалгана.',
          ),
          const SizedBox(height: 12),
        ],
        VehiclePicker(
          vehicles: today?.vehicles ?? [],
          selectedId: _vehicleId,
          onSelected: (v) => setState(() => _vehicleId = v.id),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// The supplier's [vehicles] to pick one from, [selectedId] marked; a search
/// box once there are more than a handful.
class VehiclePicker extends StatefulWidget {
  final List<LogVehicle> vehicles;
  final int? selectedId;
  final ValueChanged<LogVehicle> onSelected;

  const VehiclePicker({
    super.key,
    required this.vehicles,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<VehiclePicker> createState() => _VehiclePickerState();
}

class _VehiclePickerState extends State<VehiclePicker> {
  // The list gets a search box past this many vehicles.
  static const _searchFrom = 6;

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.vehicles;
    if (vehicles.isEmpty) {
      return const SheetNote(
        Icons.no_crash_outlined,
        'Танай байгууллагад машин бүртгэгдээгүй байна. Админд хандана уу.',
      );
    }
    // Plates are stored upper-cased without spaces.
    final text = _query.replaceAll(' ', '').toUpperCase();
    final shown = text.isEmpty ? vehicles : vehicles.where((v) => v.plate.contains(text)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vehicles.length > _searchFrom) ...[
          _searchField(),
          const SizedBox(height: 10),
        ],
        if (shown.isEmpty)
          SheetNote(Icons.search_off_rounded, '"${_query.trim()}" дугаартай машин алга.')
        else
          for (final v in shown)
            _VehicleTile(
              vehicle: v,
              selected: v.id == widget.selectedId,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onSelected(v);
              },
            ),
      ],
    );
  }

  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Улсын дугаар хайх',
        hintStyle: TextStyle(color: grey400, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: grey500, size: 20),
        isDense: true,
        filled: true,
        fillColor: grey100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final LogVehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleTile({required this.vehicle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Durations.short4,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primary.withValues(alpha: 0.08) : grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? primary : Colors.transparent, width: 1.6),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: selected ? primary : primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: selected ? white : primary.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        vehicle.plate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      Text(vehicle.limits.label, style: TextStyle(fontSize: 12, color: grey500)),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Durations.short4,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? primary : Colors.transparent,
                    border: Border.all(color: selected ? primary : grey400, width: 2),
                  ),
                  child: selected ? const Icon(Icons.check_rounded, size: 14, color: white) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
