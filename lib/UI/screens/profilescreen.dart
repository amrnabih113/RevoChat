import 'dart:io';
import 'package:animation/UI/widgets/mybutton.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/functions.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  XFile? _selectedImage;
  UserModel? updateduser;
  bool isLoading = false;

  @override
  void initState() {
    _usernameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    updateduser = widget.user;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: gradientTeal2),
        child: Column(
          children: [
            _buildTopPageWidget(),
            Expanded(
              child: _buildBodyWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPageWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_buildTitleWidget()],
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: white),
            ),
            _titleTextWidget(),
          ],
        ),
      ],
    );
  }

  Widget _titleTextWidget() {
    return const Text(
      "Edit Profile",
      style: TextStyle(
        fontSize: 35,
        color: white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileImageWidget(XFile? image) {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          border: Border.all(color: teal, width: 2),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 6,
              color: Colors.black26,
            ),
          ],
        ),
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: image != null && image.path.isNotEmpty
                  ? FileImage(File(image.path))
                  : widget.user.imageurl != null &&
                          widget.user.imageurl!.isNotEmpty
                      ? NetworkImage(widget.user.imageurl!)
                      : const AssetImage("assets/images/avatar.png")
                          as ImageProvider,
              radius: 65,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [teal, teal.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(1, 3),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                  border: Border.all(color: white, width: 2),
                ),
                child: InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = pickedFile;
                      });
                    }
                  },
                  child: const Icon(Icons.edit, color: white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyWidget() {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: _buildListViewWidget(),
    );
  }

  Widget _buildListViewWidget() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoading) {
            setState(() {
              isLoading = true;
            });
          } else if (state is UserUpdated) {
            setState(() {
              isLoading = false;
            });
            showErrorDialog(
                "Your  is Profile Updated Successfully", updateduser);
            // Navigator.pop(context);
          } else if (state is UserError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ConstantFuncs().showErrorDialog(context, state.message);
            });
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildProfileImageWidget(_selectedImage ?? widget.user.image),
            const SizedBox(height: 30),
            _buildTextEditingWidget(
                "Username", Icons.person, _usernameController),
            const SizedBox(height: 30),
            _buildTextEditingWidget("Email", Icons.email, _emailController),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: MyButton(
                onPressed: () {
                  final updatedUser = UserModel(
                    id: widget.user.id,
                    email: _emailController.text,
                    name: _usernameController.text,
                    image: _selectedImage,
                  );

                  setState(() {
                    updateduser = updatedUser;
                  });
                  context.read<UserBloc>().add(UpdateUser(updatedUser));
                },
                child: const Text("Update Profile",
                    style: TextStyle(color: white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorDialog(String message, user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Success',
          ),
          titleTextStyle: TextStyle(color: darkTeal, fontSize: 24),
          content: Text(message),
          contentTextStyle: TextStyle(fontSize: 18, color: grey),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                homepage,
                (route) => false,
                arguments: user,
              ),
              child: const Text(
                'ok',
                style: TextStyle(fontSize: 16, color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextEditingWidget(
      String title, IconData icon, TextEditingController controller) {
    return TextField(
      cursorColor: darkTeal,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: darkTeal),
        labelText: title,
        labelStyle: TextStyle(color: medTeal!, fontSize: 22),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: teal),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: teal),
        ),
      ),
    );
  }
}
