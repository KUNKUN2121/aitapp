import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:aitapp/presentation/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = useRef('');
    final password = useRef('');
    final isObscure = useState(true);
    final isLoading = useState(false);
    final isError = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<bool> validate() async {
      late final bool loginBool;
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        loginBool = await canLoginLcam(
          id: id.value,
          password: password.value,
        );
        ref
            .read(lastLoginNotifierProvider.notifier)
            .changeState(LastLogin.others);
      } else {
        loginBool = false;
      }

      return loginBool;
    }

    Future<void> setIdentity() async {
      isError.value = false;
      final pref = ref.read(sharedPreferencesProvider);
      await pref.setString('id', id.value);
      await pref
          .setString(
        'password',
        password.value,
      )
          .then(
        (value) {
          ref.read(identityProvider.notifier).setIdPassword(
                id.value,
                password.value,
              );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (ctx) => const TabScreen(),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AutofillGroup(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '愛工大へログイン',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            height: 20,
                            child: isError.value
                                ? Text(
                                    'ID パスワードが異なります',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length <= 2 ||
                                  value.trim().length >= 10) {
                                return '2文字以上10文字以下で入力してください';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              id.value = newValue!.trim();
                            },
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: '愛工大ID',
                              isDense: true,
                              prefixIcon: const Icon(Icons.account_circle),
                              fillColor: Theme.of(context).hoverColor,
                              filled: true,
                              // border: InputBorder.none,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length <= 2 ||
                                  value.trim().length >= 10) {
                                return '2文字以上10文字以下で入力してください';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              password.value = newValue!.trim();
                            },
                            autofillHints: const [AutofillHints.password],
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: isObscure.value,
                            decoration: InputDecoration(
                              hintText: 'パスワード',
                              isDense: true,
                              prefixIcon: const Icon(Icons.lock),
                              fillColor: Theme.of(context).hoverColor,
                              filled: true,
                              // border: InputBorder.none,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isObscure.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  isObscure.value = !isObscure.value;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              isLoading.value = true;
                              if (await validate()) {
                                await setIdentity();
                              } else {
                                isError.value = true;
                                isLoading.value = false;
                              }
                            },
                            child: const Text('ログイン'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading.value) ...{
            const Center(
              child: CircularProgressIndicator(),
            ),
          },
        ],
      ),
    );
  }
}
