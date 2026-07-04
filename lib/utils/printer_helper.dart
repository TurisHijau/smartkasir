import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected = !result;
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> printStrukBelanja({
    required String namaToko,
    required String alamatToko,
    required String noTelpToko,
    required List<Map<String, dynamic>> items,
    required double totalSemuanya,
    required double uangBayar,
    required double kembalian,
  }) async {
    if (!_isConnected) return;

    List<int> bytes = [];
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Hitung total dari items
    double calculatedTotal = items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0),
    );

    bytes += EscPos.init;

    // Header - Nama Toko
    bytes += EscPos.alignCenter;
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    bytes += _textToBytes(namaToko);
    bytes += EscPos.lineFeed;

    // Alamat & No Telp
    bytes += EscPos.textNormal;
    bytes += EscPos.boldOff;
    if (alamatToko.isNotEmpty) {
      bytes += _textToBytes(alamatToko);
      bytes += EscPos.lineFeed;
    }
    if (noTelpToko.isNotEmpty) {
      bytes += _textToBytes(noTelpToko);
      bytes += EscPos.lineFeed;
    }

    // Tanggal
    String formattedDate = DateFormat(
      'dd MMMM yyyy HH:mm',
    ).format(DateTime.now());
    bytes += _textToBytes(formattedDate);
    bytes += EscPos.lineFeed;

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Items
    bytes += EscPos.alignLeft;
    for (var item in items) {
      String name = item['name'].toString();
      String qty = item['qty'].toString();
      double price = double.tryParse(item['price'].toString()) ?? 0;
      double totalItem = double.tryParse(item['total'].toString()) ?? 0;

      // Print nama barang
      bytes += _textToBytes(name);
      bytes += EscPos.lineFeed;

      // Print qty x price dan totalnya
      String priceStr = currencyFormatter.format(price);
      String totalItemStr = currencyFormatter.format(totalItem);

      String line2Left = '${qty}x $priceStr';
      if (line2Left.length > 20) line2Left = line2Left.substring(0, 20);

      // Hitung spasi agar totalItemStr rata kanan
      int spaces = 32 - line2Left.length - totalItemStr.length;
      if (spaces < 1) spaces = 1;

      String line2 = line2Left + (' ' * spaces) + totalItemStr;
      bytes += _textToBytes(line2);
      bytes += EscPos.lineFeed;
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Total
    String totalStr = currencyFormatter.format(calculatedTotal);
    int totalSpaces = 32 - 6 - totalStr.length;
    bytes += EscPos.boldOn;
    bytes += _textToBytes(
      'TOTAL:' + (' ' * (totalSpaces > 0 ? totalSpaces : 1)) + totalStr,
    );
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;

    // Bayar
    String bayarStr = currencyFormatter.format(uangBayar);
    int bayarSpaces = 32 - 6 - bayarStr.length;
    bytes += _textToBytes(
      'BAYAR:' + (' ' * (bayarSpaces > 0 ? bayarSpaces : 1)) + bayarStr,
    );
    bytes += EscPos.lineFeed;

    // Kembali
    double calculatedKembali = uangBayar - calculatedTotal;
    String kembaliStr = currencyFormatter.format(calculatedKembali);
    int kembaliSpaces = 32 - 8 - kembaliStr.length;
    bytes += _textToBytes(
      'KEMBALI:' + (' ' * (kembaliSpaces > 0 ? kembaliSpaces : 1)) + kembaliStr,
    );
    bytes += EscPos.lineFeed;

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Footer
    bytes += EscPos.alignCenter;
    bytes += _textToBytes('Terima Kasih Atas');
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('Kunjungan Anda!');
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  List<int> _textToBytes(String text) {
    return List.from(text.codeUnits);
  }
}
