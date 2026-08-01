import 'package:aitapp/application/usecases/login_usecase.dart';
import 'package:aitapp/domain/types/identity.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:aitapp/presentation/wighets/loading/circular_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 事務職員向けのID/パスワードによるログイン画面。
///
/// 学生はEntraID(SSO)を使うが、事務職員は従来どおり愛工大IDとパスワードで
/// ログインする。入力したID/パスワードを spAppLogin に送り、成功したら
/// そのID/パスワードをそのまま保存する。
class StaffLoginScreen extends HookConsumerWidget {
  const StaffLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = useRef('');
    final password = useRef('');
    final isObscure = useState(true);
    final isLoading = useState(false);
    final isError = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submit() async {
      isError.value = false;
      if (!formKey.currentState!.validate()) {
        return;
      }
      formKey.currentState!.save();
      isLoading.value = true;
      final canLogin = await canLoginLcam(
        id: id.value,
        password: password.value,
      );
      if (!canLogin) {
        isError.value = true;
        isLoading.value = false;
        return;
      }
      if (!context.mounted) {
        return;
      }
      await completeLogin(
        context: context,
        ref: ref,
        identity: Identity(id: id.value, password: password.value),
      );
    }

    String? validate(String? value) {
      if (value == null || value.trim().isEmpty || value.trim().length > 20) {
        return '20文字以下で入力してください';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('事務職員ログイン'),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
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
                          const SizedBox(height: 30),
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
                          const SizedBox(height: 20),
                          TextFormField(
                            validator: validate,
                            onSaved: (newValue) {
                              id.value = newValue!.trim();
                            },
                            autofillHints: const [AutofillHints.username],
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: '事務ID',
                              isDense: true,
                              prefixIcon: const Icon(Icons.account_circle),
                              fillColor: Theme.of(context).hoverColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          TextFormField(
                            validator: validate,
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
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: isLoading.value ? null : submit,
                            child: const Text('ログイン'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: isLoading.value
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('事務職員以外の方はこちら'),
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
            const CircularLoadingWidget(),
          },
        ],
      ),
    );
  }
}
