import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../application/auth_state_provider.dart';
import '../../application/auth_status.dart';
import '../../routes/app_router.dart';

class LoginForm extends ConsumerStatefulWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String title;
  LoginForm({super.key, this.title = 'Login'});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _showPassword = false;

  void _toggleVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Form form = Form(
      key: widget._formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "E-Mail"),
            controller: widget._emailController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter E-Mail address';
              }
              if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value)) {
                return 'Not a valid E-Mail-Address';
              }
              return null;
            },
          ),
          TextFormField(
            obscureText: !_showPassword,
            controller: widget._passwordController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Passwort",
              suffixIcon: GestureDetector(
                onTap: () {
                  _toggleVisibility();
                },
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.red,
                ),
              ),
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password may not be empty';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (widget._formKey.currentState!.validate()) {
                ref
                    .read(authStateProvider.notifier)
                    .login(
                        email: widget._emailController.text,
                        password: widget._passwordController.text)
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful')));
                  AutoRouter.of(context).replace(HomeRoute());
                }).catchError((error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                });
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );

    Widget activeWidget = form;

    ref.watch(authStateProvider).when(
      data: (value) {
        if (value == AuthStatus.authenticated) {
          activeWidget = const SizedBox.shrink();

          AutoRouter.of(context).replaceNamed('/home');
        } else {
          activeWidget = form;
        }
      },
      loading: () {
        activeWidget = const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      },
    );

    return activeWidget;
  }
}
