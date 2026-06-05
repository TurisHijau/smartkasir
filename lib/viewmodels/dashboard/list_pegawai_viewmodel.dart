import 'package:flutter/material.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/services/user_service.dart';
import 'package:smartkasir/views/dashboard/kelola_pegawai_view.dart';

class ListPegawaiViewmodel extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool isCashier = false;
  bool isOwner = false;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';

  List<User> get employees => _filteredUsers;

  ListPegawaiViewmodel() {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _userService.getAll(),
        _authService.getProfile().catchError((_) => null),
      ]);

      _allUsers = results[0] as List<User>;
      final profile = results[1] as AuthResponse?;

      if (profile != null) {
        if (profile.user.role.name == 'CASHIER') {
          isCashier = true;
        }
        // Only OWNER can add/edit/delete employees
        if (profile.user.role.name == 'OWNER') {
          isOwner = true;
        }
      }

      _applyFilter();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((u) {
        return u.name.toLowerCase().contains(_searchQuery) ||
            u.username.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  void navigateToAddEmployee(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KelolaPegawaiView(),
      ),
    ).then((_) => loadUsers());
  }

  void navigateToEditEmployee(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KelolaPegawaiView(user: user),
      ),
    ).then((_) => loadUsers());
  }

  Future<void> deleteUser(BuildContext context, User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pegawai"),
        content: Text("Yakin ingin menghapus \"${user.name}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true && user.id != null) {
      try {
        await _userService.delete(user.id!);
        await loadUsers();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("\"${user.name}\" berhasil dihapus")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red[700]),
          );
        }
      }
    }
  }
}