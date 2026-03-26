import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/cleansl_button.dart';

class EditProfilePage extends StatefulWidget {
  // Pass the current details in so the form starts pre-filled
  final String currentName;
  final String currentPhone;
  final String currentEmail;
  final String currentAddress;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentAddress,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to hold the text typed by the user
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController; // Usually kept empty for security

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
    _addressController = TextEditingController(text: widget.currentAddress);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Create a map of the updated data
      final updatedData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
      };
      
      // Pop this page off the stack and pass the new data back to the ProfilePage
      Navigator.pop(context, updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- EDIT PROFILE PICTURE ---
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Logic to open ImagePicker goes here later
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening camera/gallery...")));
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: Responsive.r(context, 55),
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: const AssetImage('assets/img/profile_placeholder.jpg'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryBackground, width: 3),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(context, AppTheme.space32)),

              // --- FORM FIELDS ---
              _buildInputField(label: "Full Name", icon: Icons.person_outline_rounded, controller: _nameController),
              SizedBox(height: Responsive.h(context, AppTheme.space16)),
              
              _buildInputField(label: "Email Address", icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
              SizedBox(height: Responsive.h(context, AppTheme.space16)),
              
              _buildInputField(label: "Mobile Number", icon: Icons.phone_outlined, controller: _phoneController, keyboardType: TextInputType.phone),
              SizedBox(height: Responsive.h(context, AppTheme.space16)),
              
              _buildInputField(label: "Home Address", icon: Icons.location_on_outlined, controller: _addressController),
              SizedBox(height: Responsive.h(context, AppTheme.space16)),
              
              _buildInputField(label: "Change Password (Optional)", icon: Icons.lock_outline_rounded, controller: _passwordController, obscureText: true),
              
              SizedBox(height: Responsive.h(context, AppTheme.space48)),

              // --- SAVE BUTTON ---
              CleanSlButton(
                text: "Save Changes",
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text fields
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        SizedBox(height: Responsive.h(context, 8)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.accentColor, size: 20),
            hintText: "Enter $label",
            // The rest of the styling (white background, rounded corners) 
            // is automatically pulled from your AppTheme!
          ),
        ),
      ],
    );
  }
}