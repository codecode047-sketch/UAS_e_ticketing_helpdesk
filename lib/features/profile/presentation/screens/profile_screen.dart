import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _notifPrefsProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notif_enabled') ?? true;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final role = ref.watch(roleProvider);
    final roleLabel = role == 'admin'
        ? 'Admin'
        : role == 'helpdesk'
            ? 'Helpdesk'
            : 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, ref, textColor, subtitleColor, roleLabel),
            const SizedBox(height: 8),
            _buildStatsRow(context),
            const SizedBox(height: 8),
            _buildMenuSection(context, ref, surfaceColor, textColor, subtitleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color subtitleColor,
    String roleLabel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  'A',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditProfileSheet(context, ref),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            MockData.userName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${MockData.userName.toLowerCase().replaceAll(' ', '_')}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'surya@helpdesk.com',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleBadge(roleLabel),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;
    switch (role) {
      case 'Admin':
        bgColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        break;
      case 'Helpdesk':
        bgColor = AppColors.warning.withOpacity(0.15);
        textColor = AppColors.warning;
        break;
      default:
        bgColor = AppColors.info.withOpacity(0.15);
        textColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _statItem(context, 'Total Tiket', '15'),
              _statDivider(context),
              _statItem(context, 'Aktif', '4'),
              _statDivider(context),
              _statItem(context, 'Selesai', '9'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 36,
      color: isDark ? const Color(0xFF2A2A3E) : AppColors.divider,
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: [
          _menuCard(context, ref, surfaceColor, textColor, subtitleColor),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    WidgetRef ref,
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _menuItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () => _showEditProfileSheet(context, ref),
          ),
          _menuDivider(isDark),
          _menuItem(
            context,
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            onTap: () => _showChangePasswordSheet(context, ref),
          ),
          _menuDivider(isDark),
          _menuToggle(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            ref: ref,
          ),
          _menuDivider(isDark),
          _menuItem(
            context,
            icon: Icons.language,
            title: 'Bahasa',
            trailing: 'Indonesia',
            onTap: () => _showLanguageSheet(context),
          ),
          _menuDivider(isDark),
          _menuThemeToggle(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Tema Tampilan',
            ref: ref,
          ),
          _menuDivider(isDark),
          _menuItem(
            context,
            icon: Icons.help_outline,
            title: 'Bantuan & FAQ',
            onTap: () => _showBantuanFaq(context),
          ),
          _menuDivider(isDark),
          _menuItem(
            context,
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () => _showAboutDialog(context),
          ),
          _menuDivider(isDark),
          _menuItem(
            context,
            icon: Icons.logout,
            title: 'Keluar',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? AppColors.error
            : (isDark ? Colors.white70 : AppColors.textSecondary),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? AppColors.error
              : (isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.grey : AppColors.textHint,
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey : AppColors.textHint,
            ),
      onTap: onTap,
    );
  }

  Widget _menuToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required WidgetRef ref,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifAsync = ref.watch(_notifPrefsProvider);

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: notifAsync.when(
        data: (enabled) => Switch(
          value: enabled,
          activeColor: AppColors.primary,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('notif_enabled', value);
            ref.invalidate(_notifPrefsProvider);
          },
        ),
        loading: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => Switch(
          value: true,
          activeColor: AppColors.primary,
          onChanged: null,
        ),
      ),
    );
  }

  Widget _menuThemeToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required WidgetRef ref,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: isDark ? Colors.white70 : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: themeMode == ThemeMode.dark,
        activeColor: AppColors.primary,
        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
      ),
    );
  }

  Widget _menuDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: isDark ? const Color(0xFF2A2A3E) : AppColors.divider,
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _EditProfileSheet(),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Bahasa',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.check, color: AppColors.primary),
                title: const Text('Indonesia'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.check, color: Colors.transparent),
                title: const Text('English'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBantuanFaq(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121220) : AppColors.background;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(title: const Text('Bantuan & FAQ')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _faqItem(
                'Bagaimana cara membuat tiket?',
                'Klik tombol "+" pada halaman daftar tiket, lalu isi formulir dengan judul, kategori, prioritas, dan deskripsi. Anda juga dapat menambahkan lampiran gambar maksimal 3 file.',
                textColor,
                subtitleColor,
                surfaceColor,
              ),
              const SizedBox(height: 12),
              _faqItem(
                'Bagaimana cara melacak tiket saya?',
                'Anda dapat melihat status tiket di halaman detail tiket. Status akan diperbarui secara otomatis oleh tim helpdesk.',
                textColor,
                subtitleColor,
                surfaceColor,
              ),
              const SizedBox(height: 12),
              _faqItem(
                'Apa arti status tiket?',
                'Open: Tiket baru menunggu diproses\nIn Progress: Tiket sedang dikerjakan\nClosed: Tiket telah selesai\nCancelled: Tiket dibatalkan',
                textColor,
                subtitleColor,
                surfaceColor,
              ),
              const SizedBox(height: 12),
              _faqItem(
                'Bagaimana cara menghubungi helpdesk?',
                'Anda dapat menghubungi helpdesk melalui menu tiket dengan membuat tiket baru, atau menghubungi langsung via email support@helpdesk.com',
                textColor,
                subtitleColor,
                surfaceColor,
              ),
              const SizedBox(height: 12),
              _faqItem(
                'Apakah data saya aman?',
                'Kami menjaga keamanan data Anda dengan enkripsi端-to-end dan sistem keamanan berlapis. Data Anda tidak akan dibagikan kepada pihak ketiga tanpa persetujuan.',
                textColor,
                subtitleColor,
                surfaceColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(
    String question,
    String answer,
    Color textColor,
    Color subtitleColor,
    Color surfaceColor,
  ) {
    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: subtitleColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tentang Aplikasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-Ticketing Helpdesk',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi $_appVersion',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi manajemen tiket helpdesk yang memudahkan Anda dalam melacak dan mengelola permintaan bantuan.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: subtitleColor,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRouter.login);
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Admin User');
  final _usernameController = TextEditingController(text: 'admin_user');
  final _emailController = TextEditingController(text: 'admin@helpdesk.com');
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Text(
                              'A',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            Future.delayed(
                              const Duration(milliseconds: 800),
                              () {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profil berhasil diperbarui'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ubah Password',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_showOld,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showOld ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _showOld = !_showOld),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password lama tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password baru tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            Future.delayed(
                              const Duration(milliseconds: 800),
                              () {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password berhasil diubah'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
